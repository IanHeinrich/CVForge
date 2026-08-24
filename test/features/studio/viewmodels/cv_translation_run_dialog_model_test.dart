import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/cv_translation_run/cv_translation_run_dialog_model.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/llm/cv_translation_result.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('CvTranslationRunDialogModel Tests -', () {
    late MockSettingsService settingsService;
    late MockVaultService vaultService;
    late MockDraftService draftService;
    late MockCvTranslationService translationService;

    final vault = CvVault(
      schemaVersion: 1,
      basics: ContactBasics.empty(),
      updatedAt: DateTime(2026, 1, 1),
    );

    const emptyResult = CvTranslationResult(
      roles: {},
      projectTitles: {},
      skillCategoryNames: {},
      skillLabels: {},
      educationQualifications: {},
      educationGrades: {},
      educationDetails: {},
      hobbies: {},
      bullets: {},
    );

    void stubPass() {
      when(
        translationService.runTranslationPass(
          vault: anyNamed('vault'),
          draft: anyNamed('draft'),
          targetLanguage: anyNamed('targetLanguage'),
          region: anyNamed('region'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenAnswer((_) async => emptyResult);
      when(
        draftService.applyCvTranslationResult(any, any),
      ).thenAnswer((_) async {});
    }

    setUp(() {
      registerServices();
      settingsService = getAndRegisterSettingsService();
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      translationService = getAndRegisterCvTranslationService();
      when(settingsService.settings).thenReturn(
        AppSettings.empty().copyWith(
          preferences: CvPreferences.empty().copyWith(
            aiAssistantProviderId: 'anthropic',
            aiAssistantModelId: 'claude-sonnet-5',
          ),
        ),
      );
      when(vaultService.vault).thenReturn(vault);
      when(draftService.draft).thenReturn(draftWith());
    });
    tearDown(() => locator.reset());

    test('starts in the confirm phase', () {
      final model = CvTranslationRunDialogModel();

      expect(model.phase, CvTranslationRunPhase.confirm);
      expect(model.providerDisplayName, 'Claude');
    });

    test('a first run reports that it replaces nothing', () {
      final model = CvTranslationRunDialogModel();

      expect(model.replacesExisting, isFalse);
    });

    test('a draft that already carries a translation warns that running '
        'again replaces it', () {
      when(
        draftService.draft,
      ).thenReturn(draftWith(translatedTo: DocumentLanguage.de));

      final model = CvTranslationRunDialogModel();

      expect(model.replacesExisting, isTrue);
    });

    test('run() resolves provider/model/key from Settings, applies the '
        'result, and lands on the result phase', () async {
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'sk-ant-test');
      stubPass();

      final model = CvTranslationRunDialogModel();
      await model.run();

      expect(model.phase, CvTranslationRunPhase.result);
      expect(model.result, emptyResult);
      verify(
        translationService.runTranslationPass(
          vault: vault,
          draft: anyNamed('draft'),
          targetLanguage: anyNamed('targetLanguage'),
          region: anyNamed('region'),
          providerId: 'anthropic',
          modelId: 'claude-sonnet-5',
          apiKey: 'sk-ant-test',
        ),
      ).called(1);
      verify(draftService.applyCvTranslationResult(emptyResult, any)).called(1);
    });

    test("translates into the draft's own document language, not the "
        "Vault's default — a translation exists to make one CV match one "
        'application', () async {
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'sk-ant-test');
      when(draftService.draft).thenReturn(
        draftWith(
          region: RegionProfile.dach,
          documentLanguage: DocumentLanguage.deAt,
        ),
      );
      stubPass();

      final model = CvTranslationRunDialogModel();
      await model.run();

      final captured = verify(
        translationService.runTranslationPass(
          vault: anyNamed('vault'),
          draft: anyNamed('draft'),
          targetLanguage: captureAnyNamed('targetLanguage'),
          region: anyNamed('region'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).captured.single;

      expect(captured, DocumentLanguage.deAt);
      // The language it applied under must match the one it asked for, or
      // `translatedTo` would record a lie and staleness would misreport.
      verify(
        draftService.applyCvTranslationResult(
          emptyResult,
          DocumentLanguage.deAt,
        ),
      ).called(1);
    });

    test('a failed run lands on the error phase with per-failure copy, and '
        'never applies anything', () async {
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'bad-key');
      when(
        translationService.runTranslationPass(
          vault: anyNamed('vault'),
          draft: anyNamed('draft'),
          targetLanguage: anyNamed('targetLanguage'),
          region: anyNamed('region'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenThrow(const LlmException(LlmFailure.unauthorized));

      final model = CvTranslationRunDialogModel();
      await model.run();

      expect(model.phase, CvTranslationRunPhase.error);
      expect(model.errorMessage, contains('rejected'));
      verifyNever(draftService.applyCvTranslationResult(any, any));
    });
  });
}
