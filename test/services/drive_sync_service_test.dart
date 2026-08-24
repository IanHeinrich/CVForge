import 'dart:async';
import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/drive/drive_file_snapshot.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/drive_api_client_service.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Same shape as `backup_service_test.dart`'s helper of the same name — a
/// real in-memory `box/key` map behind the mock, so `DriveSyncService`'s
/// own persisted sync-state rows (`drive_file_id`, `drive_sync_base`, …)
/// genuinely round-trip rather than each being stubbed individually. That
/// matters more than it used to: the persisted ancestor is what a merge
/// reads, so a test that stubbed it would be testing nothing.
Map<String, String> _wireMemoryStorage(MockLocalStorageService storage) {
  final memory = <String, String>{};
  when(storage.ensureInitialized()).thenAnswer((_) async {});
  when(storage.read(any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final key = invocation.positionalArguments[1] as String;
    return memory['$box/$key'];
  });
  when(storage.write(any, any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final key = invocation.positionalArguments[1] as String;
    final value = invocation.positionalArguments[2] as String;
    memory['$box/$key'] = value;
  });
  when(storage.delete(any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final key = invocation.positionalArguments[1] as String;
    memory.remove('$box/$key');
  });
  return memory;
}

final _baseTime = DateTime.utc(2026, 1, 1);

Experience _job(String id, {String role = 'Engineer'}) => Experience(
  id: id,
  role: role,
  company: 'Acme',
  location: 'London',
  start: const YearMonth(year: 2020, month: 1),
);

CvVault _vaultWith(List<Experience> experiences, {DateTime? updatedAt}) =>
    CvVault(
      schemaVersion: 1,
      basics: ContactBasics.empty(),
      experiences: experiences,
      updatedAt: updatedAt ?? _baseTime,
    );

/// The starting state both sides share. Carries a real (non-null) vault so
/// the vault half of a merge is actually exercised — with `vault: null` the
/// only thing these tests could ever prove was how drafts behave.
final _fixtureBundle = CvBackupBundle(
  app: 'cv-forge',
  bundleVersion: 1,
  exportedAt: DateTime.utc(2026, 1, 1),
  appVersion: '2.13.0',
  vault: _vaultWith([_job('e1')]),
  drafts: const [],
);

DriveFileSnapshot _snapshot(int version) => DriveFileSnapshot(
  fileId: 'file-1',
  version: version,
  modifiedTime: DateTime.utc(2026, 1, version),
);

Map<String, dynamic> _decode(String? raw) =>
    jsonDecode(raw!) as Map<String, dynamic>;

/// Round-trips through JSON so a `toJson()` map compares equal to one that
/// has been through `jsonEncode`/`jsonDecode` on the way to storage.
Map<String, dynamic> _normalized(CvBackupBundle bundle) =>
    jsonDecode(jsonEncode(bundle.toJson())) as Map<String, dynamic>;

