import 'package:cv_forge/app/app.locator.dart';
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
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests - selection -', () {
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
      String templateId = 'ats_minimal',
    }) => CvDraft(
      schemaVersion: 1,
      id: 'current',
      name: 'My CV',
      templateId: templateId,
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

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      // Not read by any test in this file, but still needed: StudioViewModel's
      // constructor resolves both eagerly via locator regardless of which
      // tests actually exercise navigation/dialogs.
      getAndRegisterRouterService();
      getAndRegisterDialogService();
    });
    tearDown(() => locator.reset());

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

    test('resolvedCv follows the active template\'s own sectionOrder, not '
        'one global order — switching template reorders sections with no '
        'draft-side change', () {
      when(vaultService.vault).thenReturn(
        vaultWith(experiences: [experience], education: [education]),
      );
      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
          educationIds: [education.id],
        ),
      );

      final atsMinimalOrder = StudioViewModel().resolvedCv.sections
          .map((s) => s.runtimeType)
          .toList();
      expect(atsMinimalOrder, [
        ResolvedExperienceSection,
        ResolvedEducationSection,
      ]);

      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
          educationIds: [education.id],
          templateId: 'structured_serif',
        ),
      );

      final structuredSerifOrder = StudioViewModel().resolvedCv.sections
          .map((s) => s.runtimeType)
          .toList();
      expect(structuredSerifOrder, [
        ResolvedEducationSection,
        ResolvedExperienceSection,
      ]);
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
  });
}
