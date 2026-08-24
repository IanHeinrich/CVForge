import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/ai_assistant_run/ai_assistant_run_dialog_model.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('AiAssistantRunDialogModel Tests -', () {
    late MockSettingsService settingsService;
    late MockVaultService vaultService;
    late MockDraftService draftService;
    late MockAiAssistantService aiAssistantService;

    final vault = CvVault(
      schemaVersion: 1,
      basics: ContactBasics.empty(),
      updatedAt: DateTime(2026, 1, 1),
    );

    const emptyResult = AiAssistantResult(
      experienceIds: [],
      bulletIds: {},
      projectIds: [],
      projectBulletIds: {},
      publicationIds: [],
      publicationBulletIds: {},
      bulletOverrides: {},
      skillIds: [],
      educationIds: [],
      hobbyIds: [],
      hiddenSections: {CvSectionType.hobbies},
      rationale: 'Kept the relevant bits.',
      keywordGaps: ['Kubernetes'],
    );

    setUp(() {
      registerServices();
      settingsService = getAndRegisterSettingsService();
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      aiAssistantService = getAndRegisterAiAssistantService();
      when(settingsService.settings).thenReturn(
        AppSettings.empty().copyWith(
          preferences: CvPreferences.empty().copyWith(
            aiAssistantProviderId: 'anthropic',
            aiAssistantModelId: 'claude-sonnet-5',
          ),
        ),
      );
      when(vaultService.vault).thenReturn(vault);
    });
    tearDown(() => locator.reset());

    test('starts in the confirm phase', () {
      final model = AiAssistantRunDialogModel(jobDescription: 'We need a dev');

      expect(model.phase, AiAssistantRunPhase.confirm);
      expect(model.providerDisplayName, 'Claude');
    });

    test('run() resolves the provider/model/key from Settings, applies the '
        'result via DraftService, and lands on the result phase', () async {
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'sk-ant-test');
      when(
        aiAssistantService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenAnswer((_) async => emptyResult);
      when(
        draftService.applyAiAssistantResult(emptyResult),
      ).thenAnswer((_) async {});

      final model = AiAssistantRunDialogModel(jobDescription: 'We need a dev');
      await model.run();

      expect(model.phase, AiAssistantRunPhase.result);
      expect(model.result, emptyResult);
      verify(
        aiAssistantService.runTailoringPass(
          vault: vault,
          jobDescription: 'We need a dev',
          providerId: 'anthropic',
          modelId: 'claude-sonnet-5',
          apiKey: 'sk-ant-test',
        ),
      ).called(1);
      verify(draftService.applyAiAssistantResult(emptyResult)).called(1);
    });

    test('a stale stored model id falls back to the provider\'s first '
        'model, same as SettingsViewModel.selectedAiAssistantModel', () async {
      when(settingsService.settings).thenReturn(
        AppSettings.empty().copyWith(
          preferences: CvPreferences.empty().copyWith(
            aiAssistantProviderId: 'anthropic',
            aiAssistantModelId: 'not-a-real-model',
          ),
        ),
      );
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'sk-ant-test');
      when(
        aiAssistantService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: captureAnyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenAnswer((_) async => emptyResult);
      when(
        draftService.applyAiAssistantResult(emptyResult),
      ).thenAnswer((_) async {});

      final model = AiAssistantRunDialogModel(jobDescription: 'x');
      await model.run();

      final captured = verify(
        aiAssistantService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: captureAnyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).captured;
      expect(captured.single, isNot('not-a-real-model'));
    });

    test('a failed run lands on the error phase with per-failure copy, and '
        'never applies anything', () async {
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'bad-key');
      when(
        aiAssistantService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenThrow(const LlmException(LlmFailure.unauthorized));

      final model = AiAssistantRunDialogModel(jobDescription: 'x');
      await model.run();

      expect(model.phase, AiAssistantRunPhase.error);
      expect(model.errorMessage, contains('rejected'));
      verifyNever(draftService.applyAiAssistantResult(any));
    });
  });
}
