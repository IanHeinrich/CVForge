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
import 'package:cv_forge/models/vault/project.dart';
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

    CvVault vaultWith({
      List<Experience> experiences = const [],
      List<Education> education = const [],
      List<Project> projects = const [],
    }) => CvVault(
      schemaVersion: 1,
      basics: ContactBasics.empty(),
      experiences: experiences,
      education: education,
      projects: projects,
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
      updatedAt: DateTime.now(),
    );

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterTemplateRegistryService();
    });
    tearDown(() => locator.reset());

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
  });
}
