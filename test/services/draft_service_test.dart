import 'dart:convert';

import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/models/draft/text_override_field.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/models/llm/ai_assistant_result.dart';
import 'package:cv_forge/models/llm/cv_translation_result.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('DraftServiceTest -', () {
    late MockLocalStorageService storage;
    late Map<String, String> memory;
    late MockSettingsService settings;

    setUp(() {
      storage = getAndRegisterLocalStorageService();
      memory = stubInMemoryStorage(storage);
      // DraftService resolves this for real (not mocked) to stamp a
      // genuinely registered template id on every seeded/migrated draft —
      // see CvDraft.empty's doc comment.
      locator.registerLazySingleton<TemplateRegistryService>(
        TemplateRegistryService.new,
      );
      settings = getAndRegisterSettingsService();
      getAndRegisterLocalizationService();
      when(settings.settings).thenReturn(AppSettings.empty());
    });
    tearDown(() => locator.reset());

    test('A truly first-ever load seeds one fresh, active draft', () async {
      final service = DraftService();
      await service.load();

      expect(service.drafts, hasLength(1));
      expect(service.draft.schemaVersion, 1);
      expect(service.draft.experienceIds, isEmpty);
      expect(service.activeDraftId, service.draft.id);
      expect(service.isFreshDraft, isTrue);
    });

    test('A failed load (storage genuinely unavailable) can be retried — '
        'the failure is not cached forever', () async {
      when(
        storage.ensureInitialized(),
      ).thenThrow(Exception('IndexedDB unavailable'));

      final service = DraftService();
      await expectLater(service.load(), throwsException);

      when(storage.ensureInitialized()).thenAnswer((_) => Future<void>.value());

      // If the first failure's Future were still memoized, this would
      // replay the same rejection instead of actually retrying.
      await service.load();

      expect(service.drafts, hasLength(1));
    });

    test('createDraft adds a new active, fresh draft alongside the seeded '
        'one', () async {
      final service = DraftService();
      await service.load();
      final seededId = service.draft.id;

      final newId = await service.createDraft(
        name: 'Acme — Backend',
        notes: 'Tailored for the Acme application',
      );

      expect(service.drafts, hasLength(2));
      expect(service.activeDraftId, newId);
      expect(service.draft.name, 'Acme — Backend');
      expect(service.draft.notes, 'Tailored for the Acme application');
      expect(service.isFreshDraft, isTrue);
      expect(service.drafts.map((d) => d.id), contains(seededId));
    });

    test('openDraft switches the active draft; unknown ids no-op', () async {
      final service = DraftService();
      await service.load();
      final firstId = service.draft.id;
      final secondId = await service.createDraft(name: 'Second CV');
      expect(service.activeDraftId, secondId);

      await service.openDraft(firstId);
      expect(service.activeDraftId, firstId);

      await service.openDraft('does-not-exist');
      expect(service.activeDraftId, firstId);
    });

    test('flushPendingWrites persists the draft a debounced edit was made to, '
        'even if a different draft has since become active — switching away '
        'from a draft mid-debounce must not drop its edit', () async {
      final service = DraftService();
      await service.load();
      final firstId = service.draft.id;

      // Debounced — not yet persisted (no flush, no 300ms wait).
      await service.setHeadlineOverride('Tailored for this application');

      // Switch away before the debounce timer fires. The pending write
      // is still for the first draft, not whatever's active now.
      final secondId = await service.createDraft(name: 'Second CV');
      expect(service.activeDraftId, secondId);

      await service.flushPendingWrites();

      final reloaded = DraftService();
      await reloaded.load();
      final persistedFirst = reloaded.drafts.firstWhere((d) => d.id == firstId);
      expect(persistedFirst.headlineOverride, 'Tailored for this application');
    });

    test(
      'updateDraftDetails renames a draft without touching its selections',
      () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;
        await service.setSkillIncluded('skill-1', included: true);

        await service.updateDraftDetails(
          id,
          name: 'Renamed CV',
          notes: 'Some notes',
        );

        expect(service.draft.name, 'Renamed CV');
        expect(service.draft.notes, 'Some notes');
        expect(service.draft.skillIds, ['skill-1']);
      },
    );

    test('duplicateDraft clones a draft with a new id, becomes active, and '
        'keeps the source selections', () async {
      final service = DraftService();
      await service.load();
      final sourceId = service.draft.id;
      await service.setExperienceIncluded('exp-1', included: true);
      await service.updateDraftDetails(sourceId, name: 'Original', notes: '');

      final copyId = await service.duplicateDraft(sourceId);

      expect(copyId, isNot(sourceId));
      expect(service.activeDraftId, copyId);
      expect(service.draft.name, 'Original (copy)');
      expect(service.draft.experienceIds, ['exp-1']);
      expect(service.drafts, hasLength(2));
    });

    test('deleteDraft reassigns the active draft, and clears it once none '
        'remain', () async {
      final service = DraftService();
      await service.load();
      final firstId = service.draft.id;
      final secondId = await service.createDraft(name: 'Second CV');
      expect(service.activeDraftId, secondId);

      await service.deleteDraft(secondId);
      expect(service.drafts, hasLength(1));
      expect(service.activeDraftId, firstId);

      await service.deleteDraft(firstId);
      expect(service.drafts, isEmpty);
      expect(service.activeDraftId, isNull);
    });

    test('deleteDraft drops a draft edited moments earlier, rather than '
        'letting the still-pending debounced write recreate its storage '
        'entry after the delete', () async {
      final service = DraftService();
      await service.load();
      final id = service.draft.id;
      final key = '${StorageBoxes.drafts}/${StorageKeys.draftEntry(id)}';

      // Debounced — the timer is still running when the delete lands.
      await service.setHeadlineOverride('mid-typing');

      await service.deleteDraft(id);
      expect(memory.containsKey(key), isFalse);

      await Future<void>.delayed(const Duration(milliseconds: 400));

      expect(memory.containsKey(key), isFalse);
    });

    test(
      'Toggling an experience id includes/excludes it, with its bullets',
      () async {
        final service = DraftService();
        await service.load();

        await service.setExperienceIncluded(
          'exp-1',
          included: true,
          bulletIds: ['b1', 'b2'],
        );
        expect(service.draft.experienceIds, ['exp-1']);
        expect(service.draft.bulletIds['exp-1'], ['b1', 'b2']);

        await service.setExperienceIncluded('exp-1', included: false);
        expect(service.draft.experienceIds, isEmpty);
        expect(service.draft.bulletIds.containsKey('exp-1'), isFalse);

        await service.flushPendingWrites();
      },
    );

    test('Toggling a section hides/shows it', () async {
      final service = DraftService();
      await service.load();

      await service.setSectionHidden(CvSectionType.education, hidden: true);
      expect(service.draft.hiddenSections, {CvSectionType.education});

      await service.setSectionHidden(CvSectionType.education, hidden: false);
      expect(service.draft.hiddenSections, isEmpty);

      await service.flushPendingWrites();
    });

    test('setSectionOrder persists a new section order', () async {
      final service = DraftService();
      await service.load();

      const order = [
        CvSectionType.education,
        CvSectionType.experience,
        CvSectionType.summary,
        CvSectionType.skills,
        CvSectionType.projects,
        CvSectionType.hobbies,
        CvSectionType.references,
        CvSectionType.publications,
      ];
      await service.setSectionOrder(order);
      expect(service.draft.sectionOrder, order);

      await service.flushPendingWrites();
    });

    test('resetSectionSettings falls back to the active template\'s order '
        'and nothing hidden when no default has been saved', () async {
      final service = DraftService();
      await service.load();
      final registry = TemplateRegistryService();

      await service.setSectionOrder(const [
        CvSectionType.publications,
        CvSectionType.references,
        CvSectionType.hobbies,
        CvSectionType.education,
        CvSectionType.projects,
        CvSectionType.skills,
        CvSectionType.experience,
        CvSectionType.summary,
      ]);
      await service.setSectionHidden(CvSectionType.hobbies, hidden: true);

      await service.resetSectionSettings(const DocumentDefaults());
      expect(
        service.draft.sectionOrder,
        registry.byId(service.draft.templateId).sectionOrder,
      );
      expect(service.draft.hiddenSections, isEmpty);
    });

    test('resetSectionSettings prefers the user\'s remembered default '
        'order and hidden sections over the template\'s own order and '
        'nothing hidden — reset together, not independently', () async {
      const remembered = [
        CvSectionType.education,
        CvSectionType.experience,
        CvSectionType.summary,
        CvSectionType.skills,
        CvSectionType.projects,
        CvSectionType.hobbies,
        CvSectionType.references,
        CvSectionType.publications,
      ];
      const defaults = DocumentDefaults(
        sectionOrder: remembered,
        hiddenSections: {CvSectionType.references},
      );

      final service = DraftService();
      await service.load();

      await service.setSectionOrder(const [
        CvSectionType.publications,
        CvSectionType.references,
        CvSectionType.hobbies,
        CvSectionType.education,
        CvSectionType.projects,
        CvSectionType.skills,
        CvSectionType.experience,
        CvSectionType.summary,
      ]);
      await service.setSectionHidden(CvSectionType.hobbies, hidden: true);

      await service.resetSectionSettings(defaults);
      expect(service.draft.sectionOrder, remembered);
      expect(service.draft.hiddenSections, {CvSectionType.references});
    });

    test('Selections survive a reload from storage', () async {
      final first = DraftService();
      await first.load();
      final id = first.draft.id;
      await first.setExperienceIncluded('exp-1', included: true);
      await first.setSkillIncluded('skill-1', included: true);
      await first.flushPendingWrites();

      // Simulate a fresh page load: a new service instance, sharing the
      // same backing storage, reads back exactly what was persisted.
      final second = DraftService();
      await second.load();

      expect(second.activeDraftId, id);
      expect(second.draft.experienceIds, ['exp-1']);
      expect(second.draft.skillIds, ['skill-1']);
      expect(second.isFreshDraft, isFalse);
    });

    test(
      'A bulletOverride wins over nothing set — round-trips correctly',
      () async {
        final service = DraftService();
        await service.load();

        await service.setTextOverride(
          TextOverrideField.bullet,
          'bullet-1',
          'Rewritten text',
        );
        expect(service.draft.bulletOverrides['bullet-1'], 'Rewritten text');

        await service.setTextOverride(
          TextOverrideField.bullet,
          'bullet-1',
          null,
        );
        expect(service.draft.bulletOverrides.containsKey('bullet-1'), isFalse);

        await service.flushPendingWrites();
      },
    );

    test('setRegion sets the active draft region', () async {
      final service = DraftService();
      await service.load();
      expect(service.draft.region, RegionProfile.uk);

      await service.setRegion(RegionProfile.us);
      expect(service.draft.region, RegionProfile.us);

      await service.flushPendingWrites();
    });

    test('createDraft seeds region and language from the defaults it is '
        'handed — this service never reaches for the Vault itself', () async {
      final service = DraftService();
      await service.load();

      final newId = await service.createDraft(
        name: 'US application',
        defaults: const DocumentDefaults(
          region: RegionProfile.us,
          language: DocumentLanguage.enUs,
        ),
      );
      expect(service.activeDraftId, newId);
      expect(service.draft.region, RegionProfile.us);
      expect(service.draft.documentLanguage, DocumentLanguage.enUs);
    });

    test('createDraft seeds the headline default onto the new CV, so the '
        'Vault choice reaches the draft that actually renders', () async {
      final service = DraftService();
      await service.load();

      await service.createDraft(
        name: 'No headline',
        defaults: const DocumentDefaults(hideHeadline: true),
      );

      expect(service.draft.hideHeadline, isTrue);
    });

    test('createDraft leaves the headline shown when no default says '
        'otherwise — the pre-defaults behaviour', () async {
      final service = DraftService();
      await service.load();

      await service.createDraft(
        name: 'Ordinary',
        defaults: const DocumentDefaults(),
      );

      expect(service.draft.hideHeadline, isFalse);
    });

    test('createDraft starts a new CV on the default template, rather than '
        'inheriting the open draft template', () async {
      final service = DraftService();
      await service.load();

      await service.createDraft(
        name: 'On the default',
        defaults: const DocumentDefaults(templateId: 'photo_header'),
      );

      expect(service.draft.templateId, 'photo_header');
    });

    test('an explicit templateId still beats the default, so "duplicate as" '
        'is not overridden by a preference', () async {
      final service = DraftService();
      await service.load();

      await service.createDraft(
        name: 'Explicit',
        templateId: 'classic_centered',
        defaults: const DocumentDefaults(templateId: 'photo_header'),
      );

      expect(service.draft.templateId, 'classic_centered');
    });

    test('changing the defaults afterwards leaves an existing draft alone — '
        'they seed a CV, they do not follow it', () async {
      final service = DraftService();
      await service.load();

      await service.createDraft(
        name: 'German application',
        defaults: const DocumentDefaults(
          region: RegionProfile.dach,
          language: DocumentLanguage.de,
        ),
      );
      await service.createDraft(
        name: 'UK application',
        defaults: const DocumentDefaults(region: RegionProfile.uk),
      );

      final german = service.drafts.firstWhere(
        (d) => d.name == 'German application',
      );
      expect(german.region, RegionProfile.dach);
      expect(german.documentLanguage, DocumentLanguage.de);
    });

    test('createDraft seeds sectionOrder AND hiddenSections from '
        'SettingsService\'s defaultSectionOrder/defaultHiddenSections when '
        'they\'ve been saved', () async {
      const remembered = [
        CvSectionType.education,
        CvSectionType.experience,
        CvSectionType.summary,
        CvSectionType.skills,
        CvSectionType.projects,
        CvSectionType.hobbies,
        CvSectionType.references,
        CvSectionType.publications,
      ];
      final service = DraftService();
      await service.load();

      await service.createDraft(
        name: 'Tailored application',
        defaults: const DocumentDefaults(
          sectionOrder: remembered,
          hiddenSections: {CvSectionType.hobbies},
        ),
      );
      expect(service.draft.sectionOrder, remembered);
      expect(service.draft.hiddenSections, {CvSectionType.hobbies});
    });

    test('createDraft falls back to the resolved template\'s own '
        'sectionOrder when no default has been saved', () async {
      final service = DraftService();
      await service.load();
      final registry = TemplateRegistryService();

      final newId = await service.createDraft(
        name: 'Classic application',
        templateId: 'classic_centered',
      );
      expect(service.activeDraftId, newId);
      expect(
        service.draft.sectionOrder,
        registry.byId('classic_centered').sectionOrder,
      );
      expect(service.draft.hiddenSections, isEmpty);
    });

    test('An old-shaped draft JSON with no sectionOrder key still loads, '
        'defaulting to the canonical order', () async {
      final legacyJson = {
        'schemaVersion': 1,
        'id': 'legacy-draft',
        'name': 'Legacy CV',
        'templateId': 'compact',
        'region': 'uk',
        'notes': '',
        'experienceIds': <String>[],
        'bulletIds': <String, dynamic>{},
        'projectIds': <String>[],
        'projectBulletIds': <String, dynamic>{},
        'skillIds': <String>[],
        'educationIds': <String>[],
        'hobbyIds': <String>[],
        'publicationIds': <String>[],
        'hiddenSections': <String>[],
        'bulletOverrides': <String, dynamic>{},
        'educationDetailsOverrides': <String, dynamic>{},
        'updatedAt': DateTime(2026).toIso8601String(),
      };
      memory['${StorageBoxes.drafts}/${StorageKeys.draftIndex}'] = jsonEncode({
        'schemaVersion': 1,
        'draftIds': ['legacy-draft'],
        'activeDraftId': 'legacy-draft',
      });
      memory['${StorageBoxes.drafts}/${StorageKeys.draftEntry('legacy-draft')}'] =
          jsonEncode(legacyJson);

      final service = DraftService();
      await service.load();

      expect(service.draft.sectionOrder, CvSectionType.values);
    });

    // The same "sets and clears" round-trip over a scalar override, a
    // second scalar, and an id-keyed one — a table instead of three copies.
    for (final c
        in <
          ({
            String label,
            Future<void> Function(DraftService service, String? value)
            setOverride,
            String? Function(DraftService service) readOverride,
          })
        >[
          (
            label: 'setHeadlineOverride',
            setOverride: (s, v) => s.setHeadlineOverride(v),
            readOverride: (s) => s.draft.headlineOverride,
          ),
          (
            label: 'setReferencesOverride',
            setOverride: (s, v) => s.setReferencesOverride(v),
            readOverride: (s) => s.draft.referencesOverride,
          ),
          (
            label: 'setTextOverride(educationDetails)',
            setOverride: (s, v) => s.setTextOverride(
              TextOverrideField.educationDetails,
              'edu-1',
              v,
            ),
            readOverride: (s) => s.draft.educationDetailsOverrides['edu-1'],
          ),
        ]) {
      test('${c.label} sets and clears the override', () async {
        final service = DraftService();
        await service.load();

        await c.setOverride(service, 'Rewritten value');
        expect(c.readOverride(service), 'Rewritten value');

        await c.setOverride(service, null);
        expect(c.readOverride(service), isNull);

        await service.flushPendingWrites();
      });
    }

    test('Migrates a pre-multi-draft single draft into the indexed scheme, '
        "without discarding it or the legacy key it came from", () async {
      memory['${StorageBoxes.drafts}/${StorageKeys.currentDraftId}'] =
          jsonEncode({
            'schemaVersion': 1,
            'id': 'current',
            'name': 'My Old CV',
            'templateId': 'compact',
            'experienceIds': ['x'],
            'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
          });

      final service = DraftService();
      await service.load();

      expect(service.drafts, hasLength(1));
      expect(service.draft.name, 'My Old CV');
      expect(service.draft.id, isNot('current'));
      expect(service.draft.experienceIds, ['x']);
      expect(service.isFreshDraft, isFalse);
      // The old key is left in place, dead but harmless.
      expect(
        memory.containsKey(
          '${StorageBoxes.drafts}/${StorageKeys.currentDraftId}',
        ),
        isTrue,
      );
    });

    test('A corrupted per-draft entry is quarantined and dropped; other '
        "drafts in the index still load", () async {
      final seed = DraftService();
      await seed.load();
      final goodId = seed.draft.id;
      await seed.flushPendingWrites();

      // Hand-craft an index that also references a second, corrupt entry.
      memory['${StorageBoxes.drafts}/${StorageKeys.draftIndex}'] = jsonEncode({
        'schemaVersion': 1,
        'draftIds': [goodId, 'broken-id'],
        'activeDraftId': goodId,
      });
      memory['${StorageBoxes.drafts}/${StorageKeys.draftEntry('broken-id')}'] =
          'not valid json';

      final service = DraftService();
      await service.load();

      expect(service.drafts, hasLength(1));
      expect(service.draft.id, goodId);
      expect(
        memory.keys.any(
          (k) => k.contains('${StorageKeys.draftEntry('broken-id')}_corrupt_'),
        ),
        isTrue,
      );
    });

    group('applyAiAssistantResult / undoAiAssistantPass -', () {
      const result = AiAssistantResult(
        headline: 'Backend Engineer',
        summary: 'Tailored summary.',
        experienceIds: ['exp-1'],
        bulletIds: {
          'exp-1': ['bullet-1'],
        },
        projectIds: [],
        projectBulletIds: {},
        publicationIds: [],
        publicationBulletIds: {},
        bulletOverrides: {'bullet-1': 'Rewritten bullet.'},
        skillIds: ['skill-1'],
        educationIds: [],
        educationBulletIds: {},
        hobbyIds: [],
        hiddenSections: {CvSectionType.hobbies},
        rationale: 'Kept the relevant backend experience.',
        keywordGaps: ['Kubernetes'],
      );

      test('applies every field in one write and snapshots the pre-pass '
          'draft for undo', () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;

        await service.applyAiAssistantResult(result);

        expect(service.draft.headlineOverride, 'Backend Engineer');
        expect(service.draft.tailoredSummary, 'Tailored summary.');
        expect(service.draft.experienceIds, ['exp-1']);
        expect(service.draft.bulletIds, {
          'exp-1': ['bullet-1'],
        });
        expect(service.draft.bulletOverrides, {
          'bullet-1': 'Rewritten bullet.',
        });
        expect(service.draft.skillIds, ['skill-1']);
        expect(service.draft.hiddenSections, {CvSectionType.hobbies});
        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.aiAssistantUndoFor(id)}',
          ),
          isTrue,
        );
        expect(await service.hasAiAssistantUndoFor(id), isTrue);
      });

      test('a null headline/summary in the result leaves any existing '
          'override alone rather than clearing it', () async {
        final service = DraftService();
        await service.load();
        await service.setHeadlineOverride('Manually set headline');

        await service.applyAiAssistantResult(
          result.copyWith(headline: null, summary: null),
        );

        expect(service.draft.headlineOverride, 'Manually set headline');
      });

      test('undoAiAssistantPass restores the pre-pass draft exactly and clears '
          'the snapshot', () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;
        final before = service.draft;

        await service.applyAiAssistantResult(result);
        final restored = await service.undoAiAssistantPass();

        expect(restored, isTrue);
        expect(service.draft.headlineOverride, before.headlineOverride);
        expect(service.draft.experienceIds, before.experienceIds);
        expect(service.draft.bulletOverrides, before.bulletOverrides);
        expect(await service.hasAiAssistantUndoFor(id), isFalse);
      });

      test('undoAiAssistantPass is a no-op when no pass has run', () async {
        final service = DraftService();
        await service.load();

        expect(await service.undoAiAssistantPass(), isFalse);
      });

      test('deleting a draft clears its undo snapshot too', () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;
        await service.applyAiAssistantResult(result);

        await service.deleteDraft(id);

        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.aiAssistantUndoFor(id)}',
          ),
          isFalse,
        );
      });
    });

    group('setFieldOmitted -', () {
      test('putting a field back removes the key entirely, so a draft that '
          'omitted something and changed its mind stores exactly what one '
          'that never touched it stores', () async {
        final service = DraftService();
        await service.load();

        await service.setFieldOmitted(
          DraftOmittableField.projectLink,
          'proj-1',
          omitted: true,
        );
        expect(service.draft.omittedFields, {
          DraftOmittableField.projectLink: ['proj-1'],
        });

        await service.setFieldOmitted(
          DraftOmittableField.projectLink,
          'proj-1',
          omitted: false,
        );
        expect(service.draft.omittedFields, isEmpty);
      });

      test('resetWordingToVault leaves omissions alone — whether a field '
          'prints at all is the selection axis, not the wording one', () async {
        final service = DraftService();
        await service.load();

        await service.setFieldOmitted(
          DraftOmittableField.educationYear,
          'edu-1',
          omitted: true,
        );
        await service.setHeadlineOverride('Hand-edited headline');

        await service.resetWordingToVault();

        expect(service.draft.headlineOverride, isNull);
        expect(service.draft.omittedFields, {
          DraftOmittableField.educationYear: ['edu-1'],
        });
      });
    });

    group('resetWordingToVault -', () {
      test('clears every text override and the translation marker, while '
          'leaving selection alone — the one way back that needs no '
          'snapshot', () async {
        final service = DraftService();
        await service.load();
        await service.setExperienceIncluded(
          'exp-1',
          included: true,
          bulletIds: const ['bullet-1'],
        );
        await service.setTextOverride(
          TextOverrideField.bullet,
          'bullet-1',
          'Hand-edited bullet.',
        );
        await service.setHeadlineOverride('Hand-edited headline');
        await service.applyCvTranslationResult(
          const CvTranslationResult(
            roles: {'exp-1': 'Leitender Ingenieur'},
            projectTitles: {},
            skillCategoryNames: {},
            skillLabels: {},
            educationQualifications: {},
            educationGrades: {},
            educationDetails: {},
            hobbies: {},
            bullets: {},
          ),
          DocumentLanguage.de,
        );

        await service.resetWordingToVault();

        expect(service.draft.headlineOverride, isNull);
        expect(service.draft.bulletOverrides, isEmpty);
        expect(service.draft.roleOverrides, isEmpty);
        expect(service.draft.translatedTo, isNull);
        // Selection is a separate axis and must survive.
        expect(service.draft.experienceIds, ['exp-1']);
        expect(service.draft.bulletIds['exp-1'], ['bullet-1']);
      });

      test('clears every TextOverrideField, derived from the enum rather '
          'than a list written out here — a field added to the enum and '
          'not to the reset would let a user create wording they could '
          'never get back', () async {
        final service = DraftService();
        await service.load();

        for (final field in TextOverrideField.values) {
          await service.setTextOverride(field, 'some-id', 'Overridden.');
        }
        expect(service.draft.hasAnyTextOverride, isTrue);

        await service.resetWordingToVault();

        for (final field in TextOverrideField.values) {
          expect(
            field.of(service.draft),
            isEmpty,
            reason: 'TextOverrideField.${field.name} survived the reset',
          );
        }
        expect(service.draft.hasAnyTextOverride, isFalse);
      });

      test('drops both undo snapshots, so neither pass can put its wording '
          'back onto a draft just reset to the Vault', () async {
        const aiPass = AiAssistantResult(
          summary: 'Tailored summary.',
          experienceIds: [],
          bulletIds: {},
          projectIds: [],
          projectBulletIds: {},
          publicationIds: [],
          publicationBulletIds: {},
          bulletOverrides: {},
          skillIds: [],
          educationIds: [],
          educationBulletIds: {},
          hobbyIds: [],
          hiddenSections: {},
          rationale: '',
          keywordGaps: [],
        );
        const translationPass = CvTranslationResult(
          summary: 'Zusammenfassung.',
          roles: {},
          projectTitles: {},
          skillCategoryNames: {},
          skillLabels: {},
          educationQualifications: {},
          educationGrades: {},
          educationDetails: {},
          hobbies: {},
          bullets: {},
        );

        final service = DraftService();
        await service.load();
        final id = service.draft.id;
        await service.applyAiAssistantResult(aiPass);
        await service.applyCvTranslationResult(
          translationPass,
          DocumentLanguage.de,
        );

        await service.resetWordingToVault();

        expect(await service.hasAiAssistantUndoFor(id), isFalse);
        expect(await service.hasCvTranslationUndoFor(id), isFalse);
      });
    });

    group('applyCvTranslationResult / removeCvTranslation -', () {
      const translation = CvTranslationResult(
        headline: 'Leitender Ingenieur',
        summary: 'Zusammenfassung.',
        roles: {'exp-1': 'Leitender Ingenieur'},
        projectTitles: {},
        skillCategoryNames: {'cat-1': 'Sprachen'},
        skillLabels: {'skill-1': 'Stakeholder-Management'},
        educationQualifications: {},
        educationGrades: {},
        educationDetails: {},
        hobbies: {'hobby-1': 'Bouldern'},
        bullets: {'bullet-1': 'Leitete ein Team von sechs.'},
      );

      test('writes every override group and records the language it '
          'translated into', () async {
        final service = DraftService();
        await service.load();

        await service.applyCvTranslationResult(
          translation,
          DocumentLanguage.de,
        );

        expect(service.draft.headlineOverride, 'Leitender Ingenieur');
        expect(service.draft.roleOverrides, {'exp-1': 'Leitender Ingenieur'});
        expect(service.draft.skillCategoryNameOverrides, {'cat-1': 'Sprachen'});
        expect(service.draft.skillLabelOverrides, {
          'skill-1': 'Stakeholder-Management',
        });
        expect(service.draft.hobbyOverrides, {'hobby-1': 'Bouldern'});
        expect(service.draft.bulletOverrides, {
          'bullet-1': 'Leitete ein Team von sechs.',
        });
        expect(service.draft.translatedTo, DocumentLanguage.de);
      });

      test('replaces rather than merges, so a second pass into another '
          'language leaves no strings from the first behind', () async {
        final service = DraftService();
        await service.load();

        await service.applyCvTranslationResult(
          translation,
          DocumentLanguage.de,
        );
        await service.applyCvTranslationResult(
          translation.copyWith(roles: const {'exp-2': 'Ingeniero Senior'}),
          DocumentLanguage.es,
        );

        expect(service.draft.roleOverrides, {'exp-2': 'Ingeniero Senior'});
        expect(service.draft.translatedTo, DocumentLanguage.es);
      });

      test('snapshots to its own key, never contending with the AI '
          "Assistant's — otherwise one undo would silently undo the other "
          'pass', () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;

        await service.applyCvTranslationResult(
          translation,
          DocumentLanguage.de,
        );

        expect(await service.hasAiAssistantUndoFor(id), isFalse);
        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.cvTranslationUndoFor(id)}',
          ),
          isTrue,
        );
      });

      test('removeCvTranslation restores the pre-pass draft and clears '
          'translatedTo with it', () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;
        await service.setTextOverride(
          TextOverrideField.role,
          'exp-1',
          'Hand-edited role',
        );
        final before = service.draft;

        await service.applyCvTranslationResult(
          translation,
          DocumentLanguage.de,
        );
        final restored = await service.removeCvTranslation();

        expect(restored, isTrue);
        expect(service.draft.roleOverrides, before.roleOverrides);
        expect(service.draft.headlineOverride, before.headlineOverride);
        expect(service.draft.translatedTo, isNull);
        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.cvTranslationUndoFor(id)}',
          ),
          isFalse,
        );
      });

      test('a second pass keeps the first snapshot, so "remove" always '
          'lands on an untranslated CV rather than on the previous '
          'translation', () async {
        final service = DraftService();
        await service.load();

        await service.applyCvTranslationResult(
          translation,
          DocumentLanguage.de,
        );
        await service.applyCvTranslationResult(
          translation.copyWith(roles: const {'exp-1': 'Ingeniero Senior'}),
          DocumentLanguage.es,
        );
        await service.removeCvTranslation();

        expect(service.draft.translatedTo, isNull);
        expect(service.draft.roleOverrides, isEmpty);
      });

      test('removeCvTranslation is a no-op when nothing has been '
          'translated', () async {
        final service = DraftService();
        await service.load();

        expect(await service.removeCvTranslation(), isFalse);
      });

      test('deleting a draft clears its translation snapshot too, so no '
          'orphaned row survives it', () async {
        final service = DraftService();
        await service.load();
        final id = service.draft.id;

        await service.applyCvTranslationResult(
          translation,
          DocumentLanguage.de,
        );
        await service.deleteDraft(id);

        expect(
          memory.containsKey(
            '${StorageBoxes.drafts}/${StorageKeys.cvTranslationUndoFor(id)}',
          ),
          isFalse,
        );
      });
    });
  });
}
