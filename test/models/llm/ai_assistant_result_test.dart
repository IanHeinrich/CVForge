import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
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
    Education(
      id: 'edu-1',
      qualification: 'BSc',
      institution: 'Uni',
      bullets: [
        CvBullet(id: 'ebullet-a1', text: 'Dissertation on a thing'),
        CvBullet(id: 'ebullet-a2', text: 'Society committee'),
      ],
    ),
  ],
  hobbies: const [HobbyItem(id: 'hobby-1', text: 'Climbing')],
  publications: const [
    Publication(
      id: 'pub-1',
      title: 'A paper',
      bullets: [CvBullet(id: 'ubullet-a1', text: 'Cited widely')],
    ),
  ],
);

void main() {
  group('AiAssistantResult.fromLlmResponse -', () {
    late CvVault vault;

    setUp(() => vault = _fixtureVault());

    test('a fully valid response is applied as-is', () {
      final result = AiAssistantResult.fromLlmResponse({
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
        'publications': {
          'pub-1': {
            'bulletIds': ['ubullet-a1'],
            'rewrites': <Map<String, dynamic>>[],
          },
        },
        'skillIds': ['skill-1'],
        'education': {
          'edu-1': {
            'bulletIds': ['ebullet-a1'],
            'rewrites': [
              {'id': 'ebullet-a1', 'text': 'Rewritten education bullet'},
            ],
          },
        },
        'hobbyIds': ['hobby-1'],
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
      expect(result.bulletOverrides, {
        'bullet-a1': 'Rewritten bullet',
        'ebullet-a1': 'Rewritten education bullet',
      });
      expect(result.projectIds, ['proj-a']);
      expect(result.projectBulletIds, {
        'proj-a': ['pbullet-a1'],
      });
      expect(result.publicationIds, ['pub-1']);
      expect(result.publicationBulletIds, {
        'pub-1': ['ubullet-a1'],
      });
      expect(result.skillIds, ['skill-1']);
      expect(result.educationIds, ['edu-1']);
      expect(result.educationBulletIds, {
        'edu-1': ['ebullet-a1'],
      });
      expect(result.hobbyIds, ['hobby-1']);
      expect(result.hiddenSections, {CvSectionType.hobbies});
      expect(result.rationale, 'Kept the relevant bits.');
      expect(result.keywordGaps, ['Kubernetes']);
    });

    test('an experience id that does not exist in the Vault is dropped', () {
      final result = AiAssistantResult.fromLlmResponse({
        'experiences': {
          'exp-hallucinated': {
            'bulletIds': ['bullet-a1'],
            'rewrites': <Map<String, dynamic>>[],
          },
        },
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
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
      final result = AiAssistantResult.fromLlmResponse({
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
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.bulletIds['exp-a'], ['bullet-a1']);
      expect(result.bulletOverrides.containsKey('bullet-b1'), isFalse);
    });

    test('a bullet id belonging to a different entity is dropped from a '
        'publication too, not just experiences/projects', () {
      final result = AiAssistantResult.fromLlmResponse({
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'publications': {
          'pub-1': {
            // bullet-a1 belongs to an experience, not this publication.
            'bulletIds': ['ubullet-a1', 'bullet-a1'],
            'rewrites': [
              {'id': 'bullet-a1', 'text': 'Should not apply'},
            ],
          },
        },
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.publicationIds, ['pub-1']);
      expect(result.publicationBulletIds['pub-1'], ['ubullet-a1']);
      expect(result.bulletOverrides.containsKey('bullet-a1'), isFalse);
    });

    test('unknown skill/education/hobby ids are dropped', () {
      final result = AiAssistantResult.fromLlmResponse({
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': ['skill-1', 'skill-hallucinated'],
        'education': {
          'edu-hallucinated': {
            'bulletIds': <String>[],
            'rewrites': <Map<String, dynamic>>[],
          },
        },
        'hobbyIds': ['hobby-hallucinated'],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.skillIds, ['skill-1']);
      expect(result.educationIds, isEmpty);
      expect(result.hobbyIds, isEmpty);
    });

    test('a publications entry keyed by an id not in the Vault is ignored, '
        'not a crash', () {
      final result = AiAssistantResult.fromLlmResponse({
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'publications': {
          'pub-hallucinated': {
            'bulletIds': ['ubullet-a1'],
            'rewrites': <Map<String, dynamic>>[],
          },
        },
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.publicationIds, isEmpty);
      expect(result.publicationBulletIds, isEmpty);
    });

    test('an invalid hiddenSections name is dropped rather than throwing', () {
      final result = AiAssistantResult.fromLlmResponse({
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': ['hobbies', 'not_a_real_section'],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.hiddenSections, {CvSectionType.hobbies});
    });

    test('wrong-typed fields are treated as absent rather than crashing', () {
      final result = AiAssistantResult.fromLlmResponse({
        'headline': 42, // not a string
        'experiences': 'not a map',
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': 'not a list',
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
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
      final result = AiAssistantResult.fromLlmResponse({
        'experiences': {
          'exp-a': {'bulletIds': <String>[], 'rewrites': <String>[]},
        },
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.experienceIds, ['exp-a']);
      expect(result.bulletIds['exp-a'], isEmpty);
    });

    test('discards a field big enough to break rendering, and keeps its '
        'sane siblings — package:pdf cannot paginate a single text widget, '
        'so one runaway value would take out the preview and the export '
        'together', () {
      final huge = List.filled(4000, 'word').join(' ');

      final result = AiAssistantResult.fromLlmResponse({
        'headline': 'Backend Engineer',
        'summary': huge,
        'experiences': {
          'exp-a': {
            'bulletIds': ['bullet-a1', 'bullet-a2'],
            'rewrites': [
              {'id': 'bullet-a1', 'text': huge},
              {'id': 'bullet-a2', 'text': 'Shipped the other thing'},
            ],
          },
        },
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.summary, isNull, reason: 'oversized, so not applied');
      expect(result.bulletOverrides.containsKey('bullet-a1'), isFalse);
      expect(result.headline, 'Backend Engineer');
      expect(result.bulletOverrides['bullet-a2'], 'Shipped the other thing');
      expect(
        result.bulletIds['exp-a'],
        ['bullet-a1', 'bullet-a2'],
        reason:
            'a rejected rewrite drops the new text, not the bullet — '
            'it keeps saying what the Vault says',
      );
    });

    test('a tailored summary many times longer than the source is kept — '
        'unlike a translation, a rewrite has no length relationship to its '
        'source, so only the page bounds it', () {
      final expanded = List.filled(120, 'word').join(' ');

      final result = AiAssistantResult.fromLlmResponse({
        'summary': expanded,
        'experiences': <String, dynamic>{},
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.summary, expanded);
    });

    test('an empty rewrite is not applied — it would blank the line rather '
        'than tailor it, and leaving the original is the better failure', () {
      final result = AiAssistantResult.fromLlmResponse({
        'summary': '',
        'experiences': {
          'exp-a': {
            'bulletIds': ['bullet-a1'],
            'rewrites': [
              {'id': 'bullet-a1', 'text': '   '},
            ],
          },
        },
        'projects': <String, dynamic>{},
        'publications': <String, dynamic>{},
        'skillIds': <String>[],
        'education': <String, dynamic>{},
        'hobbyIds': <String>[],
        'hiddenSections': <String>[],
        'rationale': '',
        'keywordGaps': <String>[],
      }, vault);

      expect(result.summary, isNull);
      expect(result.bulletOverrides, isEmpty);
    });
  });
}
