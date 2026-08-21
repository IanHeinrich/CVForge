import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
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
    late MockLlmService llmService;

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
      llmService = getAndRegisterLlmService();
      when(draftService.drafts).thenReturn([]);
      when(settingsService.settings).thenReturn(AppSettings.empty());
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

    group('copilot connection (4.4) -', () {
      test('selectCopilotModel persists just the model id, leaving the '
          'current provider selection alone', () async {
        when(
          settingsService.setCopilotModel(any),
        ).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.selectCopilotModel('claude-sonnet-5');

        verify(settingsService.setCopilotModel('claude-sonnet-5')).called(1);
        verifyNever(settingsService.setCopilotProvider(any));
      });

      test('selectCopilotProvider persists the provider and resets the '
          'model to that provider\'s first option', () async {
        when(
          settingsService.setCopilotProvider(any),
        ).thenAnswer((_) => Future<void>.value());
        when(
          settingsService.setCopilotModel(any),
        ).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.selectCopilotProvider('gemini');

        verify(settingsService.setCopilotProvider('gemini')).called(1);
        verify(
          settingsService.setCopilotModel('gemini-3.5-flash-lite'),
        ).called(1);
      });

      test('showCopilotProviderSelector is true once more than one '
          'provider is registered', () {
        final model = SettingsViewModel();

        expect(model.showCopilotProviderSelector, isTrue);
        expect(model.copilotProviders.map((p) => p.id), [
          'anthropic',
          'gemini',
        ]);
      });

      test('selectedCopilotProvider falls back to the default provider '
          'when nothing is stored', () {
        final model = SettingsViewModel();

        expect(model.selectedCopilotProvider.id, 'anthropic');
      });

      test('setRememberApiKey(false) clears the stored key', () async {
        when(
          settingsService.setRememberApiKey(false),
        ).thenAnswer((_) => Future<void>.value());
        when(
          settingsService.clearApiKey('anthropic'),
        ).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.setRememberApiKey(false);

        verify(settingsService.setRememberApiKey(false)).called(1);
        verify(settingsService.clearApiKey('anthropic')).called(1);
      });

      test('setRememberApiKey(true) does not clear the key', () async {
        when(
          settingsService.setRememberApiKey(true),
        ).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.setRememberApiKey(true);

        verifyNever(settingsService.clearApiKey('anthropic'));
      });

      test(
        'testCopilotConnection success stores the key and clears any error',
        () async {
          when(
            llmService.testConnection('anthropic', 'sk-ant-test'),
          ).thenAnswer((_) => Future<void>.value());
          when(
            settingsService.setApiKey('anthropic', 'sk-ant-test'),
          ).thenAnswer((_) => Future<void>.value());

          final model = SettingsViewModel();
          await model.testCopilotConnection('sk-ant-test');

          expect(model.connectionTestSucceeded, isTrue);
          expect(model.connectionTestErrorMessage, isNull);
          expect(model.isTestingConnection, isFalse);
          verify(
            settingsService.setApiKey('anthropic', 'sk-ant-test'),
          ).called(1);
        },
      );

      test('testCopilotConnection failure surfaces distinct copy per '
          'LlmFailure and never stores the rejected key', () async {
        when(
          llmService.testConnection('anthropic', 'bad-key'),
        ).thenThrow(const LlmException(LlmFailure.unauthorized));

        final model = SettingsViewModel();
        await model.testCopilotConnection('bad-key');

        expect(model.connectionTestSucceeded, isFalse);
        expect(model.connectionTestErrorMessage, isNotNull);
        verifyNever(settingsService.setApiKey('anthropic', 'bad-key'));
      });
    });
  });
}