void main() {
  group('DriveSyncServiceTest -', () {
    late Map<String, String> memory;
    late MockGoogleAuthService auth;
    late MockDriveApiClientService api;
    late MockVaultService vault;
    late MockDraftService drafts;
    late MockBackupService backup;
    late MockSettingsService settings;
    late DriveSyncService service;

    /// What `BackupService.buildBundle()` currently returns — this test's
    /// stand-in for local state. Dirtiness is content-based now, so a test
    /// makes local "dirty" by changing this, which is exactly what a real
    /// edit does. (The old timestamp-based signal needed a `+50ms` fudge
    /// here to survive two `DateTime.now()` calls landing in the same
    /// millisecond; there's nothing left for that to go wrong in.)
    late CvBackupBundle localBundle;

    void Function()? vaultListener;
    void Function()? draftsListener;

    /// Stands in for the browser gesture `GoogleAuthServiceWeb` waits on
    /// before it can mint a token. Completing it is the test's way of
    /// saying "the user clicked something"; leaving it pending is a page
    /// that has loaded but not been touched yet.
    late Completer<String?> gestureToken;

    setUp(() {
      final storage = getAndRegisterLocalStorageService();
      memory = _wireMemoryStorage(storage);
      auth = getAndRegisterGoogleAuthService();
      api = getAndRegisterDriveApiClientService();
      vault = getAndRegisterVaultService();
      drafts = getAndRegisterDraftService();
      backup = getAndRegisterBackupService();
      settings = getAndRegisterSettingsService();
      when(settings.settings).thenReturn(AppSettings.empty());
      when(settings.replacePreferences(any)).thenAnswer((_) async {});

      when(auth.isConfigured).thenReturn(true);
      when(auth.warmUp()).thenAnswer((_) async {});
      gestureToken = Completer<String?>();
      when(
        auth.tokenOnNextUserGesture(),
      ).thenAnswer((_) => gestureToken.future);
      localBundle = _fixtureBundle;
      when(backup.buildBundle()).thenAnswer((_) => localBundle);

      // Applying a bundle has to be visible to the next buildBundle(), or
      // the apply-then-rebuild-then-push ordering can't be tested at all —
      // the real services behave this way, and _mergeApplyAndPush uploads
      // the rebuild rather than the raw merge output.
      when(vault.replaceAll(any)).thenAnswer((invocation) async {
        localBundle = localBundle.copyWith(
          vault: invocation.positionalArguments.first as CvVault,
        );
      });
      when(
        drafts.replaceAll(any, activeDraftId: anyNamed('activeDraftId')),
      ).thenAnswer((invocation) async {
        localBundle = localBundle.copyWith(
          drafts: invocation.positionalArguments.first as List<CvDraft>,
          activeDraftId: invocation.namedArguments[#activeDraftId] as String?,
        );
      });

      vaultListener = null;
      draftsListener = null;
      when(vault.addListener(any)).thenAnswer((invocation) {
        vaultListener = invocation.positionalArguments.first as void Function();
      });
      when(drafts.addListener(any)).thenAnswer((invocation) {
        draftsListener =
            invocation.positionalArguments.first as void Function();
      });

      service = DriveSyncService(
        idleDebounce: const Duration(milliseconds: 30),
        maxWait: const Duration(milliseconds: 90),
        mergedNoticeDuration: const Duration(milliseconds: 500),
      );
    });
    tearDown(() => locator.reset());

    /// Connects and lets the initial reconciliation settle on a
    /// freshly-created `file-1` at version 1 holding [_fixtureBundle] —
    /// the common starting point, and the ancestor every merge below is
    /// measured against.
    Future<void> connect() async {
      when(auth.connect()).thenAnswer((_) async => 'token');
      // Every reconcile/push after the initial connect() call renews the
      // token silently, not interactively — `connect()` itself is only
      // called once, up front.
      when(auth.silentAccessToken()).thenAnswer((_) async => 'token');
      when(
        api.fetchAccountEmail('token'),
      ).thenAnswer((_) async => 'person@example.com');
      when(api.findFile('token')).thenAnswer((_) async => null);
      when(api.createFile('token', any)).thenAnswer((_) async => _snapshot(1));
      await service.connect();
    }

    /// A local edit: adds a second job that Drive hasn't seen.
    void editLocally() => localBundle = _fixtureBundle.copyWith(
      vault: _vaultWith([
        _job('e1'),
        _job('e2'),
      ], updatedAt: _baseTime.add(const Duration(hours: 1))),
    );

    /// Drive's side of the same divergence: a *different* new job, so the
    /// two sides overlap on nothing and a correct merge keeps both.
    final remoteEdited = _fixtureBundle.copyWith(
      vault: _vaultWith([
        _job('e1'),
        _job('e3'),
      ], updatedAt: _baseTime.add(const Duration(minutes: 30))),
    );

    List<String> experienceIdsPassedToVault() {
      final applied =
          verify(vault.replaceAll(captureAny)).captured.last as CvVault;
      return applied.experiences.map((e) => e.id).toList();
    }

    test('connect attaches a change listener to the Vault, Drafts and '
        'Settings — preferences ride in the bundle, so changing your '
        'default region has to arm a push on its own rather than waiting '
        'for an unrelated Vault edit', () async {
      await connect();

      expect(vaultListener, isNotNull);
      expect(draftsListener, isNotNull);
      verify(settings.addListener(any)).called(1);
    });

    test("applying Drive's copy replaces preferences too, so a default "
        'region set on another device actually lands', () async {
      await connect();
      final remoteWithPrefs = _fixtureBundle.copyWith(
        preferences: CvPreferences(
          defaultRegion: RegionProfile.us,
          updatedAt: _baseTime.add(const Duration(hours: 1)),
        ),
      );
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteWithPrefs.toJson());

      await service.syncNow();

      final applied =
          verify(settings.replacePreferences(captureAny)).captured.single
              as CvPreferences;
      expect(applied.defaultRegion, RegionProfile.us);
    });

    test('a burst of local edits collapses into exactly one push after the '
        'idle debounce', () async {
      await connect();
      clearInteractions(api);
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(1));
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(2));

      vaultListener!();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      vaultListener!();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      vaultListener!();

      // Longer than idleDebounce (30ms) measured from the *last* edit
      // above, so exactly one push should have fired by now.
      await Future<void>.delayed(const Duration(milliseconds: 60));

      verify(api.updateFile('token', 'file-1', any)).called(1);
      expect(service.status, isA<DriveSyncIdle>());
    });

    test('continuous edits still push once maxWait elapses', () async {
      await connect();
      clearInteractions(api);
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(1));
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(2));

      // Re-triggers faster than idleDebounce (30ms), for longer than
      // maxWait (90ms) — if only the idle timer existed, this would never
      // push at all, since it's continuously being cancelled and re-armed.
      final ticker = Timer.periodic(
        const Duration(milliseconds: 15),
        (_) => vaultListener!(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 150));
      ticker.cancel();

      verify(
        api.updateFile('token', 'file-1', any),
      ).called(greaterThanOrEqualTo(1));
    });

    test('two overlapping sync triggers never call the Drive API '
        'concurrently — a slower push finishing after a faster one could '
        "otherwise clobber the faster one's already-correct version "
        'bookkeeping', () async {
      await connect();
      editLocally();

      var inFlight = 0;
      var maxConcurrent = 0;
      Future<T> track<T>(Future<T> Function() call) async {
        inFlight++;
        maxConcurrent = inFlight > maxConcurrent ? inFlight : maxConcurrent;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        final result = await call();
        inFlight--;
        return result;
      }

      // A real server: fetchMetadata reflects whatever the most recent
      // updateFile actually wrote, not a value fixed for the whole test.
      // A fixed snapshot here would reproduce the very bug under test
      // inside the mock instead of exercising the fix.
      var serverVersion = 1;
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) => track(() async => _snapshot(serverVersion)));
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) => track(() async => _snapshot(++serverVersion)));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) => track(() async => localBundle.toJson()));

      await Future.wait([service.syncNow(), service.syncNow()]);

      expect(maxConcurrent, 1);
      expect(service.status, isNot(isA<DriveSyncErrorState>()));
    });

    test('a no-op edit (content returns to what Drive already holds) skips '
        'the network write entirely', () async {
      await connect();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(1));
      clearInteractions(api);
      // Edited, then edited back — local content is byte-identical to the
      // ancestor again.
      editLocally();
      localBundle = _fixtureBundle;

      await service.flushPendingWrites();

      verifyNever(api.updateFile(any, any, any));
      expect(service.status, isA<DriveSyncIdle>());
    });

    test('flushPendingWrites is a no-op when nothing is dirty', () async {
      await connect();
      clearInteractions(api);

      await service.flushPendingWrites();

      verifyZeroInteractions(api);
    });

    test("syncNow applies Drive's copy silently when this device has no "
        'unsynced edits', () async {
      await connect();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteEdited.toJson());

      await service.syncNow();

      expect(experienceIdsPassedToVault(), ['e1', 'e3']);
      verifyNever(api.updateFile(any, any, any));
      verifyNever(backup.exportBackup());
      expect(service.status, isA<DriveSyncIdle>());
      expect(
        memory['${StorageBoxes.settings}/${StorageKeys.driveLastSyncedVersion}'],
        '2',
      );
    });

    test('reconnecting to an existing remote file with no local edits does '
        'not raise a false sync error', () async {
      // Simulates: connect → disconnect → reconnect, with Drive's file
      // still holding whatever an earlier session last wrote, and this
      // device's local Vault genuinely unchanged since.
      await connect();
      await service.disconnect();

      when(auth.connect()).thenAnswer((_) async => 'token');
      when(
        api.fetchAccountEmail('token'),
      ).thenAnswer((_) async => 'person@example.com');
      // This time the file already exists (from the earlier "session").
      when(api.findFile('token')).thenAnswer((_) async => _snapshot(1));
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(1));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => _fixtureBundle.toJson());

      await service.connect();

      expect(service.status, isA<DriveSyncIdle>());
    });

    test('a local edit plus Drive having moved on merges both sides instead '
        'of asking the user to discard one — the headline case: a job '
        'added here and a different job added there both survive', () async {
      await connect();
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteEdited.toJson());
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(3));

      await service.syncNow();

      expect(experienceIdsPassedToVault(), ['e1', 'e2', 'e3']);
      verify(api.updateFile('token', 'file-1', any)).called(1);
      verifyNever(backup.exportBackup());
      expect(service.status, isA<DriveSyncMerged>());
    });

    test(
      'the merged result is what gets uploaded, not the pre-merge local '
      'bundle — applying prunes and re-sorts, so the ancestor has to be '
      'the post-apply rebuild or the next merge sees phantom edits',
      () async {
        await connect();
        editLocally();
        when(
          api.fetchMetadata('token', 'file-1'),
        ).thenAnswer((_) async => _snapshot(2));
        when(
          api.downloadFile('token', 'file-1'),
        ).thenAnswer((_) async => remoteEdited.toJson());
        when(
          api.updateFile('token', 'file-1', any),
        ).thenAnswer((_) async => _snapshot(3));

        await service.syncNow();

        final uploaded =
            verify(
                  api.updateFile('token', 'file-1', captureAny),
                ).captured.single
                as Map<String, dynamic>;
        final uploadedVault = CvBackupBundle.fromJson(uploaded).vault!;
        expect(uploadedVault.experiences.map((e) => e.id), ['e1', 'e2', 'e3']);
        // And the persisted ancestor is exactly those bytes.
        expect(
          _decode(
            memory['${StorageBoxes.settings}/${StorageKeys.driveSyncBase}'],
          ),
          jsonDecode(jsonEncode(uploaded)),
        );
      },
    );

    test(
      'a merge applies locally before it pushes, so a failed upload '
      'leaves local holding the merged content and retries cleanly',
      () async {
        await connect();
        editLocally();
        when(
          api.fetchMetadata('token', 'file-1'),
        ).thenAnswer((_) async => _snapshot(2));
        when(
          api.downloadFile('token', 'file-1'),
        ).thenAnswer((_) async => remoteEdited.toJson());
        when(
          api.updateFile('token', 'file-1', any),
        ).thenThrow(const DriveApiException(DriveApiFailure.network));

        await service.syncNow();
        expect(service.status, isA<DriveSyncErrorState>());
        verifyInOrder([
          vault.replaceAll(any),
          api.updateFile('token', 'file-1', any),
        ]);

        // Drive recovers; the retry converges on the same merged content and
        // pushes it exactly once.
        when(
          api.updateFile('token', 'file-1', any),
        ).thenAnswer((_) async => _snapshot(3));
        await service.syncNow();

        verify(api.updateFile('token', 'file-1', any)).called(1);
        expect(experienceIdsPassedToVault(), ['e1', 'e2', 'e3']);
      },
    );

    test('applying a merge does not re-arm the debounce — otherwise every '
        'merge would push again, forever', () async {
      await connect();
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteEdited.toJson());
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(3));

      await service.syncNow();
      // Well past idleDebounce (30ms) and maxWait (90ms).
      await Future<void>.delayed(const Duration(milliseconds: 150));

      verify(api.updateFile('token', 'file-1', any)).called(1);
    });

    test(
      "a version bump with byte-identical content isn't divergence — "
      "Drive's own docs describe version as reflecting every server-side "
      'change, "even those not visible to the user", so a bump alone '
      "proves nothing; this device's genuine local edit still pushes",
      () async {
        await connect();
        editLocally();
        when(
          api.fetchMetadata('token', 'file-1'),
        ).thenAnswer((_) async => _snapshot(2));
        // Exactly what this device last synced — the counter moved, the
        // content didn't.
        when(
          api.downloadFile('token', 'file-1'),
        ).thenAnswer((_) async => _fixtureBundle.toJson());
        when(
          api.updateFile('token', 'file-1', any),
        ).thenAnswer((_) async => _snapshot(3));

        await service.syncNow();

        verifyNever(vault.replaceAll(any));
        verify(api.updateFile('token', 'file-1', any)).called(1);
        expect(service.status, isA<DriveSyncIdle>());
      },
    );

    test(
      'the ancestor is persisted after a push and cleared on disconnect',
      () async {
        await connect();

        expect(
          _decode(
            memory['${StorageBoxes.settings}/${StorageKeys.driveSyncBase}'],
          ),
          _normalized(_fixtureBundle),
        );

        await service.disconnect();

        expect(
          memory['${StorageBoxes.settings}/${StorageKeys.driveSyncBase}'],
          isNull,
        );
      },
    );

    test("after adopting Drive's copy the ancestor is what was downloaded, "
        'not a post-apply local rebuild', () async {
      await connect();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteEdited.toJson());

      await service.syncNow();

      expect(
        _decode(
          memory['${StorageBoxes.settings}/${StorageKeys.driveSyncBase}'],
        ),
        _normalized(remoteEdited),
      );
    });

    test('a page reload does not turn the next sync into a false conflict — '
        'the ancestor is persisted, so a restarted service still knows what '
        'Drive last held', () async {
      await connect();
      editLocally();

      // A brand-new service over the same storage: exactly what a browser
      // refresh produces. The in-memory-only signature this replaced was
      // null here, which made the first version mismatch after every
      // reload read as divergence.
      final reloaded = DriveSyncService(
        idleDebounce: const Duration(milliseconds: 30),
        maxWait: const Duration(milliseconds: 90),
      );
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => _fixtureBundle.toJson());
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(3));

      await reloaded.start();
      // A page that has loaded but not been touched holds no token yet,
      // so nothing should have gone to Drive.
      verifyNever(api.fetchMetadata(any, any));

      gestureToken.complete('token');
      await pumpEventQueue();

      // Drive's content still matched the ancestor, so this is a plain
      // push of the local edit — no merge, no error, nothing discarded.
      verifyNever(vault.replaceAll(any));
      verify(api.updateFile('token', 'file-1', any)).called(1);
      expect(reloaded.status, isA<DriveSyncIdle>());
    });

    test('a refresh waits for the user to interact before syncing, and does '
        'not strand the session on "reconnect" in the meantime — GIS mints '
        'a token via a popup, which a browser refuses at page load '
        '(popup_failed_to_open), so an immediate attempt always fails even '
        'though the grant is fine', () async {
      await connect();
      editLocally();

      final reloaded = DriveSyncService(
        idleDebounce: const Duration(milliseconds: 30),
        maxWait: const Duration(milliseconds: 90),
      );
      await reloaded.start();

      verify(auth.warmUp()).called(1);
      verifyNever(api.fetchMetadata(any, any));
      expect(reloaded.status, isA<DriveSyncIdle>());
      expect(reloaded.status, isNot(isA<DriveSyncNeedsReauth>()));
    });

    test('a refresh only reports needsReauth once a real gesture has failed '
        'to produce a token — that means the grant is genuinely gone, not '
        'just momentarily unusable', () async {
      await connect();

      final reloaded = DriveSyncService(
        idleDebounce: const Duration(milliseconds: 30),
        maxWait: const Duration(milliseconds: 90),
      );
      await reloaded.start();

      gestureToken.complete(null);
      await pumpEventQueue();

      expect(reloaded.status, isA<DriveSyncNeedsReauth>());
      verifyNever(api.fetchMetadata(any, any));
    });

    test('an existing user with no stored ancestor unions both sides rather '
        'than dropping either — the whole of the migration path', () async {
      // Seed the rows a pre-merge release would have left behind: a known
      // file and version, but no ancestor.
      memory['${StorageBoxes.settings}/${StorageKeys.driveEnabled}'] = 'true';
      memory['${StorageBoxes.settings}/${StorageKeys.driveAccountEmail}'] =
          'person@example.com';
      memory['${StorageBoxes.settings}/${StorageKeys.driveFileId}'] = 'file-1';
      memory['${StorageBoxes.settings}/${StorageKeys.driveLastSyncedVersion}'] =
          '1';
      memory['${StorageBoxes.settings}/${StorageKeys.driveLastSyncedAt}'] =
          DateTime.utc(2026, 1, 1).toIso8601String();

      when(auth.silentAccessToken()).thenAnswer((_) async => 'token');
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteEdited.toJson());
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(3));

      await service.start();
      gestureToken.complete('token');
      await pumpEventQueue();

      expect(experienceIdsPassedToVault(), ['e1', 'e2', 'e3']);
      expect(service.status, isA<DriveSyncMerged>());
    });

    test(
      'a bundle from a newer CVForge is refused rather than merged — '
      'field-wise merging across data shapes would mis-map silently',
      () async {
        await connect();
        editLocally();
        when(
          api.fetchMetadata('token', 'file-1'),
        ).thenAnswer((_) async => _snapshot(2));
        when(api.downloadFile('token', 'file-1')).thenAnswer(
          (_) async => remoteEdited.copyWith(bundleVersion: 2).toJson(),
        );

        await service.syncNow();

        verifyNever(vault.replaceAll(any));
        verifyNever(api.updateFile(any, any, any));
        final status = service.status as DriveSyncErrorState;
        expect(status.message, contains('newer version'));
      },
    );

    test('a 401 from Drive during push surfaces needsReauth without writing '
        'sync state', () async {
      await connect();
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenThrow(const DriveApiException(DriveApiFailure.needsReauth));

      await service.flushPendingWrites();

      expect(service.status, isA<DriveSyncNeedsReauth>());
      expect(
        memory['${StorageBoxes.settings}/${StorageKeys.driveLastSyncedVersion}'],
        '1',
      );
    });

    test('an unknown push failure surfaces an error but keeps the edit '
        'marked dirty for retry', () async {
      await connect();
      editLocally();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenThrow(const DriveApiException(DriveApiFailure.unknown));

      await service.flushPendingWrites();
      expect(service.status, isA<DriveSyncErrorState>());

      // Retry succeeds once Drive stops erroring — proves the edit was
      // never marked clean after the failed attempt.
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(1));
      when(
        api.updateFile('token', 'file-1', any),
      ).thenAnswer((_) async => _snapshot(2));
      await service.syncNow();

      verify(api.updateFile('token', 'file-1', any)).called(1);
      expect(service.status, isA<DriveSyncIdle>());
    });
  });
}
