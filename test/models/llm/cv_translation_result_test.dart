import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/llm/cv_translation_result.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';

CvVault _vault() => CvVault(
  schemaVersion: 1,
  basics: ContactBasics.empty(),
  experiences: [
    Experience(
      id: 'exp1',
      role: 'Senior Engineer',
      company: 'Acme',
      location: 'London',
      start: const YearMonth(year: 2020, month: 3),
      isCurrent: true,
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
      skills: [
        Skill(id: 's1', label: 'Dart'),
        Skill(id: 's2', label: 'Stakeholder management'),
      ],
    ),
  ],
  education: const [
    Education(
      id: 'edu1',
      qualification: 'BSc Computing',
      institution: 'UCL',
      grade: 'First',
      details: 'Dissertation on compilers',
    ),
  ],
  hobbies: const [HobbyItem(id: 'h1', text: 'Bouldering')],
  updatedAt: DateTime(2026, 1, 1),
);

CvDraft _draft({
  List<String> experienceIds = const ['exp1'],
  Map<String, List<String>> bulletIds = const {
    'exp1': ['b1', 'b2'],
  },
  List<String> skillIds = const ['s1', 's2'],
  List<String> educationIds = const ['edu1'],
  List<String> hobbyIds = const ['h1'],
  bool hideHeadline = false,
}) => CvDraft(
  schemaVersion: 1,
  id: 'd1',
  name: 'Draft',
  templateId: 't',
  experienceIds: experienceIds,
  bulletIds: bulletIds,
  skillIds: skillIds,
  educationIds: educationIds,
  hobbyIds: hobbyIds,
  hideHeadline: hideHeadline,
  updatedAt: DateTime(2026, 1, 1),
);

void main() {
  group('CvTranslationResultTest -', () {
    test('maps every group onto its override map', () {
      final result = CvTranslationResult.fromLlmResponse(
        {
          'headline': 'Leitender Ingenieur',
          'summary': 'Zusammenfassung',
          'referencesNote': 'Referenzen',
          'roles': {'exp1': 'Leitender Ingenieur'},
          'skills': {'s2': 'Stakeholder-Management'},
          'skillCategories': {'cat1': 'Sprachen'},
          'qualifications': {'edu1': 'BSc Informatik'},
          'grades': {'edu1': 'Sehr gut'},
          'educationDetails': {'edu1': 'Abschlussarbeit'},
          'hobbies': {'h1': 'Bouldern'},
          'bullets': {'b1': 'Leitete ein Team von sechs'},
        },
        _vault(),
        _draft(),
      );

      expect(result.headline, 'Leitender Ingenieur');
      expect(result.roles['exp1'], 'Leitender Ingenieur');
      expect(result.skillLabels['s2'], 'Stakeholder-Management');
      expect(result.skillCategoryNames['cat1'], 'Sprachen');
      expect(result.educationQualifications['edu1'], 'BSc Informatik');
      expect(result.educationGrades['edu1'], 'Sehr gut');
      expect(result.educationDetails['edu1'], 'Abschlussarbeit');
      expect(result.hobbies['h1'], 'Bouldern');
      expect(result.bullets['b1'], 'Leitete ein Team von sechs');
    });

    test('drops ids the Vault has never heard of', () {
      final result = CvTranslationResult.fromLlmResponse(
        {
          'roles': {'exp1': 'Ok', 'ghost': 'Invented'},
          'bullets': {'b1': 'Ok', 'nope': 'Invented'},
        },
        _vault(),
        _draft(),
      );

      expect(result.roles.keys, ['exp1']);
      expect(result.bullets.keys, ['b1']);
    });

    test('drops ids this draft does not include, so a translation cannot '
        'reach content the CV never prints', () {
      final result = CvTranslationResult.fromLlmResponse(
        {
          'roles': {'exp1': 'Translated'},
          'hobbies': {'h1': 'Translated'},
          'bullets': {'b1': 'Translated', 'b2': 'Translated'},
        },
        _vault(),
        _draft(
          experienceIds: const [],
          bulletIds: const {
            'exp1': ['b1'],
          },
          hobbyIds: const [],
        ),
      );

      expect(result.roles, isEmpty);
      expect(result.hobbies, isEmpty);
      // b1's owning experience is deselected, so neither bullet ships.
      expect(result.bullets, isEmpty);
    });

    test('an omitted key means "leave this alone" rather than an error — the '
        'only way to say it, since JsonSchema has no null type', () {
      final result = CvTranslationResult.fromLlmResponse(
        const {},
        _vault(),
        _draft(),
      );

      expect(result.headline, isNull);
      expect(result.summary, isNull);
      expect(result.roles, isEmpty);
      expect(result.translatedCount, 0);
    });

    test('tolerates wrong types instead of throwing', () {
      final result = CvTranslationResult.fromLlmResponse(
        {
          'headline': 42,
          'roles': 'not a map',
          'bullets': {'b1': 7, 'b2': 'Fine'},
          'hobbies': {'h1': '   '},
        },
        _vault(),
        _draft(),
      );

      expect(result.headline, isNull);
      expect(result.roles, isEmpty);
      expect(result.bullets, {'b2': 'Fine'});
      expect(result.hobbies, isEmpty, reason: 'blank is not a translation');
    });

    test('ignores a headline translation when the draft hides it', () {
      final result = CvTranslationResult.fromLlmResponse(
        {'headline': 'Leitender Ingenieur'},
        _vault(),
        _draft(hideHeadline: true),
      );

      expect(result.headline, isNull);
    });

    test('counts only what actually came back translated', () {
      final result = CvTranslationResult.fromLlmResponse(
        {
          'headline': 'A',
          'roles': {'exp1': 'B'},
          'bullets': {'b1': 'C', 'b2': 'D'},
        },
        _vault(),
        _draft(),
      );

      expect(result.translatedCount, 4);
    });
  });
}
