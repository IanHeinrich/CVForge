import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/vault/bullet_owner.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/models/region/region_profile.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/document_defaults.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests - selection -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;

    const experience = sampleExperience;
    const education = sampleEducation;
    const project = sampleProject;
    const publication = samplePublication;

    setUp(() {
      vaultService = getAndRegisterVaultService();
      draftService = getAndRegisterDraftService();
      getAndRegisterSettingsService();
      getAndRegisterTemplateRegistryService();
      getAndRegisterPdfExportService();
      // Not read by any test in this file, but still needed: StudioViewModel's
      // constructor resolves both eagerly via locator regardless of which
      // tests actually exercise navigation/dialogs.
      getAndRegisterRouterService();
      getAndRegisterDialogService();
      getAndRegisterLocalizationService();
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

    test('a UK draft and a US draft produce the same dateRange string — '
        'RegionPreset.dateStyle is RegionDateStyle.monYyyy for both today, '
        'but CvComposer switches on that seam rather than on RegionProfile '
        'directly, so this covers it before a third style diverges', () {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));

      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
          region: RegionProfile.uk,
        ),
      );
      final ukSection =
          StudioViewModel().resolvedCv.sections.single
              as ResolvedExperienceSection;
      expect(
        ukSection.groups.single.positions.single.dateRange,
        'Jan 2020 - Present',
      );

      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
          region: RegionProfile.us,
        ),
      );
      final usSection =
          StudioViewModel().resolvedCv.sections.single
              as ResolvedExperienceSection;
      expect(
        usSection.groups.single.positions.single.dateRange,
        'Jan 2020 - Present',
      );
    });

    test('resolvedCv follows the draft\'s own sectionOrder, not the active '
        'template\'s — switching template never reorders it', () {
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
          sectionOrder: const [
            CvSectionType.education,
            CvSectionType.experience,
            CvSectionType.skills,
            CvSectionType.projects,
            CvSectionType.summary,
            CvSectionType.hobbies,
            CvSectionType.references,
            CvSectionType.publications,
          ],
          templateId: 'compact',
        ),
      );

      final compactOrder = StudioViewModel().resolvedCv.sections
          .map((s) => s.runtimeType)
          .toList();
      expect(compactOrder, [
        ResolvedEducationSection,
        ResolvedExperienceSection,
      ]);

      when(draftService.draft).thenReturn(
        draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1', 'b2'],
          },
          educationIds: [education.id],
          sectionOrder: const [
            CvSectionType.education,
            CvSectionType.experience,
            CvSectionType.skills,
            CvSectionType.projects,
            CvSectionType.summary,
            CvSectionType.hobbies,
            CvSectionType.references,
            CvSectionType.publications,
          ],
          templateId: 'classic_centered',
        ),
      );

      final classicCenteredOrder = StudioViewModel().resolvedCv.sections
          .map((s) => s.runtimeType)
          .toList();
      expect(classicCenteredOrder, [
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

    // Stands in for the identical one-line removeAllX delegators on
    // projects/education/hobbies/publications — all of them share
    // _Selection.removeAll, so one test of the mechanism covers every
    // collection.
    test('removeAllExperiences excludes every currently-included '
        'experience, one at a time', () async {
      final second = experience.copyWith(id: 'exp-2');
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(experiences: [experience, second]));
      var draft = draftWith(experienceIds: [experience.id, second.id]);
      when(draftService.draft).thenAnswer((_) => draft);
      when(
        draftService.setExperienceIncluded(
          any,
          included: anyNamed('included'),
          bulletIds: anyNamed('bulletIds'),
        ),
      ).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as String;
        draft = draft.copyWith(
          experienceIds: draft.experienceIds.where((e) => e != id).toList(),
        );
      });

      final model = StudioViewModel();
      await model.removeAllExperiences();

      expect(draft.experienceIds, isEmpty);
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
        draftService.setBulletIds(BulletOwner.experience, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.toggleExperienceBullet(experience, experience.bullets[0]);

      verify(
        draftService.setBulletIds(BulletOwner.experience, experience.id, [
          'b2',
        ]),
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
        draftService.setBulletIds(BulletOwner.project, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.toggleProjectBullet(project, project.bullets[0]);

      verify(
        draftService.setBulletIds(BulletOwner.project, project.id, ['pb2']),
      ).called(1);
    });

    // Each toggle must be awaited before the next reads the draft, or
    // they all race against the same stale state and only the last one
    // lands — this is the sequential-await regression this test catches.
    test('addAllExperienceBullets selects every unselected bullet without '
        'dropping earlier selections', () async {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      var draft = draftWith(
        experienceIds: [experience.id],
        bulletIds: {experience.id: <String>[]},
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(
        draftService.setBulletIds(BulletOwner.experience, any, any),
      ).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[2] as List<String>;
        draft = draft.copyWith(
          bulletIds: {...draft.bulletIds, experience.id: ids},
        );
      });

      final model = StudioViewModel();
      await model.addAllExperienceBullets(experience);

      expect(draft.bulletIds[experience.id], ['b1', 'b2']);
    });

    test('removeAllExperienceBullets is addAllExperienceBullets\' inverse, '
        'with the same sequential-await requirement', () async {
      when(vaultService.vault).thenReturn(vaultWith(experiences: [experience]));
      var draft = draftWith(
        experienceIds: [experience.id],
        bulletIds: {
          experience.id: ['b1', 'b2'],
        },
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(
        draftService.setBulletIds(BulletOwner.experience, any, any),
      ).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[2] as List<String>;
        draft = draft.copyWith(
          bulletIds: {...draft.bulletIds, experience.id: ids},
        );
      });

      final model = StudioViewModel();
      await model.removeAllExperienceBullets(experience);

      expect(draft.bulletIds[experience.id], isEmpty);
    });

    test('addAllProjectBullets selects every unselected bullet without '
        'dropping earlier selections', () async {
      when(vaultService.vault).thenReturn(vaultWith(projects: [project]));
      var draft = draftWith(
        projectIds: [project.id],
        projectBulletIds: {project.id: <String>[]},
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(draftService.setBulletIds(BulletOwner.project, any, any)).thenAnswer(
        (invocation) async {
          final ids = invocation.positionalArguments[2] as List<String>;
          draft = draft.copyWith(
            projectBulletIds: {...draft.projectBulletIds, project.id: ids},
          );
        },
      );

      final model = StudioViewModel();
      await model.addAllProjectBullets(project);

      expect(draft.projectBulletIds[project.id], ['pb1', 'pb2']);
    });

    test('removeAllProjectBullets is addAllProjectBullets\' inverse', () async {
      when(vaultService.vault).thenReturn(vaultWith(projects: [project]));
      var draft = draftWith(
        projectIds: [project.id],
        projectBulletIds: {
          project.id: ['pb1', 'pb2'],
        },
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(draftService.setBulletIds(BulletOwner.project, any, any)).thenAnswer(
        (invocation) async {
          final ids = invocation.positionalArguments[2] as List<String>;
          draft = draft.copyWith(
            projectBulletIds: {...draft.projectBulletIds, project.id: ids},
          );
        },
      );

      final model = StudioViewModel();
      await model.removeAllProjectBullets(project);

      expect(draft.projectBulletIds[project.id], isEmpty);
    });

    test('togglePublicationBullet removes just that bullet, preserving the '
        "publication's own bullet order", () async {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(publications: [publication]));
      when(draftService.draft).thenReturn(
        draftWith(
          publicationIds: [publication.id],
          publicationBulletIds: {
            publication.id: ['ub1', 'ub2'],
          },
        ),
      );
      when(
        draftService.setBulletIds(BulletOwner.publication, any, any),
      ).thenAnswer((_) => Future<void>.value());

      final model = StudioViewModel();
      await model.togglePublicationBullet(publication, publication.bullets[0]);

      verify(
        draftService.setBulletIds(BulletOwner.publication, publication.id, [
          'ub2',
        ]),
      ).called(1);
    });

    test('addAllPublicationBullets selects every unselected bullet without '
        'dropping earlier selections', () async {
      when(
        vaultService.vault,
      ).thenReturn(vaultWith(publications: [publication]));
      var draft = draftWith(
        publicationIds: [publication.id],
        publicationBulletIds: {publication.id: <String>[]},
      );
      when(draftService.draft).thenAnswer((_) => draft);
      when(
        draftService.setBulletIds(BulletOwner.publication, any, any),
      ).thenAnswer((invocation) async {
        final ids = invocation.positionalArguments[2] as List<String>;
        draft = draft.copyWith(
          publicationBulletIds: {
            ...draft.publicationBulletIds,
            publication.id: ids,
          },
        );
      });

      final model = StudioViewModel();
      await model.addAllPublicationBullets(publication);

      expect(draft.publicationBulletIds[publication.id], ['ub1', 'ub2']);
    });

    test(
      'removeAllPublicationBullets is addAllPublicationBullets\' inverse',
      () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(publications: [publication]));
        var draft = draftWith(
          publicationIds: [publication.id],
          publicationBulletIds: {
            publication.id: ['ub1', 'ub2'],
          },
        );
        when(draftService.draft).thenAnswer((_) => draft);
        when(
          draftService.setBulletIds(BulletOwner.publication, any, any),
        ).thenAnswer((invocation) async {
          final ids = invocation.positionalArguments[2] as List<String>;
          draft = draft.copyWith(
            publicationBulletIds: {
              ...draft.publicationBulletIds,
              publication.id: ids,
            },
          );
        });

        final model = StudioViewModel();
        await model.removeAllPublicationBullets(publication);

        expect(draft.publicationBulletIds[publication.id], isEmpty);
      },
    );

    group('skills -', () {
      final skillCategoryA = SkillCategory(
        id: 'cat-a',
        name: 'Languages',
        skills: const [
          Skill(id: 's1', label: 'Dart', linkedBulletIds: ['b1']),
          Skill(id: 's2', label: 'Python'),
          Skill(id: 's3', label: 'Go'),
        ],
      );
      final skillCategoryB = SkillCategory(
        id: 'cat-b',
        name: 'Cloud',
        skills: const [Skill(id: 's4', label: 'AWS')],
      );

      void stubMutableSkillIds(
        CvDraft Function() draftGetter,
        void Function(CvDraft) setDraft,
      ) {
        when(
          draftService.setSkillIncluded(any, included: anyNamed('included')),
        ).thenAnswer((invocation) async {
          final id = invocation.positionalArguments[0] as String;
          final included = invocation.namedArguments[#included] as bool;
          final ids = {...draftGetter().skillIds};
          if (included) {
            ids.add(id);
          } else {
            ids.remove(id);
          }
          setDraft(draftGetter().copyWith(skillIds: ids.toList()));
        });
      }

      // Same sequential-await requirement as addAllExperienceBullets: a
      // category of three only ends up with all three ids if each toggle
      // is awaited before the next reads the draft.
      test('addAllSkillsInCategory selects only that category\'s skills and '
          'leaves other categories untouched', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(skillCategories: [skillCategoryA, skillCategoryB]),
        );
        var draft = draftWith(skillIds: const ['s4']);
        when(draftService.draft).thenAnswer((_) => draft);
        stubMutableSkillIds(() => draft, (d) => draft = d);

        final model = StudioViewModel();
        await model.addAllSkillsInCategory(skillCategoryA);

        expect(draft.skillIds, containsAll(['s1', 's2', 's3', 's4']));
        expect(draft.skillIds, hasLength(4));
      });

      test('removeAllSkillsInCategory is its inverse and does not disturb '
          'manual selections elsewhere', () async {
        when(vaultService.vault).thenReturn(
          vaultWith(skillCategories: [skillCategoryA, skillCategoryB]),
        );
        var draft = draftWith(skillIds: const ['s1', 's2', 's3', 's4']);
        when(draftService.draft).thenAnswer((_) => draft);
        stubMutableSkillIds(() => draft, (d) => draft = d);

        final model = StudioViewModel();
        await model.removeAllSkillsInCategory(skillCategoryA);

        expect(draft.skillIds, ['s4']);
      });

      test('selectEvidencedSkills selects a skill linked to an included '
          'bullet, does not select one linked only to an excluded bullet, '
          'and does not deselect a manually-selected unlinked skill', () async {
        const evidenced = Skill(
          id: 's-evidenced',
          label: 'Dart',
          linkedBulletIds: ['b1'],
        );
        const manual = Skill(id: 's-manual', label: 'Manual');
        const excluded = Skill(
          id: 's-excluded',
          label: 'Excluded',
          linkedBulletIds: ['pb2'],
        );
        const category = SkillCategory(
          id: 'cat',
          name: 'Cat',
          skills: [evidenced, manual, excluded],
        );
        when(vaultService.vault).thenReturn(
          vaultWith(
            experiences: [experience],
            projects: [project],
            skillCategories: [category],
          ),
        );
        // `project` is deliberately NOT in `projectIds` — its
        // `projectBulletIds` entry exists but must not count, proving the
        // included-bullet set is restricted to entries that are
        // themselves included.
        var draft = draftWith(
          experienceIds: [experience.id],
          bulletIds: {
            experience.id: ['b1'],
          },
          projectBulletIds: {
            project.id: ['pb1', 'pb2'],
          },
          skillIds: const ['s-manual'],
        );
        when(draftService.draft).thenAnswer((_) => draft);
        stubMutableSkillIds(() => draft, (d) => draft = d);

        final model = StudioViewModel();
        await model.selectEvidencedSkills();

        expect(draft.skillIds, containsAll(['s-manual', 's-evidenced']));
        expect(draft.skillIds, isNot(contains('s-excluded')));
        expect(draft.skillIds, hasLength(2));
      });

      test('hasAnyLinkedSkills is false when no skill in the Vault has a '
          'linkedBulletIds entry, true as soon as one does', () async {
        when(
          vaultService.vault,
        ).thenReturn(vaultWith(skillCategories: [skillCategoryB]));
        when(draftService.draft).thenAnswer((_) => draftWith());

        final unlinkedModel = StudioViewModel();
        expect(unlinkedModel.hasAnyLinkedSkills, isFalse);

        when(vaultService.vault).thenReturn(
          vaultWith(skillCategories: [skillCategoryA, skillCategoryB]),
        );
        final linkedModel = StudioViewModel();
        expect(linkedModel.hasAnyLinkedSkills, isTrue);
      });

      test('evidenceCountFor counts only a skill\'s linked bullets that are '
          'themselves included in the draft, restricted to entries that are '
          'themselves included', () async {
        const skill = Skill(
          id: 's-multi',
          label: 'Dart',
          linkedBulletIds: ['b1', 'b2', 'pb2'],
        );
        when(vaultService.vault).thenReturn(
          vaultWith(
            experiences: [experience],
            projects: [project],
            skillCategories: [
              SkillCategory(id: 'cat', name: 'Cat', skills: const [skill]),
            ],
          ),
        );
        // `project` is deliberately NOT in `projectIds` — its
        // `projectBulletIds` entry exists but must not count, same rule
        // as `_includedBulletIds` itself.
        when(draftService.draft).thenAnswer(
          (_) => draftWith(
            experienceIds: [experience.id],
            bulletIds: {
              experience.id: ['b1'],
            },
            projectBulletIds: {
              project.id: ['pb2'],
            },
          ),
        );

        final model = StudioViewModel();

        expect(model.evidenceCountFor(skill), 1);
      });
    });

    group('section order -', () {
      test(
        'reorderSections moves within the visible (sectionHasData) '
        'subsequence, appending no-data sections unchanged at the end',
        () async {
          when(vaultService.vault).thenReturn(
            vaultWith(experiences: [experience], education: [education]),
          );
          when(draftService.draft).thenReturn(
            draftWith(
              experienceIds: [experience.id],
              educationIds: [education.id],
            ),
          );
          when(
            draftService.setSectionOrder(any),
          ).thenAnswer((_) => Future<void>.value());

          final model = StudioViewModel();
          await model.reorderSections(0, 1);

          verify(
            draftService.setSectionOrder([
              CvSectionType.education,
              CvSectionType.experience,
              CvSectionType.summary,
              CvSectionType.skills,
              CvSectionType.languages,
              CvSectionType.projects,
              CvSectionType.hobbies,
              CvSectionType.references,
              CvSectionType.publications,
            ]),
          ).called(1);
        },
      );

      test("resetSectionSettings hands DraftService the Vault's defaults, "
          'rather than having it reach for them itself', () async {
        const defaults = DocumentDefaults(
          sectionOrder: [CvSectionType.skills, CvSectionType.summary],
        );
        when(
          vaultService.vault,
        ).thenReturn(CvVault.empty().copyWith(documentDefaults: defaults));
        when(draftService.draft).thenReturn(draftWith());
        when(
          draftService.resetSectionSettings(any),
        ).thenAnswer((_) => Future<void>.value());
        // Confirmed first, like the wording reset beside it — neither can
        // be undone.
        final dialogService = getAndRegisterDialogService();
        when(
          dialogService.showDialog(
            title: anyNamed('title'),
            description: anyNamed('description'),
            buttonTitle: anyNamed('buttonTitle'),
            cancelTitle: anyNamed('cancelTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse<dynamic>(confirmed: true));

        final model = StudioViewModel();
        await model.resetSectionSettings();

        verify(draftService.resetSectionSettings(defaults)).called(1);
      });

      test('a declined confirmation leaves the arrangement alone', () async {
        when(vaultService.vault).thenReturn(CvVault.empty());
        when(draftService.draft).thenReturn(draftWith());
        final dialogService = getAndRegisterDialogService();
        when(
          dialogService.showDialog(
            title: anyNamed('title'),
            description: anyNamed('description'),
            buttonTitle: anyNamed('buttonTitle'),
            cancelTitle: anyNamed('cancelTitle'),
          ),
        ).thenAnswer((_) async => DialogResponse<dynamic>(confirmed: false));

        final model = StudioViewModel();
        await model.resetSectionSettings();

        verifyNever(draftService.resetSectionSettings(any));
      });
    });

    group('education bullets -', () {
      // `sampleEducation` has none, and deliberately stays that way: every
      // other test in this file composes it and would start printing
      // bullets it does not expect.
      const schooled = Education(
        id: 'edu-2',
        qualification: 'MSc Distributed Systems',
        institution: 'Leeds',
        bullets: [
          CvBullet(id: 'eb1', text: 'Dissertation on consensus'),
          CvBullet(id: 'eb2', text: 'Ran the systems reading group'),
        ],
      );

      List<String> printedBullets(StudioViewModel model) {
        final section =
            model.resolvedCv.sections.single as ResolvedEducationSection;
        return [for (final b in section.items.single.bullets) b.text];
      }

      test('a draft saved before education bullets were selectable still '
          'prints every one of them — an absent map means all, not none, '
          'or upgrading would silently strip them from every CV already '
          'made', () {
        when(vaultService.vault).thenReturn(vaultWith(education: [schooled]));
        when(
          draftService.draft,
        ).thenReturn(draftWith(educationIds: [schooled.id]));

        final model = StudioViewModel();

        expect(printedBullets(model), [
          'Dissertation on consensus',
          'Ran the systems reading group',
        ]);
        expect(model.isEducationBulletIncluded(schooled.id, 'eb1'), isTrue);
        expect(model.isEducationBulletIncluded(schooled.id, 'eb2'), isTrue);
      });

      test('an explicitly empty list means none, so a user who clears an '
          "entry's bullets is not handed them all back", () {
        when(vaultService.vault).thenReturn(vaultWith(education: [schooled]));
        when(draftService.draft).thenReturn(
          draftWith(
            educationIds: [schooled.id],
            educationBulletIds: {schooled.id: <String>[]},
          ),
        );

        final model = StudioViewModel();

        expect(printedBullets(model), isEmpty);
        expect(model.isEducationBulletIncluded(schooled.id, 'eb1'), isFalse);
      });

      test('toggleEducationBullet removes just that bullet, preserving the '
          "entry's own bullet order", () async {
        when(vaultService.vault).thenReturn(vaultWith(education: [schooled]));
        when(draftService.draft).thenReturn(
          draftWith(
            educationIds: [schooled.id],
            educationBulletIds: {
              schooled.id: ['eb1', 'eb2'],
            },
          ),
        );
        when(
          draftService.setBulletIds(BulletOwner.education, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        await model.toggleEducationBullet(schooled, schooled.bullets[0]);

        verify(
          draftService.setBulletIds(BulletOwner.education, schooled.id, [
            'eb2',
          ]),
        ).called(1);
      });

      test('toggling a bullet on a draft with no map yet writes the rest of '
          'them back explicitly, so the absent-means-all default cannot '
          'quietly restore what was just deselected', () async {
        when(vaultService.vault).thenReturn(vaultWith(education: [schooled]));
        when(
          draftService.draft,
        ).thenReturn(draftWith(educationIds: [schooled.id]));
        when(
          draftService.setBulletIds(BulletOwner.education, any, any),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        await model.toggleEducationBullet(schooled, schooled.bullets[0]);

        verify(
          draftService.setBulletIds(BulletOwner.education, schooled.id, [
            'eb2',
          ]),
        ).called(1);
      });

      test('removeAllEducationBullets clears the entry down to an explicit '
          'empty selection', () async {
        when(vaultService.vault).thenReturn(vaultWith(education: [schooled]));
        var draft = draftWith(
          educationIds: [schooled.id],
          educationBulletIds: {
            schooled.id: ['eb1', 'eb2'],
          },
        );
        when(draftService.draft).thenAnswer((_) => draft);
        when(
          draftService.setBulletIds(BulletOwner.education, any, any),
        ).thenAnswer((invocation) async {
          draft = draft.copyWith(
            educationBulletIds: {
              schooled.id: invocation.positionalArguments[2] as List<String>,
            },
          );
        });

        final model = StudioViewModel();
        await model.removeAllEducationBullets(schooled);

        expect(draft.educationBulletIds[schooled.id], isEmpty);
      });

      test('including an education entry seeds every one of its bullets, so '
          'it arrives in the draft looking like the Vault entry it came '
          'from', () async {
        when(vaultService.vault).thenReturn(vaultWith(education: [schooled]));
        when(draftService.draft).thenReturn(draftWith());
        when(
          draftService.setEducationIncluded(
            any,
            included: anyNamed('included'),
            bulletIds: anyNamed('bulletIds'),
          ),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        await model.toggleEducation(schooled);

        verify(
          draftService.setEducationIncluded(
            schooled.id,
            included: true,
            bulletIds: ['eb1', 'eb2'],
          ),
        ).called(1);
      });

      test('an included education bullet counts as evidence for a skill '
          'linked to it, the same as any other bullet', () {
        const skill = Skill(
          id: 'skill-1',
          label: 'Distributed systems',
          linkedBulletIds: ['eb1'],
        );
        when(vaultService.vault).thenReturn(
          vaultWith(
            education: [schooled],
            skillCategories: const [
              SkillCategory(id: 'cat-1', name: 'Languages', skills: [skill]),
            ],
          ),
        );
        when(
          draftService.draft,
        ).thenReturn(draftWith(educationIds: [schooled.id]));

        final model = StudioViewModel();

        expect(model.evidenceCountFor(skill), 1);
      });
    });
  });
}
