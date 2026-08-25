import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/services/llm/ai_assistant_response_schema.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildAiAssistantResponseSchema -', () {
    test('the enum for a given experience is scoped to that experience\'s '
        'own bullet ids, not a flat list of every bullet in the Vault — '
        'the fix for the array-of-objects shape\'s original bug', () {
      final vault = CvVault(
        schemaVersion: 1,
        basics: ContactBasics.empty(),
        updatedAt: DateTime(2026, 1, 1),
        experiences: [
          Experience(
            id: 'exp-a',
            role: 'A',
            company: 'A',
            location: '',
            start: const YearMonth(year: 2020, month: 1),
            bullets: const [CvBullet(id: 'bullet-a1', text: 'x')],
          ),
          Experience(
            id: 'exp-b',
            role: 'B',
            company: 'B',
            location: '',
            start: const YearMonth(year: 2019, month: 1),
            bullets: const [CvBullet(id: 'bullet-b1', text: 'y')],
          ),
        ],
      );

      final schema = buildAiAssistantResponseSchema(vault) as JsonSchemaObject;
      final experiences = schema.properties['experiences'] as JsonSchemaObject;
      final expA = experiences.properties['exp-a'] as JsonSchemaObject;
      final bulletIdsSchema = expA.properties['bulletIds'] as JsonSchemaArray;
      final enumValues = (bulletIdsSchema.items as JsonSchemaStringEnum).values;

      expect(enumValues, ['bullet-a1']);
      expect(enumValues, isNot(contains('bullet-b1')));
      // Nothing is required at the experiences-object level — an omitted
      // experience id simply means "not selected".
      expect(experiences.required, isEmpty);
    });

    test('skillIds is a flat enum across every skill category', () {
      final vault = CvVault(
        schemaVersion: 1,
        basics: const ContactBasics(
          fullName: '',
          headline: '',
          email: '',
          phone: '',
          location: '',
        ),
        updatedAt: DateTime(2026, 1, 1),
        skillCategories: const [
          SkillCategory(
            id: 'cat-1',
            name: 'Languages',
            skills: [Skill(id: 'skill-1', label: 'Dart')],
          ),
          SkillCategory(
            id: 'cat-2',
            name: 'Tools',
            skills: [Skill(id: 'skill-2', label: 'Git')],
          ),
        ],
      );

      final schema = buildAiAssistantResponseSchema(vault) as JsonSchemaObject;
      final skillIds = schema.properties['skillIds'] as JsonSchemaArray;
      final values = (skillIds.items as JsonSchemaStringEnum).values;

      expect(values, ['skill-1', 'skill-2']);
    });

    test('the top-level object requires every field except headline/summary '
        '— those two stay omittable so an absent key can mean "no '
        'override" without needing a null type the schema AST doesn\'t '
        'support', () {
      final schema =
          buildAiAssistantResponseSchema(CvVault.empty()) as JsonSchemaObject;

      expect(
        schema.required,
        containsAll([
          'experiences',
          'projects',
          'skillIds',
          'education',
          'hobbyIds',
          'publications',
          'hiddenSections',
          'rationale',
          'keywordGaps',
        ]),
      );
      expect(schema.required, isNot(contains('headline')));
      expect(schema.required, isNot(contains('summary')));
    });

    test('hiddenSections enumerates every CvSectionType name', () {
      final schema =
          buildAiAssistantResponseSchema(CvVault.empty()) as JsonSchemaObject;
      final hiddenSections =
          schema.properties['hiddenSections'] as JsonSchemaArray;
      final values = (hiddenSections.items as JsonSchemaStringEnum).values;

      expect(values, contains('experience'));
      expect(values, contains('publications'));
    });
  });
}
