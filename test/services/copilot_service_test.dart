import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_usage.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/services/copilot_service.dart';
import 'package:cv_forge/services/llm/copilot_prompt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CopilotServiceTest -', () {
    late MockLlmService llmService;

    setUp(() {
      registerServices();
      llmService = getAndRegisterLlmService();
    });
    tearDown(() => locator.reset());

    final vault = CvVault(
      schemaVersion: 1,
      basics: const ContactBasics(
        fullName: 'Should never be sent',
        headline: 'Backend Engineer',
        email: 'should-never-be-sent@example.com',
        phone: '000',
        location: 'Nowhere',
      ),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('sends the system prompt, a PII-stripped user payload, and a '
        'schema built from the Vault, then parses the response against '
        'that same Vault', () async {
      when(
        llmService.completeJson(
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
          systemPrompt: anyNamed('systemPrompt'),
          userContent: anyNamed('userContent'),
          schema: anyNamed('schema'),
        ),
      ).thenAnswer(
        (_) async => const LlmJsonResponse(
          data: {
            'headline': 'Senior Backend Engineer',
            'experiences': <String, dynamic>{},
            'projects': <String, dynamic>{},
            'skillIds': <String>[],
            'educationIds': <String>[],
            'hobbyIds': <String>[],
            'publicationIds': <String>[],
            'hiddenSections': <String>[],
            'rationale': 'ok',
            'keywordGaps': <String>[],
          },
          usage: LlmUsage(inputTokens: 100, outputTokens: 20),
        ),
      );

      final service = CopilotService();
      final result = await service.runTailoringPass(
        vault: vault,
        jobDescription: 'We need a backend engineer.',
        providerId: 'anthropic',
        modelId: 'claude-sonnet-5',
        apiKey: 'sk-test',
      );

      expect(result.headline, 'Senior Backend Engineer');
      expect(result.rationale, 'ok');

      final call = verify(
        llmService.completeJson(
          providerId: captureAnyNamed('providerId'),
          modelId: captureAnyNamed('modelId'),
          apiKey: captureAnyNamed('apiKey'),
          systemPrompt: captureAnyNamed('systemPrompt'),
          userContent: captureAnyNamed('userContent'),
          schema: captureAnyNamed('schema'),
        ),
      )..called(1);
      final captured = call.captured;
      expect(captured[0], 'anthropic');
      expect(captured[1], 'claude-sonnet-5');
      expect(captured[2], 'sk-test');
      expect(captured[3], copilotSystemPrompt);
      final userContent = captured[4] as String;
      expect(userContent, contains('We need a backend engineer.'));
      expect(userContent, contains('Backend Engineer')); // the headline
      expect(userContent, isNot(contains('Should never be sent')));
      expect(userContent, isNot(contains('should-never-be-sent@example.com')));
      expect(captured[5], isA<JsonSchema>());
    });
  });
}
