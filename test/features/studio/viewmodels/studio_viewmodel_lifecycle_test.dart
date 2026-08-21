import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/features/studio/dialogs/edit_draft/edit_draft_dialog_data.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
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
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests - lifecycle -', () {
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
      templateId: 'compact',
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
    late MockDialogService dialogService;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      routerService = getAndRegisterRouterService();
      dialogService = getAndRegisterDialogService();
    });
    tearDown(() => locator.reset());

    group('initialise -', () {
      test('loads both VaultService and DraftService', () async {
        when(vaultService.vault).thenReturn(CvVault.empty());
        when(vaultService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.draft).thenReturn(draftWith());
        when(
          draftService.hasCopilotUndoFor(any),
        ).thenAnswer((_) async => false);

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

      test('a fresh draft (never before persisted) is populated from the '
          'Vault once loaded', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience], hobbies: [hobby]));
        when(vaultService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.isFreshDraft).thenReturn(true);
        when(
          draftService.selectAllFromVault(
            experienceIds: anyNamed('experienceIds'),
            bulletIds: anyNamed('bulletIds'),
            projectIds: anyNamed('projectIds'),
            projectBulletIds: anyNamed('projectBulletIds'),
            skillIds: anyNamed('skillIds'),
            educationIds: anyNamed('educationIds'),
            hobbyIds: anyNamed('hobbyIds'),
            publicationIds: anyNamed('publicationIds'),
          ),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        model.initialise();
        await pumpEventQueue();

        verify(
          draftService.selectAllFromVault(
            experienceIds: [experience.id],
            bulletIds: {
              experience.id: ['b1', 'b2'],
            },
            projectIds: [],
            projectBulletIds: {},
            skillIds: [],
            educationIds: [],
            hobbyIds: [hobby.id],
            publicationIds: [],
          ),
        ).called(1);
      });

      test('a non-fresh draft is left as-is', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(experiences: [experience]));
        when(vaultService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.load()).thenAnswer((_) => Future<void>.value());
        when(draftService.isFreshDraft).thenReturn(false);

        final model = StudioViewModel();
        model.initialise();
        await pumpEventQueue();

        verifyNever(
          draftService.selectAllFromVault(
            experienceIds: anyNamed('experienceIds'),
            bulletIds: anyNamed('bulletIds'),
            projectIds: anyNamed('projectIds'),
            projectBulletIds: anyNamed('projectBulletIds'),
            skillIds: anyNamed('skillIds'),
            educationIds: anyNamed('educationIds'),
            hobbyIds: anyNamed('hobbyIds'),
            publicationIds: anyNamed('publicationIds'),
          ),
        );
      });
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

    test('goToDrafts navigates to DraftsListViewRoute', () async {
      when(vaultService.vault).thenReturn(CvVault.empty());
      when(draftService.draft).thenReturn(draftWith());
      when(routerService.replaceWith(any)).thenAnswer((_) async => null);

      final model = StudioViewModel();
      await model.goToDrafts();

      verify(routerService.replaceWith(argThat(isA<DraftsListViewRoute>())));
    });

    test('draftName/draftNotes read through to the active draft', () {
      when(vaultService.vault).thenReturn(CvVault.empty());
      when(
        draftService.draft,
      ).thenReturn(draftWith().copyWith(name: 'Acme CV', notes: 'For Acme'));

      final model = StudioViewModel();

      expect(model.draftName, 'Acme CV');
      expect(model.draftNotes, 'For Acme');
    });

    group('editDraftDetails -', () {
      test(
        'confirming updates the draft via DraftService.updateDraftDetails',
        () async {
          when(vaultService.vault).thenReturn(CvVault.empty());
          when(
            draftService.draft,
          ).thenReturn(draftWith().copyWith(name: 'Old name', notes: ''));
          when(
            dialogService.showCustomDialog(
              variant: anyNamed('variant'),
              title: anyNamed('title'),
              data: anyNamed('data'),
              mainButtonTitle: anyNamed('mainButtonTitle'),
              secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
            ),
          ).thenAnswer(
            (_) async => DialogResponse<EditDraftDialogData>(
              confirmed: true,
              data: const EditDraftDialogData(
                name: 'New name',
                notes: 'New notes',
              ),
            ),
          );
          when(
            draftService.updateDraftDetails(
              any,
              name: anyNamed('name'),
              notes: anyNamed('notes'),
            ),
          ).thenAnswer((_) => Future<void>.value());

          final model = StudioViewModel();
          await model.editDraftDetails();

          verify(
            draftService.updateDraftDetails(
              'current',
              name: 'New name',
              notes: 'New notes',
            ),
          ).called(1);
        },
      );

      test('cancelling updates nothing', () async {
        when(vaultService.vault).thenReturn(CvVault.empty());
        when(draftService.draft).thenReturn(draftWith());
        when(
          dialogService.showCustomDialog(
            variant: anyNamed('variant'),
            title: anyNamed('title'),
            data: anyNamed('data'),
            mainButtonTitle: anyNamed('mainButtonTitle'),
            secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
          ),
        ).thenAnswer(
          (_) async => DialogResponse<EditDraftDialogData>(confirmed: false),
        );

        final model = StudioViewModel();
        await model.editDraftDetails();

        verifyNever(
          draftService.updateDraftDetails(
            any,
            name: anyNamed('name'),
            notes: anyNamed('notes'),
          ),
        );
      });
    });

    test('includeEverything selects every Vault item — including every '
        'bullet of every included experience/project, not just the '
        'top-level entries — and unhides every hidden section', () async {
      when(vaultService.vault).thenReturn(
        vaultWith(
          experiences: [experience],
          projects: [project],
          education: [education],
          skillCategories: [skillCategory],
          hobbies: [hobby],
        ),
      );
      // A mutable stand-in for the real DraftService's state, not a static
      // stub — includeEverything's bullet-level follow-up
      // (addAllExperienceBullets/addAllProjectBullets) reads the draft
      // fresh after each top-level toggle, so the stub must actually
      // reflect prior calls in this test the same way it does in
      // `addAllExperienceBullets`'s own test above.
      var draft = draftWith(
        hiddenSections: {CvSectionType.experience, CvSectionType.education},
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(
        draftService.setExperienceIncluded(
          any,
          included: anyNamed('included'),
          bulletIds: anyNamed('bulletIds'),
        ),
      ).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        final bulletIds = invocation.namedArguments[#bulletIds] as List<String>;
        draft = draft.copyWith(
          experienceIds: [...draft.experienceIds, id],
          bulletIds: {...draft.bulletIds, id: bulletIds},
        );
      });
      when(
        draftService.setProjectIncluded(
          any,
          included: anyNamed('included'),
          bulletIds: anyNamed('bulletIds'),
        ),
      ).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        final bulletIds = invocation.namedArguments[#bulletIds] as List<String>;
        draft = draft.copyWith(
          projectIds: [...draft.projectIds, id],
          projectBulletIds: {...draft.projectBulletIds, id: bulletIds},
        );
      });
      when(draftService.setBulletsForExperience(any, any)).thenAnswer((
        invocation,
      ) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        draft = draft.copyWith(
          bulletIds: {...draft.bulletIds, experience.id: ids},
        );
      });
      when(draftService.setBulletsForProject(any, any)).thenAnswer((
        invocation,
      ) async {
        final ids = invocation.positionalArguments[1] as List<String>;
        draft = draft.copyWith(
          projectBulletIds: {...draft.projectBulletIds, project.id: ids},
        );
      });
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

      expect(draft.experienceIds, [experience.id]);
      expect(draft.bulletIds[experience.id], ['b1', 'b2']);
      expect(draft.projectIds, [project.id]);
      expect(draft.projectBulletIds[project.id], ['pb1', 'pb2']);
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
  });
}
