import 'package:cv_forge/models/draft/draft_omittable_field.dart';
import 'package:cv_forge/models/draft/text_override_field.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/document/document_language.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/language_item.dart';
import 'package:cv_forge/models/vault/language_proficiency.dart';
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

    test('a language renders its name and its CEFR band, and the band is '
        'the same code in every document language', () {
      const german = LanguageItem(
        id: 'lang-1',
        name: 'German',
        proficiency: LanguageProficiency.b2,
      );
      const spanish = LanguageItem(id: 'lang-2', name: 'Spanish');

      when(
        vaultService.vault,
      ).thenReturn(vaultWith(languages: const [german, spanish]));
      when(
        draftService.draft,
      ).thenReturn(draftWith(languageIds: const ['lang-1', 'lang-2']));

      final languages = StudioViewModel().resolvedCv.sections
          .whereType<ResolvedLanguagesSection>()
          .first;

      expect(languages.items.map((l) => l.name), ['German', 'Spanish']);
      expect(languages.items.first.level, 'B2');
      // Ungraded prints the language alone rather than inventing a band.
      expect(languages.items.last.level, isNull);
    });

    test('a native speaker is the one band that takes the document '
        "language's own word for it", () {
      const english = LanguageItem(
        id: 'lang-1',
        name: 'Englisch',
        proficiency: LanguageProficiency.native,
      );

      when(
        vaultService.vault,
      ).thenReturn(vaultWith(languages: const [english]));
      when(draftService.draft).thenReturn(
        draftWith(
          languageIds: const ['lang-1'],
          documentLanguage: DocumentLanguage.de,
        ),
      );

      final languages = StudioViewModel().resolvedCv.sections
          .whereType<ResolvedLanguagesSection>()
          .first;

      expect(languages.title, 'Sprachen');
      expect(languages.items.single.level, 'Muttersprache');
    });

    test('a language name override reaches the document, and the band it '
        'carries is left alone — a CEFR code is not wording', () {
      const german = LanguageItem(
        id: 'lang-1',
        name: 'German',
        proficiency: LanguageProficiency.c1,
      );

      when(vaultService.vault).thenReturn(vaultWith(languages: const [german]));
      when(draftService.draft).thenReturn(
        draftWith(
          languageIds: const ['lang-1'],
          languageOverrides: const {'lang-1': 'Deutsch'},
        ),
      );

      final model = StudioViewModel();
      expect(model.languageName(german), 'Deutsch');

      final languages = model.resolvedCv.sections
          .whereType<ResolvedLanguagesSection>()
          .first;
      expect(languages.items.single.name, 'Deutsch');
      expect(languages.items.single.level, 'C1');
    });

    test('a Vault with languages none of which this draft selected omits '
        'the section rather than printing an empty heading', () {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(languages: const [sampleLanguage]));
      when(draftService.draft).thenReturn(draftWith());

      expect(
        StudioViewModel().resolvedCv.sections
            .whereType<ResolvedLanguagesSection>(),
        isEmpty,
      );
    });

    test('a publication title and citation override are what render — a '
        'paper is cited differently by different venues, and only the '
        'person who wrote it knows which form belongs on this CV', () {
      const paper = Publication(
        id: 'pub-1',
        title: 'On Consensus Under Partition',
        citation: 'Proc. FOO 2021, pp. 1-12',
        link: 'https://example.org/paper',
      );
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(publications: const [paper]));
      when(draftService.draft).thenReturn(
        draftWith(
          publicationIds: const ['pub-1'],
          publicationTitleOverrides: const {
            'pub-1': 'Sobre el consenso ante particiones',
          },
          publicationCitationOverrides: const {
            'pub-1': 'Actas FOO 2021, pp. 1-12',
          },
        ),
      );

      final model = StudioViewModel();

      expect(
        model.publicationTitleText(paper),
        'Sobre el consenso ante '
        'particiones',
      );
      expect(model.publicationCitationText(paper), 'Actas FOO 2021, pp. 1-12');

      final section = model.resolvedCv.sections
          .whereType<ResolvedPublicationsSection>()
          .first;
      expect(section.items.single.title, 'Sobre el consenso ante particiones');
      expect(section.items.single.citation, 'Actas FOO 2021, pp. 1-12');
      // The link is the one part that stays the Vault's.
      expect(section.items.single.link, 'https://example.org/paper');
    });

    test('an education location override is what renders — a city has a '
        'name in each language, unlike the institution beside it', () {
      const degree = Education(
        id: 'edu-1',
        qualification: 'BSc',
        institution: 'TUM',
        location: 'Munich',
      );
      when(vaultService.vault).thenReturn(vaultWith(education: const [degree]));
      when(draftService.draft).thenReturn(
        draftWith(
          educationIds: const ['edu-1'],
          educationLocationOverrides: const {'edu-1': 'München'},
        ),
      );

      final model = StudioViewModel();

      expect(model.educationLocationText(degree), 'München');
      final section = model.resolvedCv.sections
          .whereType<ResolvedEducationSection>()
          .first;
      expect(section.items.single.location, 'München');
      expect(section.items.single.institution, 'TUM');
    });

    group('experience location overrides in a company group -', () {
      // Two roles at one employer. The group prints ONE location line, and
      // `roles.first` after the recency sort is the newer role — so an
      // override on the older one has to be able to reach the group, or
      // editing it would silently do nothing.
      const newer = Experience(
        id: 'exp-new',
        role: 'Staff Engineer',
        company: 'Acme',
        location: 'Munich',
        start: YearMonth(year: 2022, month: 1),
        isCurrent: true,
        companyGroupId: 'grp-1',
      );
      const older = Experience(
        id: 'exp-old',
        role: 'Senior Engineer',
        company: 'Acme',
        location: 'Munich',
        start: YearMonth(year: 2019, month: 1),
        end: YearMonth(year: 2021, month: 12),
        companyGroupId: 'grp-1',
      );

      String? printedLocation(StudioViewModel model) => model
          .resolvedCv
          .sections
          .whereType<ResolvedExperienceSection>()
          .first
          .groups
          .single
          .location;

      test('with no override the group prints the newest role\'s location', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: const [newer, older]));
        when(
          draftService.draft,
        ).thenReturn(draftWith(experienceIds: const ['exp-new', 'exp-old']));

        expect(printedLocation(StudioViewModel()), 'Munich');
      });

      test('an override on the older role still reaches the group, so '
          'editing it is never a no-op', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: const [newer, older]));
        when(draftService.draft).thenReturn(
          draftWith(
            experienceIds: const ['exp-new', 'exp-old'],
            experienceLocationOverrides: const {'exp-old': 'München'},
          ),
        );

        expect(printedLocation(StudioViewModel()), 'München');
      });

      test('with both overridden the newest wins, so the result is '
          'deterministic rather than dependent on edit order', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: const [newer, older]));
        when(draftService.draft).thenReturn(
          draftWith(
            experienceIds: const ['exp-new', 'exp-old'],
            experienceLocationOverrides: const {
              'exp-new': 'München',
              'exp-old': 'Muenchen',
            },
          ),
        );

        expect(printedLocation(StudioViewModel()), 'München');
      });
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

    group('omitted fields -', () {
      // Three fields nobody may rewrite for one application without
      // saying something untrue, but that anyone may leave off.
      const project = Project(
        id: 'proj-1',
        title: 'CV Forge',
        link: 'https://example.org/demo',
      );
      const paper = Publication(
        id: 'pub-1',
        title: 'On Consensus Under Partition',
        link: 'https://example.org/paper',
      );
      const degree = Education(
        id: 'edu-1',
        qualification: 'BSc',
        institution: 'Leeds',
        year: 2011,
      );

      test('with nothing omitted every field prints — a draft saved before '
          'any of this existed has no map at all, and must be unchanged '
          'by the upgrade', () {
        when(vaultService.vault).thenReturn(
          vaultWith(
            projects: const [project],
            publications: const [paper],
            education: const [degree],
          ),
        );
        when(draftService.draft).thenReturn(
          draftWith(
            projectIds: const ['proj-1'],
            publicationIds: const ['pub-1'],
            educationIds: const ['edu-1'],
          ),
        );

        final cv = StudioViewModel().resolvedCv;

        expect(
          cv.sections
              .whereType<ResolvedProjectsSection>()
              .first
              .items
              .single
              .link,
          'https://example.org/demo',
        );
        expect(
          cv.sections
              .whereType<ResolvedPublicationsSection>()
              .first
              .items
              .single
              .link,
          'https://example.org/paper',
        );
        expect(
          cv.sections
              .whereType<ResolvedEducationSection>()
              .first
              .items
              .single
              .yearLabel,
          '2011',
        );
      });

      test('an omitted link or year is gone from the document, while the '
          'Vault still has it for every other CV', () {
        when(vaultService.vault).thenReturn(
          vaultWith(
            projects: const [project],
            publications: const [paper],
            education: const [degree],
          ),
        );
        when(draftService.draft).thenReturn(
          draftWith(
            projectIds: const ['proj-1'],
            publicationIds: const ['pub-1'],
            educationIds: const ['edu-1'],
            omittedFields: const {
              DraftOmittableField.projectLink: ['proj-1'],
              DraftOmittableField.publicationLink: ['pub-1'],
              DraftOmittableField.educationYear: ['edu-1'],
            },
          ),
        );

        final model = StudioViewModel();
        final cv = model.resolvedCv;

        expect(
          cv.sections
              .whereType<ResolvedProjectsSection>()
              .first
              .items
              .single
              .link,
          isNull,
        );
        expect(
          cv.sections
              .whereType<ResolvedPublicationsSection>()
              .first
              .items
              .single
              .link,
          isNull,
        );
        expect(
          cv.sections
              .whereType<ResolvedEducationSection>()
              .first
              .items
              .single
              .yearLabel,
          isNull,
        );
        expect(vaultService.vault.projects.first.link, project.link);
        expect(vaultService.vault.education.first.year, 2011);
      });

      test("omitting one entry's field leaves another entry's alone — the "
          'list is per entity, not per section', () {
        const other = Project(
          id: 'proj-2',
          title: 'Other',
          link: 'https://example.org/other',
        );
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(projects: const [project, other]));
        when(draftService.draft).thenReturn(
          draftWith(
            projectIds: const ['proj-1', 'proj-2'],
            omittedFields: const {
              DraftOmittableField.projectLink: ['proj-1'],
            },
          ),
        );

        final items = StudioViewModel().resolvedCv.sections
            .whereType<ResolvedProjectsSection>()
            .first
            .items;

        expect(items.first.link, isNull);
        expect(items.last.link, 'https://example.org/other');
      });

      test('toggleFieldOmitted asks the service for the inverse of what is '
          'currently stored', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(projects: const [project]));
        when(draftService.draft).thenReturn(
          draftWith(
            projectIds: const ['proj-1'],
            omittedFields: const {
              DraftOmittableField.projectLink: ['proj-1'],
            },
          ),
        );
        when(
          draftService.setFieldOmitted(any, any, omitted: anyNamed('omitted')),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        expect(
          model.isFieldOmitted(DraftOmittableField.projectLink, 'proj-1'),
          isTrue,
        );

        await model.toggleFieldOmitted(
          DraftOmittableField.projectLink,
          'proj-1',
        );

        verify(
          draftService.setFieldOmitted(
            DraftOmittableField.projectLink,
            'proj-1',
            omitted: false,
          ),
        ).called(1);
      });
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

    test('a headline with no summary is still reachable — while the two '
        'shared an editor, this CV could not reach its headline at all', () {
      when(vaultService.vault).thenReturn(
        vaultWith(basics: ContactBasics.empty().copyWith(headline: 'Vault')),
      );
      when(draftService.draft).thenReturn(draftWith());

      final model = StudioViewModel();

      expect(model.hasHeadline, isTrue);
      // No summary text, so the Summary section has nothing behind it.
      expect(model.sectionHasData(CvSectionType.summary), isFalse);
    });

    test('opening the headline closes whichever section was open, and vice '
        'versa — one editor pane, two kinds of thing it can show', () {
      when(vaultService.vault).thenReturn(
        vaultWith(basics: ContactBasics.empty().copyWith(headline: 'Vault')),
      );
      when(draftService.draft).thenReturn(draftWith());

      final model = StudioViewModel()..selectSection(CvSectionType.skills);
      expect(model.isHeadlineOpen, isFalse);

      model.selectHeadline();
      expect(model.isHeadlineOpen, isTrue);
      expect(model.openSection, isNull);

      model.selectSection(CvSectionType.skills);
      expect(model.isHeadlineOpen, isFalse);
      expect(model.openSection, CvSectionType.skills);
    });

    test('no headline anywhere means no row to show', () {
      when(vaultService.vault).thenReturn(vaultWith());
      when(draftService.draft).thenReturn(draftWith());

      expect(StudioViewModel().hasHeadline, isFalse);
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
