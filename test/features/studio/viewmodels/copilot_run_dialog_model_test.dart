import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/copilot_run/copilot_run_dialog_model.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/copilot_result.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('CopilotRunDialogModel Tests -', () {
    late MockSettingsService settingsService;
    late MockVaultService vaultService;
    late MockDraftService draftService;
    late MockCopilotService copilotService;

    final vault = CvVault(
      schemaVersion: 1,
      basics: ContactBasics.empty(),
      updatedAt: DateTime(2026, 1, 1),
    );

    const emptyResult = CopilotResult(
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
      copilotService = getAndRegisterCopilotService();
      when(settingsService.settings).thenReturn(
        AppSettings.empty().copyWith(
          copilotProviderId: 'anthropic',
          copilotModelId: 'claude-sonnet-5',
        ),
      );
      when(vaultService.vault).thenReturn(vault);
    });
    tearDown(() => locator.reset());

    test('starts in the confirm phase', () {
      final model = CopilotRunDialogModel(jobDescription: 'We need a dev');

      expect(model.phase, CopilotRunPhase.confirm);
      expect(model.providerDisplayName, 'Anthropic');
    });

    test('run() resolves the provider/model/key from Settings, applies the '
        'result via DraftService, and lands on the result phase', () async {
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'sk-ant-test');
      when(
        copilotService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenAnswer((_) async => emptyResult);
      when(
        draftService.applyCopilotResult(emptyResult),
      ).thenAnswer((_) async {});

      final model = CopilotRunDialogModel(jobDescription: 'We need a dev');
      await model.run();

      expect(model.phase, CopilotRunPhase.result);
      expect(model.result, emptyResult);
      verify(
        copilotService.runTailoringPass(
          vault: vault,
          jobDescription: 'We need a dev',
          providerId: 'anthropic',
          modelId: 'claude-sonnet-5',
          apiKey: 'sk-ant-test',
        ),
      ).called(1);
      verify(draftService.applyCopilotResult(emptyResult)).called(1);
    });

    test('a stale stored model id falls back to the provider\'s first '
        'model, same as SettingsViewModel.selectedCopilotModel', () async {
      when(settingsService.settings).thenReturn(
        AppSettings.empty().copyWith(
          copilotProviderId: 'anthropic',
          copilotModelId: 'not-a-real-model',
        ),
      );
      when(
        settingsService.apiKeyFor('anthropic'),
      ).thenAnswer((_) async => 'sk-ant-test');
      when(
        copilotService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: captureAnyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenAnswer((_) async => emptyResult);
      when(
        draftService.applyCopilotResult(emptyResult),
      ).thenAnswer((_) async {});

      final model = CopilotRunDialogModel(jobDescription: 'x');
      await model.run();

      final captured = verify(
        copilotService.runTailoringPass(
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
        copilotService.runTailoringPass(
          vault: anyNamed('vault'),
          jobDescription: anyNamed('jobDescription'),
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
        ),
      ).thenThrow(const LlmException(LlmFailure.unauthorized));

      final model = CopilotRunDialogModel(jobDescription: 'x');
      await model.run();

      expect(model.phase, CopilotRunPhase.error);
      expect(model.errorMessage, contains('rejected'));
      verifyNever(draftService.applyCopilotResult(any));
    });
  });
}
