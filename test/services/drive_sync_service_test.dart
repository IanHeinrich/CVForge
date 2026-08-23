import 'dart:async';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/drive/drive_file_snapshot.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/services/drive_api_client_service.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Same shape as `backup_service_test.dart`'s helper of the same name — a
/// real in-memory `box/key` map behind the mock, so `DriveSyncService`'s
/// own persisted sync-state rows (`drive_file_id`, `drive_last_synced_
/// version`, …) genuinely round-trip rather than each being stubbed
/// individually.
Map<String, String> _wireMemoryStorage(MockLocalStorageService storage) {
  final memory = <String, String>{};
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

final _fixtureBundle = CvBackupBundle(
  app: 'cv-forge',
  bundleVersion: 1,
  exportedAt: DateTime.utc(2026, 1, 1),
  appVersion: '2.13.0',
  drafts: const [],
);

DriveFileSnapshot _snapshot(int version) => DriveFileSnapshot(
  fileId: 'file-1',
  version: version,
  modifiedTime: DateTime.utc(2026, 1, version),
);

void main() {
  group('DriveSyncServiceTest -', () {
    late Map<String, String> memory;
    late MockGoogleAuthService auth;
    late MockDriveApiClientService api;
    late MockVaultService vault;
    late MockDraftService drafts;
    late MockBackupService backup;
    late DriveSyncService service;

    void Function()? vaultListener;
    void Function()? draftsListener;

    setUp(() {
      final storage = getAndRegisterLocalStorageService();
      memory = _wireMemoryStorage(storage);
      auth = getAndRegisterGoogleAuthService();
      api = getAndRegisterDriveApiClientService();
      vault = getAndRegisterVaultService();
      drafts = getAndRegisterDraftService();
      backup = getAndRegisterBackupService();

      when(auth.isConfigured).thenReturn(true);
      when(backup.buildBundle()).thenReturn(_fixtureBundle);

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
      );
    });
    tearDown(() => locator.reset());

    /// Connects and lets the initial reconciliation settle on a
    /// freshly-created `file-1` at version 1 — the common starting point
    /// every scenario below builds on.
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

    test(
      'connect attaches a change listener to both Vault and Drafts',
      () async {
        await connect();

        expect(vaultListener, isNotNull);
        expect(draftsListener, isNotNull);
      },
    );

    test('a burst of local edits collapses into exactly one push after the '
        'idle debounce', () async {
      await connect();
      clearInteractions(api);
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

    test('flushPendingWrites is a no-op when nothing is dirty', () async {
      await connect();
      clearInteractions(api);

      await service.flushPendingWrites();

      verifyZeroInteractions(api);
    });

    test("syncNow applies Drive's copy silently when this device has no "
        'unsynced edits', () async {
      await connect();
      final remoteBundle = _fixtureBundle.copyWith(activeDraftId: 'd1');
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));
      when(
        api.downloadFile('token', 'file-1'),
      ).thenAnswer((_) async => remoteBundle.toJson());
      when(
        drafts.replaceAll(any, activeDraftId: anyNamed('activeDraftId')),
      ).thenAnswer((_) async {});

      await service.syncNow();

      verify(
        drafts.replaceAll(
          remoteBundle.drafts,
          activeDraftId: remoteBundle.activeDraftId,
        ),
      ).called(1);
      verifyNever(vault.replaceAll(any));
      expect(service.status, isA<DriveSyncIdle>());
      expect(
        memory['${StorageBoxes.settings}/${StorageKeys.driveLastSyncedVersion}'],
        '2',
      );
    });

    test('a local edit plus Drive having moved on raises a conflict after a '
        'safety backup, without applying remote', () async {
      await connect();
      when(backup.exportBackup()).thenAnswer((_) async {});
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenAnswer((_) async => _snapshot(2));

      vaultListener!();
      await service.syncNow();

      verify(backup.exportBackup()).called(1);
      verifyNever(
        drafts.replaceAll(any, activeDraftId: anyNamed('activeDraftId')),
      );
      expect(service.status, isA<DriveSyncConflict>());
    });

    test('a 401 from Drive during push surfaces needsReauth without writing '
        'sync state', () async {
      await connect();
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenThrow(const DriveApiException(DriveApiFailure.needsReauth));

      vaultListener!();
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
      when(
        api.fetchMetadata('token', 'file-1'),
      ).thenThrow(const DriveApiException(DriveApiFailure.unknown));

      vaultListener!();
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
