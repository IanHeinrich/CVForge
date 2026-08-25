import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/llm/cv_translation_payload.dart';
import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/llm/cv_translation_response_schema.dart';
import 'package:flutter_test/flutter_test.dart';

CvVault _vault() => CvVault(
  schemaVersion: 1,
  basics: ContactBasics.empty().copyWith(
    headline: 'Senior Engineer',
    summary: 'Backend engineer with ten years of experience.',
  ),
  experiences: [
    Experience(
      id: 'exp1',
      role: 'Senior Engineer',
      company: 'Acme',
      location: 'London',
      start: const YearMonth(year: 2020, month: 3),
      bullets: const [
        CvBullet(id: 'b1', text: 'Led a team of six'),
        CvBullet(id: 'b2', text: 'Cut latency by 40%'),
      ],
    ),
  ],
  skillCategories: const [
    SkillCategory(
      id: 'cat1',
      name: 'Languages',
      skills: [Skill(id: 's1', label: 'Dart')],
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
    'exp1': ['b1', 'b2'],
  },
  skillIds: const ['s1'],
  updatedAt: DateTime(2026, 1, 1),
);

/// The one request carrying [key].
CvTranslationPayload _chunkWith(String key) => CvTranslationPayload.chunksFor(
  _vault(),
  _draft(),
).firstWhere((c) => c.toJson().containsKey(key));

void main() {
  group('buildCvTranslationResponseSchema -', () {
    test('requires every key it asks about, at both levels — an optional '
        'key is one the model may decline to fill, which is what produced '
        'a first pass that translated part of a CV and a second that '
        'finished the job', () {
      final schema =
          buildCvTranslationResponseSchema(_chunkWith('roles'))
              as JsonSchemaObject;

      expect(schema.required, unorderedEquals(schema.properties.keys));
      expect(schema.required, containsAll(['roles', 'bullets']));

      final bullets = schema.properties['bullets']! as JsonSchemaObject;
      expect(
        bullets.required,
        unorderedEquals(['b1', 'b2']),
        reason: 'every bullet the request sent must come back',
      );
    });

    test('asks only about the ids in its own request, so an answer cannot '
        'reach past the section it was given', () {
      final schema =
          buildCvTranslationResponseSchema(_chunkWith('summary'))
              as JsonSchemaObject;

      expect(schema.properties.keys, unorderedEquals(['headline', 'summary']));
    });

    test('leaves out a group the request has nothing in, rather than '
        'requiring an empty object', () {
      final schema =
          buildCvTranslationResponseSchema(_chunkWith('skills'))
              as JsonSchemaObject;

      expect(schema.properties.containsKey('roles'), isFalse);
      expect(schema.properties.containsKey('skills'), isTrue);
    });
  });
}
