import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/copilot_result.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';

CvVault _fixtureVault() => CvVault(
  schemaVersion: 1,
  basics: ContactBasics.empty(),
  updatedAt: DateTime(2026, 1, 1),
  experiences: [
    Experience(
      id: 'exp-a',
      role: 'Backend Engineer',
      company: 'Acme',
      location: 'Remote',
      start: const YearMonth(year: 2020, month: 1),
      bullets: const [
        CvBullet(id: 'bullet-a1', text: 'Shipped a thing'),
        CvBullet(id: 'bullet-a2', text: 'Shipped another thing'),
      ],
    ),
    Experience(
      id: 'exp-b',
      role: 'Junior Dev',
      company: 'Old Co',
      location: 'Remote',
      start: const YearMonth(year: 2018, month: 1),
      bullets: const [CvBullet(id: 'bullet-b1', text: 'Learned things')],
    ),
  ],
  projects: const [
    Project(
      id: 'proj-a',
      title: 'Side Project',
      bullets: [CvBullet(id: 'pbullet-a1', text: 'Built a thing')],
    ),
  ],
  skillCategories: const [
    SkillCategory(
      id: 'cat-1',
      name: 'Languages',
      skills: [Skill(id: 'skill-1', label: 'Dart')],
    ),
  ],
  education: const [
    Education(id: 'edu-1', qualification: 'BSc', institution: 'Uni'),
  ],
  hobbies: const [HobbyItem(id: 'hobby-1', text: 'Climbing')],
  publications: const [Publication(id: 'pub-1', title: 'A paper')],
);

void main() {
  group('CopilotResult.fromLlmResponse -', () {
    late CvVault vault;

    setUp(() => vault = _fixtureVault());

    test('a fully valid response is applied as-is', () {
      final result = CopilotResult.fromLlmResponse({
        'headline': 'Senior Backend Engineer',
        'summary': 'Tailored.',
        'experiences': {
          'exp-a': {
            'bulletIds': ['bullet-a1'],
            'rewrites': [
              {'id': 'bullet-a1', 'text': 'Rewritten bullet'},
            ],
          },
        },
        'projects': {
          'proj-a': {
            'bulletIds': ['pbullet-a1'],
            'rewrites': <Map<String, dynamic>>[],
          },
        },
        'skillIds': ['skill-1'],
        'educationIds': ['edu-1'],
        'hobbyIds': ['hobby-1'],
        'publicationIds': ['pub-1'],
        'hiddenSections': ['hobbies'],
        'rationale': 'Kept the relevant bits.',
        'keywordGaps': ['Kubernetes'],
      }, vault);

      expect(result.headline, 'Senior Backend Engineer');
      expect(result.summary, 'Tailored.');
      expect(result.experienceIds, ['exp-a']);
      expect(result.bulletIds, {
        'exp-a': ['bullet-a1'],
      });
      expect(result.bulletOverrides, {'bullet-a1': 'Rewritten bullet'});
      expect(result.projectIds, ['proj-a']);
      expect(result.projectBulletIds, {
        'proj-a': ['pbullet-a1'],
      });
      expect(result.skillIds, ['skill-1']);
      expect(result.educationIds, ['edu-1']);
      expect(result.hobbyIds, ['hobby-1']);
      expect(result.publicationIds, ['pub-1']);
      expect(result.hiddenSections, {CvSectionType.hobbies});
      expect(result.rationale, 'Kept the relevant bits.');
      expect(result.keywordGaps, ['Kubernetes']);
    });

    test('an experience id that does not exist in the Vault is dropped', () {
      final result = CopilotResult.fromLlmResponse({
        'experiences': {
          'exp-hallucinated': {
            'bulletIds': ['bullet-a1'],
            'rewrites': <Map<String, dynamic>>[],
          },
        },
        'projects': <String, dynamic>{},
        'skillIds': <String>[],
        'educationIds': <String>[],
        'hobbyIds': <String>[],
        'publicationIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.experienceIds, isEmpty);
      expect(result.bulletIds, isEmpty);
    });

    test('a bullet id belonging to a different experience is dropped, not '
        'attached to the wrong one — the exact class of error the '
        'per-entry enum scoping exists to prevent', () {
      final result = CopilotResult.fromLlmResponse({
        'experiences': {
          'exp-a': {
            // bullet-b1 belongs to exp-b, not exp-a.
            'bulletIds': ['bullet-a1', 'bullet-b1'],
            'rewrites': [
              {'id': 'bullet-b1', 'text': 'Should not apply'},
            ],
          },
        },
        'projects': <String, dynamic>{},
        'skillIds': <String>[],
        'educationIds': <String>[],
        'hobbyIds': <String>[],
        'publicationIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.bulletIds['exp-a'], ['bullet-a1']);
      expect(result.bulletOverrides.containsKey('bullet-b1'), isFalse);
    });

    test('unknown skill/education/hobby/publication ids are dropped', () {
      final result = CopilotResult.fromLlmResponse({
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'skillIds': ['skill-1', 'skill-hallucinated'],
        'educationIds': ['edu-hallucinated'],
        'hobbyIds': ['hobby-hallucinated'],
        'publicationIds': ['pub-hallucinated'],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.skillIds, ['skill-1']);
      expect(result.educationIds, isEmpty);
      expect(result.hobbyIds, isEmpty);
      expect(result.publicationIds, isEmpty);
    });

    test('an invalid hiddenSections name is dropped rather than throwing', () {
      final result = CopilotResult.fromLlmResponse({
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'skillIds': <String>[],
        'educationIds': <String>[],
        'hobbyIds': <String>[],
        'publicationIds': <String>[],
        'hiddenSections': ['hobbies', 'not_a_real_section'],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.hiddenSections, {CvSectionType.hobbies});
    });

    test('wrong-typed fields are treated as absent rather than crashing', () {
      final result = CopilotResult.fromLlmResponse({
        'headline': 42, // not a string
        'experiences': 'not a map',
        'projects': <String, dynamic>{},
        'skillIds': 'not a list',
        'educationIds': <String>[],
        'hobbyIds': <String>[],
        'publicationIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': 7,
        'keywordGaps': [1, 'a real gap', null],
      }, vault);

      expect(result.headline, isNull);
      expect(result.experienceIds, isEmpty);
      expect(result.skillIds, isEmpty);
      expect(result.rationale, '');
      expect(result.keywordGaps, ['a real gap']);
    });

    test('an experience key present with an empty bulletIds selection is '
        'still "included", matching CvDraft.bulletIds\' own '
        'key-exists-means-included convention', () {
      final result = CopilotResult.fromLlmResponse({
        'experiences': {
          'exp-a': {'bulletIds': <String>[], 'rewrites': <String>[]},
        },
        'projects': <String, dynamic>{},
        'skillIds': <String>[],
        'educationIds': <String>[],
        'hobbyIds': <String>[],
        'publicationIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.experienceIds, ['exp-a']);
      expect(result.bulletIds['exp-a'], isEmpty);
    });
  });
}
