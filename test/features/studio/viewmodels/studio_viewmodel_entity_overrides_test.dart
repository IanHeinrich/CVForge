import 'package:cv_forge/models/draft/text_override_field.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

/// The entity-scoped text overrides added so a draft can shorten a job
/// title, rename a skill, or carry a translation without touching the
/// Vault — and so the same layer a translation pass writes to is one the
/// user can reach by hand.
void main() {
  group('StudioViewModel Tests - entity overrides -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterSettingsService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      getAndRegisterRouterService();
      getAndRegisterDialogService();
      getAndRegisterLocalizationService();
    });
    tearDown(() => locator.reset());

    test('a role override is what renders, leaving the Vault alone', () {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(experiences: const [sampleExperience]));
      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: const ['exp-1'],
          roleOverrides: const {'exp-1': 'Leitender Ingenieur'},
        ),
      );

      final model = StudioViewModel();

      expect(model.roleText(sampleExperience), 'Leitender Ingenieur');
      expect(model.hasRoleOverride('exp-1'), isTrue);

      final section = model.resolvedCv.sections
          .whereType<ResolvedExperienceSection>()
          .first;
      expect(section.groups.first.positions.first.role, 'Leitender Ingenieur');
      // The Vault is untouched, which is the whole premise.
      expect(vaultService.vault.experiences.first.role, sampleExperience.role);
    });

    test('without an override the Vault value renders', () {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(experiences: const [sampleExperience]));
      when(
        draftService.draft,
      ).thenReturn(draftWith(experienceIds: const ['exp-1']));

      final model = StudioViewModel();

      expect(model.roleText(sampleExperience), sampleExperience.role);
      expect(model.hasRoleOverride('exp-1'), isFalse);
    });

    test('skill, category and hobby overrides all reach the document', () {
      const category = SkillCategory(
        id: 'cat-1',
        name: 'Languages',
        skills: [Skill(id: 'sk-1', label: 'Stakeholder management')],
      );
      const hobby = HobbyItem(id: 'h-1', text: 'Bouldering');

      when(vaultService.vault).thenReturn(
        vaultWith(skillCategories: const [category], hobbies: const [hobby]),
      );
      when(draftService.draft).thenReturn(
        draftWith(
          skillIds: const ['sk-1'],
          hobbyIds: const ['h-1'],
          skillLabelOverrides: const {'sk-1': 'Stakeholder-Management'},
          skillCategoryNameOverrides: const {'cat-1': 'Sprachen'},
          hobbyOverrides: const {'h-1': 'Bouldern'},
        ),
      );

      final model = StudioViewModel();

      expect(
        model.skillLabelText(category.skills.first),
        'Stakeholder-Management',
      );
      expect(model.skillCategoryNameText(category), 'Sprachen');
      expect(model.hobbyText(hobby), 'Bouldern');

      final skills = model.resolvedCv.sections
          .whereType<ResolvedSkillsSection>()
          .first;
      expect(skills.groups.first.category, 'Sprachen');
      expect(skills.groups.first.skills, ['Stakeholder-Management']);

      final hobbies = model.resolvedCv.sections
          .whereType<ResolvedHobbiesSection>()
          .first;
      expect(hobbies.items, ['Bouldern']);
    });

    test('typing the Vault value back leaves no override behind, so the '
        'field stays connected to future Vault edits', () async {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(experiences: const [sampleExperience]));
      when(
        draftService.draft,
      ).thenReturn(draftWith(experienceIds: const ['exp-1']));
      when(
        draftService.setTextOverride(any, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.setRoleOverride(sampleExperience, sampleExperience.role);

      verify(
        draftService.setTextOverride(TextOverrideField.role, 'exp-1', null),
      ).called(1);
    });

    test(
      'blank input clears the override rather than printing nothing',
      () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: const [sampleExperience]));
        when(
          draftService.draft,
        ).thenReturn(draftWith(experienceIds: const ['exp-1']));
        when(
          draftService.setTextOverride(any, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        await model.setRoleOverride(sampleExperience, '   ');

        verify(
          draftService.setTextOverride(TextOverrideField.role, 'exp-1', null),
        ).called(1);
      },
    );

    test('reverting delegates a null through to the service', () async {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(experiences: const [sampleExperience]));
      when(
        draftService.draft,
      ).thenReturn(draftWith(experienceIds: const ['exp-1']));
      when(
        draftService.setTextOverride(any, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.revertRoleOverride('exp-1');

      verify(
        draftService.setTextOverride(TextOverrideField.role, 'exp-1', null),
      ).called(1);
    });
  });

  group('StudioViewModel Tests - headline visibility -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterSettingsService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      getAndRegisterRouterService();
      getAndRegisterDialogService();
      getAndRegisterLocalizationService();
    });
    tearDown(() => locator.reset());

    test('hiding the headline empties it on the document but keeps the '
        'override, so toggling back restores the edit', () {
      when(vaultService.vault).thenReturn(
        vaultWith(basics: ContactBasics.empty().copyWith(headline: 'Vault')),
      );
      when(
        draftService.draft,
      ).thenReturn(draftWith(headlineOverride: 'Tailored', hideHeadline: true));

      final model = StudioViewModel();

      expect(model.includeHeadline, isFalse);
      expect(model.resolvedCv.header.headline, isEmpty);
      // Still there, waiting for the toggle to come back on.
      expect(model.headlineText, 'Tailored');
    });

    test('showing it again prints the override', () {
      when(vaultService.vault).thenReturn(
        vaultWith(basics: ContactBasics.empty().copyWith(headline: 'Vault')),
      );
      when(
        draftService.draft,
      ).thenReturn(draftWith(headlineOverride: 'Tailored'));

      final model = StudioViewModel();

      expect(model.includeHeadline, isTrue);
      expect(model.resolvedCv.header.headline, 'Tailored');
    });

    test(
      'toggling asks the service for the opposite of what is shown',
      () async {
        when(vaultService.vault).thenReturn(vaultWith());
        when(draftService.draft).thenReturn(draftWith());
        when(
          draftService.setHeadlineHidden(any),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        await model.toggleHeadline();

        verify(draftService.setHeadlineHidden(true)).called(1);
      },
    );
  });

  group('StudioViewModel Tests - translation state -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterSettingsService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      getAndRegisterRouterService();
      getAndRegisterDialogService();
      getAndRegisterLocalizationService();
    });
    tearDown(() => locator.reset());

    test('an untranslated draft reports no translated language', () {
      when(vaultService.vault).thenReturn(vaultWith());
      when(draftService.draft).thenReturn(draftWith());

      final model = StudioViewModel();

      expect(model.translatedLanguage, isNull);
      expect(model.isTranslationStale, isFalse);
    });

    test('a translation matching the document language is not stale', () {
      when(vaultService.vault).thenReturn(vaultWith());
      when(draftService.draft).thenReturn(
        draftWith(
          documentLanguage: DocumentLanguage.de,
          translatedTo: DocumentLanguage.de,
        ),
      );

      final model = StudioViewModel();

      expect(model.isTranslationStale, isFalse);
    });

    test('changing the document language after translating marks it stale, '
        'since what prints is a translation into the wrong language', () {
      when(vaultService.vault).thenReturn(vaultWith());
      when(draftService.draft).thenReturn(
        draftWith(
          documentLanguage: DocumentLanguage.es,
          translatedTo: DocumentLanguage.de,
        ),
      );

      final model = StudioViewModel();

      expect(model.isTranslationStale, isTrue);
    });
  });
}
