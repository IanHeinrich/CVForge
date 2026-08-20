import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('SettingsViewModel Tests -', () {
    late MockSettingsService settingsService;
    late MockBackupService backupService;
    late MockDraftService draftService;
    late MockDialogService dialogService;

    final bundle = CvBackupBundle(
      app: 'cv-forge',
      bundleVersion: 1,
      exportedAt: DateTime(2026, 1, 1),
      appVersion: '1.2.0',
      activeDraftId: null,
    );

    setUp(() {
      settingsService = getAndRegisterSettingsService();
      backupService = getAndRegisterBackupService();
      draftService = getAndRegisterDraftService();
      dialogService = getAndRegisterDialogService();
      when(draftService.drafts).thenReturn([]);
    });
    tearDown(() => locator.reset());

    test('initialise loads SettingsService', () async {
      when(settingsService.load()).thenAnswer((_) => Future<void>.value());

      final model = SettingsViewModel();
      model.initialise();
      await pumpEventQueue();

      verify(settingsService.load()).called(1);
      expect(model.isLoading, isFalse);
      expect(model.hasLoadError, isFalse);
    });

    test('exportBackup delegates to BackupService', () async {
      when(
        backupService.exportBackup(),
      ).thenAnswer((_) => Future<void>.value());

      final model = SettingsViewModel();
      await model.exportBackup();

      verify(backupService.exportBackup()).called(1);
    });

    group('importBackup -', () {
      test('cancelling the file picker does nothing', () async {
        when(backupService.pickImportFile()).thenAnswer((_) async => null);

        final model = SettingsViewModel();
        await model.importBackup();

        verifyNever(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        );
        verifyNever(backupService.applyImport(any));
      });

      test('cancelling the confirm dialog does not apply the import', () async {
        when(backupService.pickImportFile()).thenAnswer((_) async => bundle);
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse(confirmed: false));

        final model = SettingsViewModel();
        await model.importBackup();

        verifyNever(backupService.applyImport(any));
      });

      test('confirming applies the import', () async {
        when(backupService.pickImportFile()).thenAnswer((_) async => bundle);
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse(confirmed: true));
        when(
          backupService.applyImport(bundle),
        ).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.importBackup();

        verify(backupService.applyImport(bundle)).called(1);
      });

      test('a pickImportFile failure surfaces via importErrorMessage '
          'without applying anything', () async {
        when(
          backupService.pickImportFile(),
        ).thenThrow(const BackupException(BackupFailure.malformed, 'bad json'));

        final model = SettingsViewModel();
        await model.importBackup();

        expect(model.importErrorMessage, isNotNull);
        verifyNever(backupService.applyImport(any));
      });
    });
  });
}
