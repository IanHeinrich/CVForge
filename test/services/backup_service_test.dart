import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cv_forge/models/draft/text_override_field.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Same shape as `draft_service_test.dart`'s helper of the same name — a
/// real in-memory `box/key` map behind the mock, needed here so a real
/// [VaultService]/[DraftService] pair (not mocked) genuinely round-trip
/// through export→import.
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

void main() {
  test('the version stamped on a bundle matches pubspec — the only thing '
      'keeping the two in step is a doc comment saying to bump both, so '
      'this is what actually notices when one is missed', () {
    final declared = File('pubspec.yaml')
        .readAsLinesSync()
        .firstWhere((line) => line.startsWith('version:'))
        .split(':')
        .last
        .trim();

    final storage = getAndRegisterLocalStorageService();
    _wireMemoryStorage(storage);
    locator.registerLazySingleton<TemplateRegistryService>(
      TemplateRegistryService.new,
    );
    final settingsService = getAndRegisterSettingsService();
    when(settingsService.settings).thenReturn(AppSettings.empty());
    locator.registerSingleton<VaultService>(VaultService());
    locator.registerSingleton<DraftService>(DraftService());
    getAndRegisterFileDownloadService();
    getAndRegisterFileUploadService();
    getAndRegisterLocalizationService();

    final bundle = BackupService().buildBundle();

    expect(bundle.appVersion, declared);
    locator.reset();
  });

  group('BackupServiceTest -', () {
    late Map<String, String> memory;
    late VaultService vaultService;
    late DraftService draftService;
    late MockFileDownloadService fileDownload;
    late MockFileUploadService fileUpload;
    late BackupService backupService;

    setUp(() async {
      final storage = getAndRegisterLocalStorageService();
      memory = _wireMemoryStorage(storage);
      locator.registerLazySingleton<TemplateRegistryService>(
        TemplateRegistryService.new,
      );
      final settingsService = getAndRegisterSettingsService();
      when(settingsService.settings).thenReturn(AppSettings.empty());

      vaultService = VaultService();
      locator.registerSingleton<VaultService>(vaultService);
      draftService = DraftService();
      locator.registerSingleton<DraftService>(draftService);

      fileDownload = getAndRegisterFileDownloadService();
      when(
        fileDownload.saveFile(
          nameWithoutExtension: anyNamed('nameWithoutExtension'),
          bytes: anyNamed('bytes'),
          extension: anyNamed('extension'),
          mimeType: anyNamed('mimeType'),
        ),
      ).thenAnswer((_) async {});

      fileUpload = getAndRegisterFileUploadService();
      getAndRegisterLocalizationService();

      backupService = BackupService();

      await vaultService.load();
      await draftService.load();
    });
    tearDown(() => locator.reset());

    test('Export then import round-trips a known state', () async {
      final experience = await vaultService.addExperience(
        role: 'Engineer',
        company: 'Acme',
        location: 'London',
        start: const YearMonth(year: 2020, month: 1),
      );
      final bullet = await vaultService.addBullet(
        BulletOwner.experience,
        experience.id,
        text: 'Did things',
      );
      final firstDraftId = draftService.activeDraftId!;
      await draftService.setExperienceIncluded(
        experience.id,
        included: true,
        bulletIds: [bullet.id],
      );
      await draftService.setTextOverride(
        TextOverrideField.bullet,
        bullet.id,
        'Did other things',
      );
      final secondDraftId = await draftService.createDraft(name: 'Second CV');
      await draftService.openDraft(firstDraftId);

      final beforeDraftIds = draftService.drafts.map((d) => d.id).toSet();
      final beforeActiveId = draftService.activeDraftId;
      final beforeFullName = vaultService.vault.basics.fullName;
      final beforeExperienceCount = vaultService.vault.experiences.length;

      Uint8List? exportedBytes;
      when(
        fileDownload.saveFile(
          nameWithoutExtension: anyNamed('nameWithoutExtension'),
          bytes: anyNamed('bytes'),
          extension: anyNamed('extension'),
          mimeType: anyNamed('mimeType'),
        ),
      ).thenAnswer((invocation) async {
        exportedBytes = invocation.namedArguments[#bytes] as Uint8List;
      });

      await backupService.exportBackup();
      expect(exportedBytes, isNotNull);

      when(fileUpload.pickJsonFile()).thenAnswer((_) async => exportedBytes);

      final bundle = await backupService.pickImportFile();
      expect(bundle, isNotNull);

      await backupService.applyImport(bundle!);

      expect(vaultService.vault.basics.fullName, beforeFullName);
      expect(vaultService.vault.experiences.length, beforeExperienceCount);
      expect(
        draftService.drafts.map((d) => d.id).toSet(),
        beforeDraftIds..add(secondDraftId),
      );
      expect(draftService.activeDraftId, beforeActiveId);
      final restoredDraft = draftService.drafts.firstWhere(
        (d) => d.id == firstDraftId,
      );
      expect(restoredDraft.bulletOverrides[bullet.id], 'Did other things');
      expect(restoredDraft.experienceIds, contains(experience.id));
    });

    test('A truncated/invalid JSON payload throws BackupFailure.malformed and '
        'writes nothing', () async {
      when(fileUpload.pickJsonFile()).thenAnswer(
        (_) async => Uint8List.fromList(utf8.encode('not valid json{')),
      );

      final draftsBefore = draftService.drafts.length;

      await expectLater(
        backupService.pickImportFile(),
        throwsA(
          isA<BackupException>().having(
            (e) => e.failure,
            'failure',
            BackupFailure.malformed,
          ),
        ),
      );

      expect(draftService.drafts.length, draftsBefore);
    });

    test('A bundleVersion newer than this build understands throws '
        'BackupFailure.unsupportedVersion', () async {
      final futureBundle = jsonEncode({
        'app': 'cv-forge',
        'bundleVersion': BackupService.bundleVersion + 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': '99.0.0',
        'vault': null,
        'drafts': <Map<String, dynamic>>[],
        'activeDraftId': null,
      });
      when(
        fileUpload.pickJsonFile(),
      ).thenAnswer((_) async => Uint8List.fromList(utf8.encode(futureBundle)));

      await expectLater(
        backupService.pickImportFile(),
        throwsA(
          isA<BackupException>().having(
            (e) => e.failure,
            'failure',
            BackupFailure.unsupportedVersion,
          ),
        ),
      );
    });

    test('A bundle whose vault parses but whose third draft does not throws '
        'before any write — parse-all-before-write-all', () async {
      final goodDraft = CvDraft.empty(id: 'd1', templateId: 'compact');
      final badDraftJson = {
        'schemaVersion': 1,
        // Missing required fields (id/templateId/updatedAt) — fromJson
        // must throw on this entry.
      };
      final bundleJson = jsonEncode({
        'app': 'cv-forge',
        'bundleVersion': BackupService.bundleVersion,
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': '1.2.0',
        'vault': null,
        'drafts': [
          goodDraft.toJson(),
          goodDraft.copyWith(id: 'd2').toJson(),
          badDraftJson,
        ],
        'activeDraftId': 'd1',
      });
      when(
        fileUpload.pickJsonFile(),
      ).thenAnswer((_) async => Uint8List.fromList(utf8.encode(bundleJson)));

      final draftIdsBefore = draftService.drafts.map((d) => d.id).toSet();

      await expectLater(
        backupService.pickImportFile(),
        throwsA(
          isA<BackupException>().having(
            (e) => e.failure,
            'failure',
            BackupFailure.malformed,
          ),
        ),
      );

      expect(draftService.drafts.map((d) => d.id).toSet(), draftIdsBefore);
    });

    test(
      'Import deletes a pre-existing draft not present in the imported set '
      '— replace-the-world at the storage layer, not just the index',
      () async {
        final survivorId = draftService.activeDraftId!;
        final removedId = await draftService.createDraft(name: 'Will vanish');
        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.draftEntry(removedId)}',
          ),
          isTrue,
        );

        final onlySurvivor = draftService.drafts.firstWhere(
          (d) => d.id == survivorId,
        );
        final bundle = CvBackupBundle(
          app: 'cv-forge',
          bundleVersion: BackupService.bundleVersion,
          exportedAt: DateTime.now(),
          appVersion: '1.2.0',
          drafts: [onlySurvivor],
          activeDraftId: survivorId,
        );

        await backupService.applyImport(bundle);

        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.draftEntry(removedId)}',
          ),
          isFalse,
        );
        expect(draftService.drafts.map((d) => d.id), [survivorId]);
      },
    );
  });
}
