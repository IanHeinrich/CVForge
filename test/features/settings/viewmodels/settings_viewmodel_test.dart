import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/features/settings/dialogs/drive_conflict/drive_conflict_dialog_data.dart';
import 'package:cv_forge/features/settings/views/settings/settings_viewmodel.dart';
import 'package:cv_forge/models/backup/cv_backup_bundle.dart';
import 'package:cv_forge/models/drive/drive_sync_status.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/backup_service.dart';
import 'package:cv_forge/services/google_auth_service.dart';
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
    late MockVaultService vaultService;
    late MockDialogService dialogService;
    late MockLlmService llmService;
    late MockDriveSyncService driveSyncService;

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
      vaultService = getAndRegisterVaultService();
      dialogService = getAndRegisterDialogService();
      llmService = getAndRegisterLlmService();
      driveSyncService = getAndRegisterDriveSyncService();
      // Mockito can't synthesize its own dummy for a custom sealed class
      // like DriveSyncStatus — `when(driveSyncService.status)` below would
      // otherwise throw MissingDummyValueError before the explicit stub
      // even applies.
      provideDummy<DriveSyncStatus>(const DriveSyncStatus.disconnected());
      // Every test not specifically about Drive gets the
      // hidden-when-unconfigured default, matching a build with no
      // GOOGLE_OAUTH_CLIENT_ID compiled in.
      when(driveSyncService.isAvailable).thenReturn(false);
      when(
        driveSyncService.status,
      ).thenReturn(const DriveSyncStatus.disconnected());
      when(draftService.drafts).thenReturn([]);
      when(vaultService.vault).thenReturn(
        CvVault(
          schemaVersion: 1,
          basics: ContactBasics.empty(),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      when(settingsService.settings).thenReturn(AppSettings.empty());
      when(
        settingsService.setLastBackupAt(any),
      ).thenAnswer((_) => Future<void>.value());
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

    group('backup state (7.7) -', () {
      test('lastBackupAt is null initially', () {
        final model = SettingsViewModel();

        expect(model.lastBackupAt, isNull);
      });

      test('a successful exportBackup sets lastBackupAt', () async {
        when(
          backupService.exportBackup(),
        ).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.exportBackup();

        verify(settingsService.setLastBackupAt(any)).called(1);
      });

      test('a failed exportBackup does not set lastBackupAt', () async {
        when(
          backupService.exportBackup(),
        ).thenThrow(const BackupException(BackupFailure.ioError, 'disk full'));

        final model = SettingsViewModel();
        await model.exportBackup();

        verifyNever(settingsService.setLastBackupAt(any));
      });

      test('hasChangesSinceBackup is false with no lastBackupAt at all', () {
        final model = SettingsViewModel();

        expect(model.hasChangesSinceBackup, isFalse);
      });

      test('hasChangesSinceBackup is true once the Vault was updated after '
          'lastBackupAt', () {
        when(settingsService.settings).thenReturn(
          AppSettings.empty().copyWith(lastBackupAt: DateTime(2026, 1, 1)),
        );
        when(vaultService.vault).thenReturn(
          CvVault(
            schemaVersion: 1,
            basics: ContactBasics.empty(),
            updatedAt: DateTime(2026, 1, 2),
          ),
        );

        final model = SettingsViewModel();

        expect(model.hasChangesSinceBackup, isTrue);
      });

      test('hasChangesSinceBackup is false when nothing changed since '
          'lastBackupAt', () {
        when(settingsService.settings).thenReturn(
          AppSettings.empty().copyWith(lastBackupAt: DateTime(2026, 1, 2)),
        );
        when(vaultService.vault).thenReturn(
          CvVault(
            schemaVersion: 1,
            basics: ContactBasics.empty(),
            updatedAt: DateTime(2026, 1, 1),
          ),
        );

        final model = SettingsViewModel();

        expect(model.hasChangesSinceBackup, isFalse);
      });
    });

    group('clearVault (7.8) -', () {
      test('prompts for confirmation and, once confirmed, clears the '
          'Vault', () async {
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse(confirmed: true));
        when(vaultService.clearVault()).thenAnswer((_) => Future<void>.value());

        final model = SettingsViewModel();
        await model.clearVault();

        verify(vaultService.clearVault()).called(1);
      });

      test('cancelling the confirmation clears nothing', () async {
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
        await model.clearVault();

        verifyNever(vaultService.clearVault());
      });
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
          'gemini',
          'anthropic',
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

      test('clearConnectionTestResult clears a stale success, so a prior '
          "test's result can't survive editing the key/provider/model "
          '(7.7 issue 6)', () async {
        when(
          llmService.testConnection('anthropic', 'sk-ant-test'),
        ).thenAnswer((_) => Future<void>.value());
        when(
          settingsService.setApiKey('anthropic', 'sk-ant-test'),
        ).thenAnswer((_) => Future<void>.value());
        final model = SettingsViewModel();
        await model.testCopilotConnection('sk-ant-test');
        expect(model.connectionTestSucceeded, isTrue);

        model.clearConnectionTestResult();

        expect(model.connectionTestSucceeded, isFalse);
      });

      test(
        'selectCopilotProvider clears a stale connection test result',
        () async {
          when(
            settingsService.setCopilotProvider(any),
          ).thenAnswer((_) => Future<void>.value());
          when(
            settingsService.setCopilotModel(any),
          ).thenAnswer((_) => Future<void>.value());
          when(
            llmService.testConnection('anthropic', 'sk-ant-test'),
          ).thenAnswer((_) => Future<void>.value());
          when(
            settingsService.setApiKey('anthropic', 'sk-ant-test'),
          ).thenAnswer((_) => Future<void>.value());
          final model = SettingsViewModel();
          await model.testCopilotConnection('sk-ant-test');
          expect(model.connectionTestSucceeded, isTrue);

          await model.selectCopilotProvider('gemini');

          expect(model.connectionTestSucceeded, isFalse);
        },
      );
    });

    group('Google Drive -', () {
      test('isDriveAvailable mirrors DriveSyncService.isAvailable', () {
        when(driveSyncService.isAvailable).thenReturn(true);

        final model = SettingsViewModel();

        expect(model.isDriveAvailable, isTrue);
      });

      test('connectDrive delegates to DriveSyncService.connect', () async {
        when(driveSyncService.connect()).thenAnswer((_) async {});

        final model = SettingsViewModel();
        await model.connectDrive();

        verify(driveSyncService.connect()).called(1);
        expect(model.isDriveConnecting, isFalse);
      });

      test(
        'a cancelled/blocked connect surfaces a specific error message',
        () async {
          when(driveSyncService.connect()).thenThrow(
            const GoogleAuthException(GoogleAuthFailure.cancelledOrBlocked),
          );

          final model = SettingsViewModel();
          await model.connectDrive();

          expect(model.driveConnectErrorMessage, 'Connection cancelled.');
        },
      );

      test('syncDriveNow delegates to DriveSyncService.syncNow', () async {
        when(driveSyncService.syncNow()).thenAnswer((_) async {});

        final model = SettingsViewModel();
        await model.syncDriveNow();

        verify(driveSyncService.syncNow()).called(1);
      });

      test(
        'disconnectDrive does nothing when the confirmation is declined',
        () async {
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
          await model.disconnectDrive();

          verifyNever(driveSyncService.disconnect());
        },
      );

      test('disconnectDrive calls through once confirmed', () async {
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            description: anyNamed('description'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse(confirmed: true));
        when(driveSyncService.disconnect()).thenAnswer((_) async {});

        final model = SettingsViewModel();
        await model.disconnectDrive();

        verify(driveSyncService.disconnect()).called(1);
      });

      test(
        'resolveDriveConflict is a no-op when not currently in conflict',
        () async {
          when(
            driveSyncService.status,
          ).thenReturn(const DriveSyncStatus.disconnected());

          final model = SettingsViewModel();
          await model.resolveDriveConflict();

          verifyNever(
            dialogService.showCustomDialog<bool, DriveConflictDialogData>(
              variant: anyNamed('variant'),
              data: anyNamed('data'),
            ),
          );
        },
      );

      test(
        'resolveDriveConflict resolves with the choice from the dialog',
        () async {
          when(driveSyncService.status).thenReturn(
            const DriveSyncStatus.conflict(accountEmail: 'person@example.com'),
          );
          when(driveSyncService.conflictRemoteModifiedAt).thenReturn(null);
          when(
            dialogService.showCustomDialog<bool, DriveConflictDialogData>(
              variant: DialogType.driveConflict,
              data: anyNamed('data'),
            ),
          ).thenAnswer(
            (_) async => DialogResponse<bool>(confirmed: true, data: false),
          );
          when(
            driveSyncService.resolveConflict(keepLocal: false),
          ).thenAnswer((_) async {});

          final model = SettingsViewModel();
          await model.resolveDriveConflict();

          verify(driveSyncService.resolveConflict(keepLocal: false)).called(1);
        },
      );
    });
  });
}
