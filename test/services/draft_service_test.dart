import 'dart:convert';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/models/settings/app_settings.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/storage_keys.dart';
import 'package:cv_forge/services/template_registry_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

/// Backs [MockLocalStorageService] with a real in-memory map keyed by
/// "box/key", so two [DraftService] instances sharing the same mock
/// genuinely round-trip through separate index/per-draft entries — a
/// blanket `when(storage.read(any, any))` returning one canned value
/// can't exercise the indexed, multi-key storage scheme correctly (the
/// index and a draft entry are both valid JSON with a `schemaVersion`
/// key, so a wrong value can accidentally "succeed" parsing as the wrong
/// shape instead of failing loudly).
Map<String, String> _wireMemoryStorage(MockLocalStorageService storage) {
  final memory = <String, String>{};
  when(storage.read(any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final key = invocation.positionalArguments[1] as String;
    return memory['$box/$key'];
  });
  when(storage.write(any, any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final key = invocation.positionalArguments[1] as String;
    final value = invocation.positionalArguments[2] as String;
    memory['$box/$key'] = value;
  });
  when(storage.delete(any, any)).thenAnswer((invocation) async {
    final box = invocation.positionalArguments[0] as String;
    final key = invocation.positionalArguments[1] as String;
    memory.remove('$box/$key');
  });
  return memory;
}

void main() {
  group('DraftServiceTest -', () {
    late MockLocalStorageService storage;
    late Map<String, String> memory;
    late MockSettingsService settings;

    setUp(() {
      storage = getAndRegisterLocalStorageService();
      memory = _wireMemoryStorage(storage);
      // DraftService resolves this for real (not mocked) to stamp a
      // genuinely registered template id on every seeded/migrated draft —
      // see CvDraft.empty's doc comment.
      locator.registerLazySingleton<TemplateRegistryService>(
        TemplateRegistryService.new,
      );
      settings = getAndRegisterSettingsService();
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

        await service.setBulletOverride('bullet-1', 'Rewritten text');
        expect(service.draft.bulletOverrides['bullet-1'], 'Rewritten text');

        await service.setBulletOverride('bullet-1', null);
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

    test('createDraft defaults a new draft\'s region from '
        "SettingsService's defaultRegion", () async {
      when(settings.settings).thenReturn(
        AppSettings.empty().copyWith(defaultRegion: RegionProfile.us),
      );

      final service = DraftService();
      await service.load();

      final newId = await service.createDraft(name: 'US application');
      expect(service.activeDraftId, newId);
      expect(service.draft.region, RegionProfile.us);
    });

    test('setHeadlineOverride sets and clears the override', () async {
      final service = DraftService();
      await service.load();

      await service.setHeadlineOverride('Rewritten headline');
      expect(service.draft.headlineOverride, 'Rewritten headline');

      await service.setHeadlineOverride(null);
      expect(service.draft.headlineOverride, isNull);

      await service.flushPendingWrites();
    });

    test('setReferencesOverride sets and clears the override', () async {
      final service = DraftService();
      await service.load();

      await service.setReferencesOverride('Rewritten references');
      expect(service.draft.referencesOverride, 'Rewritten references');

      await service.setReferencesOverride(null);
      expect(service.draft.referencesOverride, isNull);

      await service.flushPendingWrites();
    });

    test('setEducationDetailsOverride sets and clears the override — '
        'round-trips correctly', () async {
      final service = DraftService();
      await service.load();

      await service.setEducationDetailsOverride('edu-1', 'Rewritten details');
      expect(
        service.draft.educationDetailsOverrides['edu-1'],
        'Rewritten details',
      );

      await service.setEducationDetailsOverride('edu-1', null);
      expect(
        service.draft.educationDetailsOverrides.containsKey('edu-1'),
        isFalse,
      );

      await service.flushPendingWrites();
    });

    test('Migrates a pre-multi-draft single draft into the indexed scheme, '
        "without discarding it or the legacy key it came from", () async {
      memory['${StorageBoxes.drafts}/${StorageKeys.currentDraftId}'] =
          jsonEncode({
            'schemaVersion': 1,
            'id': 'current',
            'name': 'My Old CV',
            'templateId': 'ats_minimal',
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
  });
}
