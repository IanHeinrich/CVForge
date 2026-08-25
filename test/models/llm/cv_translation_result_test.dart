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

/// The requests a real pass would send for this Vault and draft.
List<CvTranslationPayload> _chunks({CvDraft? draft}) =>
    CvTranslationPayload.chunksFor(_vault(), draft ?? _draft());

/// The one request carrying [key] — a result is always parsed against the
/// request that asked for it, so a test answers the chunk that actually
/// contains the field it cares about.
CvTranslationPayload _chunkWith(String key, {CvDraft? draft}) =>
    _chunks(draft: draft).firstWhere((c) => c.toJson().containsKey(key));

void main() {
  group('CvTranslationResultTest - fromLlmResponse -', () {
    test("maps a request's own groups onto their override maps", () {
      final result = CvTranslationResult.fromLlmResponse({
        'roles': {'exp1': 'Leitender Ingenieur'},
        'bullets': {'b1': 'Leitete ein Team von sechs'},
      }, _chunkWith('roles'));

      expect(result.roles['exp1'], 'Leitender Ingenieur');
      expect(result.bullets['b1'], 'Leitete ein Team von sechs');
    });

    test('drops ids the request never asked about', () {
      final result = CvTranslationResult.fromLlmResponse({
        'roles': {'exp1': 'Ok', 'ghost': 'Invented'},
        'bullets': {'b1': 'Ok', 'nope': 'Invented'},
      }, _chunkWith('roles'));

      expect(result.roles.keys, ['exp1']);
      expect(result.bullets.keys, ['b1']);
    });

    test('ignores a group belonging to a different request, so an answer '
        'cannot reach past the section it was asked about', () {
      final result = CvTranslationResult.fromLlmResponse({
        'summary': 'Zusammenfassung',
        'roles': {'exp1': 'Leitender Ingenieur'},
      }, _chunkWith('summary'));

      expect(result.summary, 'Zusammenfassung');
      expect(result.roles, isEmpty, reason: 'roles belong to another chunk');
    });

    test('an omitted key means "leave this alone" rather than an error — the '
        'only way to say it, since JsonSchema has no null type', () {
      final result = CvTranslationResult.fromLlmResponse(
        const {},
        _chunkWith('summary'),
      );

      expect(result.summary, isNull);
      expect(result.headline, isNull);
      expect(result.translatedCount, 0);
    });

    test('tolerates wrong types instead of throwing', () {
      final result = CvTranslationResult.fromLlmResponse({
        'roles': 'not a map',
        'bullets': {'b1': 7, 'b2': 'Fine'},
      }, _chunkWith('roles'));

      expect(result.roles, isEmpty);
      expect(result.bullets, {'b2': 'Fine'});
    });

    test('discards a field that has swallowed the document — the failure '
        'that produced an unrenderable CV: package:pdf cannot paginate a '
        'single widget taller than a page, so one enormous summary killed '
        'the whole preview and export', () {
      final huge = List.filled(4000, 'palabra').join(' ');

      final result = CvTranslationResult.fromLlmResponse({
        'headline': 'Ingeniero Senior',
        'summary': huge,
      }, _chunkWith('summary'));

      expect(result.summary, isNull, reason: 'oversized, so not applied');
      expect(
        result.headline,
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
      }, _chunkWith('roles'));

      expect(
        result.roles['exp1'],
        'Leitender Softwareentwickler mit Sicherheitsschwerpunkt',
      );
    });

    test('keeps a value echoed back unchanged, but does not count it as a '
        'translation — every key is required now, and a term that should '
        'keep its own name is answered by returning it', () {
      final result = CvTranslationResult.fromLlmResponse({
        'skills': {'s1': 'Dart', 's2': 'Gestión de stakeholders'},
      }, _chunkWith('skills'));

      expect(
        result.skillLabels['s1'],
        'Dart',
        reason: 'stored, so replacing the map wholesale cannot lose it',
      );
      expect(result.skillLabels['s2'], 'Gestión de stakeholders');
      expect(
        result.translatedCount,
        1,
        reason: 'only the one that actually changed',
      );
    });

    test('a hidden headline is never asked about, so it cannot come back', () {
      final draft = _draft(hideHeadline: true);
      final chunk = _chunkWith('summary', draft: draft);

      expect(chunk.toJson().containsKey('headline'), isFalse);

      final result = CvTranslationResult.fromLlmResponse({
        'headline': 'Leitender Ingenieur',
      }, chunk);

      expect(result.headline, isNull);
    });
  });

  group('CvTranslationResultTest - chunking -', () {
    test('splits the CV into several requests, none of them carrying the '
        'whole document — which is what stops a model dumping the lot '
        'into one prose field', () {
      final chunks = _chunks();

      expect(chunks.length, greaterThan(1));
      for (final chunk in chunks) {
        final keys = chunk.toJson().keys;
        expect(
          keys.contains('summary') && keys.contains('roles'),
          isFalse,
          reason: 'no request mixes the summary with another section',
        );
      }
    });

    test('keeps a role and its own bullets in one request, where a '
        'wandering translation would show most', () {
      final json = _chunkWith('roles').toJson();

      expect((json['roles'] as Map).keys, contains('exp1'));
      expect((json['bullets'] as Map).keys, containsAll(['b1', 'b2']));
    });

    test('asks about every string the CV prints, exactly once', () {
      // Keyed by group *and* id: one education entry legitimately appears
      // under qualifications, grades and educationDetails alike, since
      // those are three different fields of the same entry.
      final fields = <String>[];
      for (final chunk in _chunks()) {
        chunk.toJson().forEach((group, value) {
          if (value is Map) {
            fields.addAll(value.keys.map((id) => '$group/$id'));
          } else {
            fields.add(group);
          }
        });
      }

      expect(
        fields.toSet().length,
        fields.length,
        reason: 'no field asked twice',
      );
      expect(
        fields,
        containsAll([
          'summary',
          'headline',
          'roles/exp1',
          'bullets/b1',
          'bullets/b2',
          'skills/s1',
          'skills/s2',
          'skillCategories/cat1',
          'hobbies/h1',
          'qualifications/edu1',
          'grades/edu1',
          'educationDetails/edu1',
        ]),
      );
    });
  });

  group('CvTranslationResultTest - merge -', () {
    test('combines every request into one result and totals what was '
        'asked', () {
      final parts = [
        CvTranslationResult.fromLlmResponse({
          'summary': 'Zusammenfassung',
        }, _chunkWith('summary')),
        CvTranslationResult.fromLlmResponse({
          'roles': {'exp1': 'Leitender Ingenieur'},
        }, _chunkWith('roles')),
      ];

      final merged = CvTranslationResult.merge(parts);

      expect(merged.summary, 'Zusammenfassung');
      expect(merged.roles['exp1'], 'Leitender Ingenieur');
      expect(merged.translatedCount, 2);
      expect(
        merged.requestedCount,
        parts.fold<int>(0, (total, part) => total + part.requestedCount),
      );
    });

    test('merging nothing is an empty result rather than a crash — a CV '
        'with nothing to translate sends no requests at all', () {
      final merged = CvTranslationResult.merge(const []);

      expect(merged.translatedCount, 0);
      expect(merged.requestedCount, 0);
      expect(merged.roles, isEmpty);
    });
  });
}
