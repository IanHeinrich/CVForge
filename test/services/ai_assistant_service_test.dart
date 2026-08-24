import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_usage.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/services/ai_assistant_service.dart';
import 'package:cv_forge/services/llm/ai_assistant_prompt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('AiAssistantServiceTest -', () {
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
            'publications': <String, dynamic>{},
            'skillIds': <String>[],
            'educationIds': <String>[],
            'hobbyIds': <String>[],
            'hiddenSections': <String>[],
            'rationale': 'ok',
            'keywordGaps': <String>[],
          },
          usage: LlmUsage(inputTokens: 100, outputTokens: 20),
        ),
      );

      final service = AiAssistantService();
      final result = await service.runTailoringPass(
        vault: vault,
        jobDescription: 'We need a backend engineer.',
        region: RegionProfile.uk,
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
      // The region block is appended to the base prompt, never spliced
      // into it — so the base survives verbatim as a stable prefix.
      final systemPrompt = captured[3] as String;
      expect(systemPrompt, startsWith(aiAssistantSystemPrompt));
      expect(systemPrompt, contains('UK & Ireland'));
      expect(systemPrompt, contains('British English'));
      final userContent = captured[4] as String;
      expect(userContent, contains('We need a backend engineer.'));
      expect(userContent, contains('Backend Engineer')); // the headline
      expect(userContent, isNot(contains('Should never be sent')));
      expect(userContent, isNot(contains('should-never-be-sent@example.com')));
      expect(captured[5], isA<JsonSchema>());
    });

    test('the region block follows the draft region, and closes with the '
        'clause that stops a convention becoming an invitation to '
        'invent', () {
      for (final region in RegionProfile.values) {
        final prompt = aiAssistantSystemPromptFor(region);
        final preset = region.preset;

        expect(prompt, startsWith(aiAssistantSystemPrompt));
        expect(prompt, contains(preset.displayName));
        expect(prompt, contains(preset.coverage));
        expect(prompt, contains(preset.localName));
        expect(prompt, contains(preset.spelling.promptLabel));
        expect(prompt, contains(preset.photo.promptLabel));
        expect(prompt, contains(preset.personalDetails.promptLabel));
        for (final convention in preset.conventions) {
          expect(prompt, contains(convention), reason: region.name);
        }

        // Without this the DACH/LatAm photo and date-of-birth conventions
        // read as instructions to supply what the Vault cannot hold.
        expect(
          prompt,
          contains('do not add, describe, or imply it'),
          reason: '${region.name} is missing the anti-fabrication clause',
        );
      }
    });

    test('spelling guidance is region-specific rather than boilerplate', () {
      final uk = aiAssistantSystemPromptFor(RegionProfile.uk);
      final us = aiAssistantSystemPromptFor(RegionProfile.us);

      expect(uk, contains('British English'));
      expect(uk, isNot(contains('US English')));
      expect(us, contains('US English'));
      expect(us, isNot(contains('British English')));
    });
  });
}
