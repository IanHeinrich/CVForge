import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/document/document_strings.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_usage.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/cv_translation_service.dart';
import 'package:cv_forge/services/llm/cv_translation_prompt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';

const _fullName = 'Ada Lovelace';
const _email = 'ada@example.com';
const _phone = '+44 7700 900000';

CvVault _vault() => CvVault(
  schemaVersion: 1,
  basics: ContactBasics.empty().copyWith(
    fullName: _fullName,
    email: _email,
    phone: _phone,
    headline: 'Senior Engineer',
  ),
  experiences: [
    Experience(
      id: 'exp1',
      role: 'Senior Engineer',
      company: 'Acme',
      location: 'London',
      start: const YearMonth(year: 2020, month: 3),
      isCurrent: true,
      bullets: const [CvBullet(id: 'b1', text: 'Led a team of six')],
    ),
  ],
  updatedAt: DateTime(2026, 1, 1),
);

CvDraft _draft() => CvDraft(
  schemaVersion: 1,
  id: 'd1',
  name: 'Draft',
  templateId: 't',
  experienceIds: const ['exp1'],
  bulletIds: const {
    'exp1': ['b1'],
  },
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  group('CvTranslationServiceTest -', () {
    setUp(registerServices);
    tearDown(locator.reset);

    /// Runs a pass and returns every captured call, since a CV is now
    /// translated as several requests rather than one.
    Future<({List<String> prompts, String userContent})> runAndCapture({
      DocumentLanguage language = DocumentLanguage.de,
      RegionProfile region = RegionProfile.uk,
    }) async {
      final llm = getAndRegisterLlmService();
      when(
        llm.completeJson(
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
          systemPrompt: anyNamed('systemPrompt'),
          userContent: anyNamed('userContent'),
          schema: anyNamed('schema'),
        ),
      ).thenAnswer(
        (_) async => const LlmJsonResponse(
          data: {},
          usage: LlmUsage(inputTokens: 1, outputTokens: 1),
        ),
      );

      await CvTranslationService().runTranslationPass(
        vault: _vault(),
        draft: _draft(),
        targetLanguage: language,
        region: region,
        providerId: 'anthropic',
        modelId: 'claude-opus-5',
        apiKey: 'key',
      );

      final captured = verify(
        llm.completeJson(
          providerId: anyNamed('providerId'),
          modelId: anyNamed('modelId'),
          apiKey: anyNamed('apiKey'),
          systemPrompt: captureAnyNamed('systemPrompt'),
          userContent: captureAnyNamed('userContent'),
          schema: anyNamed('schema'),
        ),
      ).captured;

      // Captures interleave as [prompt, content, prompt, content, ...].
      final prompts = <String>[];
      final contents = <String>[];
      for (var i = 0; i < captured.length; i += 2) {
        prompts.add(captured[i] as String);
        contents.add(captured[i + 1] as String);
      }
      return (prompts: prompts, userContent: contents.join(' '));
    }

    test('keeps the base prompt as a verbatim prefix, so the region and '
        'language block is a testable delta', () async {
      final captured = await runAndCapture();
      expect(captured.prompts, isNotEmpty);
      for (final prompt in captured.prompts) {
        expect(prompt, startsWith(cvTranslationSystemPrompt));
      }
    });

    test('names the target language in the prompt', () async {
      final captured = await runAndCapture(language: DocumentLanguage.de);
      expect(
        captured.prompts.first,
        contains(DocumentLanguage.de.strings.promptName),
      );
    });

    test(
      'omits the region spelling note for a non-English target — "write '
      'in German" and "British spelling" in one prompt is incoherent',
      () async {
        final captured = await runAndCapture(
          language: DocumentLanguage.de,
          region: RegionProfile.uk,
        );
        expect(
          captured.prompts.first,
          isNot(contains(RegionProfile.uk.preset.spelling.promptLabel)),
        );
      },
    );

    test('keeps the region spelling note when the target is English', () async {
      final captured = await runAndCapture(
        language: DocumentLanguage.enGb,
        region: RegionProfile.uk,
      );
      expect(
        captured.prompts.first,
        contains(RegionProfile.uk.preset.spelling.promptLabel),
      );
    });

    test('never sends identifying details — the same PII policy the '
        'tailoring payload enforces', () async {
      final captured = await runAndCapture();
      final userContent = captured.userContent;
      expect(userContent, isNot(contains(_fullName)));
      expect(userContent, isNot(contains(_email)));
      expect(userContent, isNot(contains(_phone)));
    });

    test('never sends a field that must survive translation untouched, so '
        'it cannot come back translated', () async {
      final captured = await runAndCapture();
      final userContent = captured.userContent;
      expect(userContent, isNot(contains('Acme')));
      expect(userContent, isNot(contains('London')));
    });

    test('sends the text the CV actually prints', () async {
      final captured = await runAndCapture();
      final userContent = captured.userContent;
      expect(userContent, contains('Led a team of six'));
      expect(userContent, contains('Senior Engineer'));
    });
  });
}
