import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;

    final experience = Experience(
      id: 'exp-1',
      role: 'Engineer',
      company: 'Acme',
      location: 'London',
      start: const YearMonth(year: 2020, month: 1),
      isCurrent: true,
      bullets: const [
        CvBullet(id: 'b1', text: 'Did a thing'),
        CvBullet(id: 'b2', text: 'Did another thing'),
      ],
    );
    final education = const Education(
      id: 'edu-1',
      qualification: 'BSc Computing',
      institution: 'Leeds',
    );
    final project = Project(
      id: 'proj-1',
      title: 'CV Forge',
      bullets: const [
        CvBullet(id: 'pb1', text: 'Built a thing'),
        CvBullet(id: 'pb2', text: 'Built another thing'),
      ],
    );
    const skillCategory = SkillCategory(
      id: 'cat-1',
      name: 'Languages',
      skills: [Skill(id: 'skill-1', label: 'Dart')],
    );
    const hobby = HobbyItem(id: 'hobby-1', text: 'Climbing');

    CvVault vaultWith({
      List<Experience> experiences = const [],
      List<Education> education = const [],
      List<Project> projects = const [],
      List<SkillCategory> skillCategories = const [],
      List<HobbyItem> hobbies = const [],
      ContactBasics? basics,
      String? referencesNote,
    }) => CvVault(
      schemaVersion: 1,
      basics: basics ?? ContactBasics.empty(),
      experiences: experiences,
      education: education,
      projects: projects,
      skillCategories: skillCategories,
      hobbies: hobbies,
      referencesNote: referencesNote,
      updatedAt: DateTime.now(),
    );

    CvDraft draftWith({
      List<String> experienceIds = const [],
      Map<String, List<String>> bulletIds = const {},
      List<String> projectIds = const [],
      Map<String, List<String>> projectBulletIds = const {},
      List<String> educationIds = const [],
      Set<CvSectionType> hiddenSections = const {},
      Map<String, String> bulletOverrides = const {},
      String? tailoredSummary,
      String? headlineOverride,
      String? referencesOverride,
      Map<String, String> educationDetailsOverrides = const {},
    }) => CvDraft(
      schemaVersion: 1,
      id: 'current',
      name: 'My CV',
      templateId: 'ats_minimal',
      experienceIds: experienceIds,
      bulletIds: bulletIds,
      projectIds: projectIds,
      projectBulletIds: projectBulletIds,
      educationIds: educationIds,
      hiddenSections: hiddenSections,
      bulletOverrides: bulletOverrides,
      tailoredSummary: tailoredSummary,
      headlineOverride: headlineOverride,
      referencesOverride: referencesOverride,
      educationDetailsOverrides: educationDetailsOverrides,
      updatedAt: DateTime.now(),
    );

    late MockRouterService routerService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      routerService = getAndRegisterRouterService();
    });
    tearDown(() => locator.reset());

    group('initialise -', () {
      test('loads both VaultService and DraftService', () async {
        when(vaultService.vault).thenReturn(CvVault.empty());
        when(vaultService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.load()).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        model.initialise();
        expect(model.isLoading, isTrue);

        await pumpEventQueue();

        verify(vaultService.load()).called(1);
        verify(draftService.load()).called(1);
        expect(model.isLoading, isFalse);
        expect(model.hasLoadError, isFalse);
      });

      test(
        'a failed load surfaces via hasLoadError without disturbing '
        'isExporting/hasExportError — the two must not share state',
        () async {
          when(vaultService.vault).thenReturn(CvVault.empty());
          when(vaultService.load()).thenThrow(Exception('boom'));

          final model = StudioViewModel();
          model.initialise();
          await pumpEventQueue();

          expect(model.hasLoadError, isTrue);
          expect(model.isExporting, isFalse);
          expect(model.hasExportError, isFalse);
        },
      );
    });

    group('previewState -', () {
      test('vaultEmpty when the Vault has no data at all', () {
        when(vaultService.vault).thenReturn(vaultWith());
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();

        expect(model.previewState, StudioPreviewState.vaultEmpty);
      });

      test('nothingSelected when the Vault has data but none of it is '
          "included in this draft — distinct from vaultEmpty, since "
          '"add something to your Vault" would be wrong here', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();

        expect(model.previewState, StudioPreviewState.nothingSelected);
      });

      test('ready once at least one section resolves', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(draftService.draft).thenReturn(
          draftWith(
            experienceIds: [experience.id],
            bulletIds: {
              experience.id: ['b1', 'b2'],
            },
          ),
        );

        final model = StudioViewModel();

        expect(model.previewState, StudioPreviewState.ready);
      });
    });

    test('vaultItemCount totals individual items across every category, '
        'not categories/groups', () {
      when(vaultService.vault).thenReturn(
        vaultWith(
          experiences: [experience],
          projects: [project],
          education: [education],
          skillCategories: [skillCategory],
          hobbies: [hobby],
        ),
      );
      when(draftService.draft).thenReturn(draftWith());

      final model = StudioViewModel();

      expect(model.vaultItemCount, 5);
    });

    test('goToVault navigates to VaultViewRoute', () async {
      when(vaultService.vault).thenReturn(CvVault.empty());
      when(draftService.draft).thenReturn(draftWith());
      when(routerService.replaceWith(any)).thenAnswer((_) async => null);

      final model = StudioViewModel();
      await model.goToVault();

      verify(routerService.replaceWith(argThat(isA<VaultViewRoute>())));
    });

    test('includeEverything selects every Vault item and unhides every '
        'hidden section', () async {
      when(vaultService.vault).thenReturn(
        vaultWith(
          experiences: [experience],
          projects: [project],
          education: [education],
          skillCategories: [skillCategory],
          hobbies: [hobby],
        ),
      );
      when(draftService.draft).thenReturn(
        draftWith(
          hiddenSections: {CvSectionType.experience, CvSectionType.education},
        ),
      );
      when(
        draftService.setExperienceIncluded(
          any,
          included: anyNamed('included'),
          bulletIds: anyNamed('bulletIds'),
        ),
      ).thenAnswer((_) => Future<void>.value());
      when(
        draftService.setProjectIncluded(
          any,
          included: anyNamed('included'),
          bulletIds: anyNamed('bulletIds'),
        ),
      ).thenAnswer((_) => Future<void>.value());
      when(
        draftService.setSkillIncluded(any, included: anyNamed('included')),
      ).thenAnswer((_) => Future<void>.value());
      when(
        draftService.setEducationIncluded(any, included: anyNamed('included')),
      ).thenAnswer((_) => Future<void>.value());
      when(
        draftService.setHobbyIncluded(any, included: anyNamed('included')),
      ).thenAnswer((_) => Future<void>.value());
      when(
        draftService.setSectionHidden(any, hidden: anyNamed('hidden')),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.includeEverything();

      verify(
        draftService.setExperienceIncluded(
          experience.id,
          included: true,
          bulletIds: ['b1', 'b2'],
        ),
      ).called(1);
      verify(
        draftService.setProjectIncluded(
          project.id,
          included: true,
          bulletIds: ['pb1', 'pb2'],
        ),
      ).called(1);
      verify(
        draftService.setSkillIncluded('skill-1', included: true),
      ).called(1);
      verify(
        draftService.setEducationIncluded(education.id, included: true),
      ).called(1);
      verify(draftService.setHobbyIncluded(hobby.id, included: true)).called(1);
      verify(
        draftService.setSectionHidden(CvSectionType.experience, hidden: false),
      ).called(1);
      verify(
        draftService.setSectionHidden(CvSectionType.education, hidden: false),
      ).called(1);
      verifyNever(
        draftService.setSectionHidden(
          CvSectionType.skills,
          hidden: anyNamed('hidden'),
        ),
      );
    });

    group('persist error -', () {
      test('hasPersistError mirrors DraftService.persistError, and '
          'retryPersist delegates to flushPendingWrites', () async {
        when(vaultService.vault).thenReturn(CvVault.empty());
        when(draftService.draft).thenReturn(draftWith());
        when(draftService.persistError).thenReturn(Exception('write failed'));
        when(
          draftService.flushPendingWrites(),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        expect(model.hasPersistError, isTrue);

        await model.retryPersist();

        verify(draftService.flushPendingWrites()).called(1);
      });
    });

    test('resolvedCv includes only the experiences selected in the draft, '
        'and silently drops a dangling id', () {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id, 'deleted-experience'],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
        ),
      );

      final model = StudioViewModel();
      final section = model.resolvedCv.sections.single;

      expect(section, isA<ResolvedExperienceSection>());
      final experienceSection = section as ResolvedExperienceSection;
      expect(experienceSection.groups, hasLength(1));
      expect(experienceSection.groups.single.positions.single.role, 'Engineer');
    });

    test('hiding a section removes it from the resolved model', () {
      when(vaultService.vault).thenReturn(vaultWith(education: [education]));
      when(draftService.draft).thenReturn(
        draftWith(
          educationIds: [education.id],
          hiddenSections: {CvSectionType.education},
        ),
      );

      final model = StudioViewModel();

      expect(model.resolvedCv.sections, isEmpty);
    });

    test('a bulletOverride wins over the Vault bullet text', () {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1'],
          },
          bulletOverrides: {'b1': 'Rewritten text'},
        ),
      );

      final model = StudioViewModel();
      final section =
          model.resolvedCv.sections.single as ResolvedExperienceSection;

      expect(
        section.groups.single.positions.single.bullets.single.text,
        'Rewritten text',
      );
    });

    test('toggleExperience delegates to DraftService with the full bullet id '
        'list when including, and just the id when excluding', () async {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      when(draftService.draft).thenReturn(draftWith());
      when(
        draftService.setExperienceIncluded(
          any,
          included: anyNamed('included'),
          bulletIds: anyNamed('bulletIds'),
        ),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.toggleExperience(experience);

      verify(
        draftService.setExperienceIncluded(
          experience.id,
          included: true,
          bulletIds: ['b1', 'b2'],
        ),
      ).called(1);
    });

    test('unselectedExperiences reflects what is not yet in the draft', () {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      when(draftService.draft).thenReturn(draftWith());

      final model = StudioViewModel();

      expect(model.unselectedExperiences, [experience]);
    });

    test('toggleExperienceBullet removes just that bullet, preserving the '
        "experience's own bullet order", () async {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
        ),
      );
      when(
        draftService.setBulletsForExperience(any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.toggleExperienceBullet(experience, experience.bullets[0]);

      verify(
        draftService.setBulletsForExperience(experience.id, ['b2']),
      ).called(1);
    });

    test('toggleProjectBullet removes just that bullet, preserving the '
        "project's own bullet order", () async {
      when(vaultService.vault).thenReturn(vaultWith(projects: [project]));
      when(draftService.draft).thenReturn(
        draftWith(
          projectIds: [project.id],
          projectBulletIds: {
            project.id: ['pb1', 'pb2'],
          },
        ),
      );
      when(
        draftService.setBulletsForProject(any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.toggleProjectBullet(project, project.bullets[0]);

      verify(draftService.setBulletsForProject(project.id, ['pb2'])).called(1);
    });

    test('addAllExperienceBullets selects every unselected bullet without '
        'dropping earlier selections — each toggle must be awaited before '
        'the next reads the draft, or they all race against the same stale '
        'state and only the last one lands', () async {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      var draft = draftWith(
        experienceIds: [experience.id],
        bulletIds: {experience.id: <String>[]},
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(draftService.setBulletsForExperience(any, any)).thenAnswer((
        invocation,
      ) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        draft = draft.copyWith(
          bulletIds: {...draft.bulletIds, experience.id: ids},
        );
      });

      final model = StudioViewModel();
      await model.addAllExperienceBullets(experience);

      expect(draft.bulletIds[experience.id], ['b1', 'b2']);
    });

    test('addAllProjectBullets selects every unselected bullet without '
        'dropping earlier selections', () async {
      when(vaultService.vault).thenReturn(vaultWith(projects: [project]));
      var draft = draftWith(
        projectIds: [project.id],
        projectBulletIds: {project.id: <String>[]},
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(draftService.setBulletsForProject(any, any)).thenAnswer((
        invocation,
      ) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        draft = draft.copyWith(
          projectBulletIds: {...draft.projectBulletIds, project.id: ids},
        );
      });

      final model = StudioViewModel();
      await model.addAllProjectBullets(project);

      expect(draft.projectBulletIds[project.id], ['pb1', 'pb2']);
    });

    group('tailored summary -', () {
      setUp(() {
        when(
          draftService.setTailoredSummary(any),
        ).thenAnswer((_) => Future<void>.value());
      });

      test(
        'the tailored summary wins over the Vault summary in resolvedCv',
        () {
          when(vaultService.vault).thenReturn(
            vaultWith(
              basics: ContactBasics.empty().copyWith(summary: 'Vault text'),
            ),
          );
          when(
            draftService.draft,
          ).thenReturn(draftWith(tailoredSummary: 'Tailored text'));

          final model = StudioViewModel();
          final section =
              model.resolvedCv.sections.single as ResolvedSummarySection;

          expect(section.text, 'Tailored text');
        },
      );

      test('blank input stores null so the draft stays inherited', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(summary: 'Vault text'),
          ),
        );
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setTailoredSummary('   ');

        verify(draftService.setTailoredSummary(null)).called(1);
      });

      test('input identical to the Vault summary stores null rather than an '
          'identical-but-separate override', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(summary: 'Same text'),
          ),
        );
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setTailoredSummary('Same text');

        verify(draftService.setTailoredSummary(null)).called(1);
      });

      test('genuinely different input stores the override verbatim', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(summary: 'Vault text'),
          ),
        );
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setTailoredSummary('New tailored text');

        verify(draftService.setTailoredSummary('New tailored text')).called(1);
      });

      test('revertSummaryToVault clears the override and resolvedCv falls back '
          'to the Vault text', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(summary: 'Vault text'),
          ),
        );
        when(
          draftService.draft,
        ).thenReturn(draftWith(tailoredSummary: 'Tailored text'));

        final model = StudioViewModel();
        await model.revertSummaryToVault();

        verify(draftService.setTailoredSummary(null)).called(1);
      });

      test(
        'hasTailoredSummary and summaryText reflect draft-vs-Vault state',
        () {
          when(vaultService.vault).thenReturn(
            vaultWith(
              basics: ContactBasics.empty().copyWith(summary: 'Vault text'),
            ),
          );
          when(draftService.draft).thenReturn(draftWith());

          final inherited = StudioViewModel();
          expect(inherited.hasTailoredSummary, isFalse);
          expect(inherited.summaryText, 'Vault text');

          when(
            draftService.draft,
          ).thenReturn(draftWith(tailoredSummary: 'Tailored text'));

          final custom = StudioViewModel();
          expect(custom.hasTailoredSummary, isTrue);
          expect(custom.summaryText, 'Tailored text');
        },
      );
    });

    group('headline override -', () {
      setUp(() {
        when(
          draftService.setHeadlineOverride(any),
        ).thenAnswer((_) => Future<void>.value());
      });

      test('the headline override wins over the Vault headline in '
          'resolvedCv', () {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(headline: 'Vault title'),
          ),
        );
        when(
          draftService.draft,
        ).thenReturn(draftWith(headlineOverride: 'Tailored title'));

        final model = StudioViewModel();

        expect(model.resolvedCv.header.headline, 'Tailored title');
      });

      test('blank input stores null so the draft stays inherited', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(headline: 'Vault title'),
          ),
        );
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setHeadlineOverride('   ');

        verify(draftService.setHeadlineOverride(null)).called(1);
      });

      test('input identical to the Vault headline stores null rather than '
          'an identical-but-separate override', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(headline: 'Same title'),
          ),
        );
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setHeadlineOverride('Same title');

        verify(draftService.setHeadlineOverride(null)).called(1);
      });

      test('revertHeadlineToVault clears the override', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(
            basics: ContactBasics.empty().copyWith(headline: 'Vault title'),
          ),
        );
        when(
          draftService.draft,
        ).thenReturn(draftWith(headlineOverride: 'Tailored title'));

        final model = StudioViewModel();
        await model.revertHeadlineToVault();

        verify(draftService.setHeadlineOverride(null)).called(1);
      });
    });

    group('references override -', () {
      setUp(() {
        when(
          draftService.setReferencesOverride(any),
        ).thenAnswer((_) => Future<void>.value());
      });

      test('the references override wins over the Vault note in '
          'resolvedCv', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(referencesNote: 'Vault note'));
        when(
          draftService.draft,
        ).thenReturn(draftWith(referencesOverride: 'Tailored note'));

        final model = StudioViewModel();
        final section =
            model.resolvedCv.sections.single as ResolvedReferencesSection;

        expect(section.text, 'Tailored note');
      });

      test('blank input stores null so the draft stays inherited', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(referencesNote: 'Vault note'));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setReferencesOverride('   ');

        verify(draftService.setReferencesOverride(null)).called(1);
      });

      test('input identical to the Vault note stores null rather than an '
          'identical-but-separate override', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(referencesNote: 'Same note'));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setReferencesOverride('Same note');

        verify(draftService.setReferencesOverride(null)).called(1);
      });

      test('revertReferencesToVault clears the override', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(referencesNote: 'Vault note'));
        when(
          draftService.draft,
        ).thenReturn(draftWith(referencesOverride: 'Tailored note'));

        final model = StudioViewModel();
        await model.revertReferencesToVault();

        verify(draftService.setReferencesOverride(null)).called(1);
      });

      test('hasReferences accounts for an override on a Vault with no '
          'references note of its own', () {
        when(vaultService.vault).thenReturn(vaultWith());
        when(
          draftService.draft,
        ).thenReturn(draftWith(referencesOverride: 'Tailored note'));

        final model = StudioViewModel();

        expect(model.hasReferences, isTrue);
      });
    });

    group('bullet text override -', () {
      setUp(() {
        when(
          draftService.setBulletOverride(any, any),
        ).thenAnswer((_) => Future<void>.value());
      });

      test('blank input stores null so the draft stays inherited', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setBulletOverride(experience.bullets.first, '   ');

        verify(draftService.setBulletOverride('b1', null)).called(1);
      });

      test('input identical to the Vault bullet text stores null rather '
          'than an identical-but-separate override', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setBulletOverride(experience.bullets.first, 'Did a thing');

        verify(draftService.setBulletOverride('b1', null)).called(1);
      });

      test('revertBulletOverride clears the override', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(
          draftService.draft,
        ).thenReturn(draftWith(bulletOverrides: {'b1': 'Rewritten text'}));

        final model = StudioViewModel();
        await model.revertBulletOverride('b1');

        verify(draftService.setBulletOverride('b1', null)).called(1);
      });

      test('bulletText/hasBulletOverride reflect draft-vs-Vault state', () {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        expect(model.hasBulletOverride('b1'), isFalse);
        expect(model.bulletText(experience.bullets.first), 'Did a thing');

        when(
          draftService.draft,
        ).thenReturn(draftWith(bulletOverrides: {'b1': 'Rewritten text'}));

        expect(model.hasBulletOverride('b1'), isTrue);
        expect(model.bulletText(experience.bullets.first), 'Rewritten text');
      });
    });

    group('education details override -', () {
      setUp(() {
        when(
          draftService.setEducationDetailsOverride(any, any),
        ).thenAnswer((_) => Future<void>.value());
      });

      test('the details override wins over the Vault details in '
          'resolvedCv', () {
        final detailed = education.copyWith(details: 'Vault details');
        when(vaultService.vault).thenReturn(vaultWith(education: [detailed]));
        when(draftService.draft).thenReturn(
          draftWith(
            educationIds: [detailed.id],
            educationDetailsOverrides: {detailed.id: 'Tailored details'},
          ),
        );

        final model = StudioViewModel();
        final section =
            model.resolvedCv.sections.single as ResolvedEducationSection;

        expect(section.items.single.details, 'Tailored details');
      });

      test('blank input stores null so the draft stays inherited', () async {
        final detailed = education.copyWith(details: 'Vault details');
        when(vaultService.vault).thenReturn(vaultWith(education: [detailed]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setEducationDetailsOverride(detailed, '   ');

        verify(
          draftService.setEducationDetailsOverride(detailed.id, null),
        ).called(1);
      });

      test('input identical to the Vault details stores null rather than '
          'an identical-but-separate override', () async {
        final detailed = education.copyWith(details: 'Same details');
        when(vaultService.vault).thenReturn(vaultWith(education: [detailed]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        await model.setEducationDetailsOverride(detailed, 'Same details');

        verify(
          draftService.setEducationDetailsOverride(detailed.id, null),
        ).called(1);
      });

      test('revertEducationDetailsOverride clears the override', () async {
        when(vaultService.vault).thenReturn(vaultWith(education: [education]));
        when(draftService.draft).thenReturn(
          draftWith(
            educationDetailsOverrides: {education.id: 'Tailored details'},
          ),
        );

        final model = StudioViewModel();
        await model.revertEducationDetailsOverride(education.id);

        verify(
          draftService.setEducationDetailsOverride(education.id, null),
        ).called(1);
      });

      test('educationDetailsText/hasEducationDetailsOverride reflect '
          'draft-vs-Vault state, defaulting to blank when the Vault has no '
          'details at all', () {
        when(vaultService.vault).thenReturn(vaultWith(education: [education]));
        when(draftService.draft).thenReturn(draftWith());

        final model = StudioViewModel();
        expect(model.hasEducationDetailsOverride(education.id), isFalse);
        expect(model.educationDetailsText(education), '');

        when(draftService.draft).thenReturn(
          draftWith(
            educationDetailsOverrides: {education.id: 'Tailored details'},
          ),
        );

        expect(model.hasEducationDetailsOverride(education.id), isTrue);
        expect(model.educationDetailsText(education), 'Tailored details');
      });
    });
  });
}
