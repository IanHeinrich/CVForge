import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/llm/cv_translation_payload.dart';
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

CvTranslationPayload _payload({CvVault? vault, CvDraft? draft}) =>
    CvTranslationPayload.from(vault ?? _vault(), draft ?? _draft());

void main() {
  group('CvTranslationResultTest -', () {
    test('maps every group onto its override map', () {
      final result = CvTranslationResult.fromLlmResponse({
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
      }, _payload());

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
      final result = CvTranslationResult.fromLlmResponse({
        'roles': {'exp1': 'Ok', 'ghost': 'Invented'},
        'bullets': {'b1': 'Ok', 'nope': 'Invented'},
      }, _payload());

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
        _payload(
          draft: _draft(
            experienceIds: const [],
            bulletIds: const {
              'exp1': ['b1'],
            },
            hobbyIds: const [],
          ),
        ),
      );

      expect(result.roles, isEmpty);
      expect(result.hobbies, isEmpty);
      // b1's owning experience is deselected, so neither bullet ships.
      expect(result.bullets, isEmpty);
    });

    test('an omitted key means "leave this alone" rather than an error — the '
        'only way to say it, since JsonSchema has no null type', () {
      final result = CvTranslationResult.fromLlmResponse(const {}, _payload());

      expect(result.headline, isNull);
      expect(result.summary, isNull);
      expect(result.roles, isEmpty);
      expect(result.translatedCount, 0);
    });

    test('tolerates wrong types instead of throwing', () {
      final result = CvTranslationResult.fromLlmResponse({
        'headline': 42,
        'roles': 'not a map',
        'bullets': {'b1': 7, 'b2': 'Fine'},
        'hobbies': {'h1': '   '},
      }, _payload());

      expect(result.headline, isNull);
      expect(result.roles, isEmpty);
      expect(result.bullets, {'b2': 'Fine'});
      expect(result.hobbies, isEmpty, reason: 'blank is not a translation');
    });

    test('ignores a headline translation when the draft hides it', () {
      final result = CvTranslationResult.fromLlmResponse({
        'headline': 'Leitender Ingenieur',
      }, _payload(draft: _draft(hideHeadline: true)));

      expect(result.headline, isNull);
    });

    test('discards a field that has swallowed the document — the failure '
        'that produced an unrenderable CV: package:pdf cannot paginate a '
        'single widget taller than a page, so one enormous summary killed '
        'the whole preview and export', () {
      final huge = List.generate(4000, (i) => 'palabra$i').join(' ');

      final result = CvTranslationResult.fromLlmResponse({
        'summary': huge,
        'roles': {'exp1': 'Ingeniero Senior'},
      }, _payload());

      expect(result.summary, isNull, reason: 'oversized, so not applied');
      expect(
        result.roles['exp1'],
        'Ingeniero Senior',
        reason: 'a sane sibling field still lands',
      );
    });

    test('accepts a translation that is legitimately longer than its '
        'source — German and Spanish both run long, and the guard exists '
        'to catch a swallowed document, not to police length', () {
      final result = CvTranslationResult.fromLlmResponse({
        'roles': {
          'exp1': 'Leitender Softwareentwickler mit Sicherheitsschwerpunkt',
        },
      }, _payload());

      expect(
        result.roles['exp1'],
        'Leitender Softwareentwickler mit Sicherheitsschwerpunkt',
      );
    });

    test('ignores a field the request never asked about, so a response '
        'cannot introduce content the CV does not print', () {
      final result = CvTranslationResult.fromLlmResponse({
        'referencesNote': 'Referencias disponibles',
      }, _payload());

      expect(result.referencesNote, isNull);
    });

    test('reports how many strings were asked about, so a partial pass '
        'reads as partial rather than as success', () {
      final result = CvTranslationResult.fromLlmResponse({
        'roles': {'exp1': 'Ingeniero Senior'},
      }, _payload());

      expect(result.translatedCount, 1);
      expect(result.requestedCount, greaterThan(1));
    });

    test('counts only what actually came back translated', () {
      final result = CvTranslationResult.fromLlmResponse({
        'headline': 'A',
        'roles': {'exp1': 'B'},
        'bullets': {'b1': 'C', 'b2': 'D'},
      }, _payload());

      expect(result.translatedCount, 4);
    });
  });
}
