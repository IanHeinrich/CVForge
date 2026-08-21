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
import 'package:cv_forge/models/render/region_profile.dart';
import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf/pdf.dart';

import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

void main() {
  group('StudioViewModel Tests - overrides -', () {
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
      RegionProfile region = RegionProfile.uk,
    }) => CvDraft(
      schemaVersion: 1,
      id: 'current',
      name: 'My CV',
      templateId: 'compact',
      region: region,
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

    group('region -', () {
      test('pageFormat resolves through the draft\'s region', () {
        when(vaultService.vault).thenReturn(vaultWith());
        when(
          draftService.draft,
        ).thenReturn(draftWith(region: RegionProfile.uk));
        expect(StudioViewModel().pageFormat, PdfPageFormat.a4);

        when(
          draftService.draft,
        ).thenReturn(draftWith(region: RegionProfile.us));
        expect(StudioViewModel().pageFormat, PdfPageFormat.letter);
      });

      test('setRegion delegates to DraftService', () async {
        when(vaultService.vault).thenReturn(vaultWith());
        when(draftService.draft).thenReturn(draftWith());
        when(
          draftService.setRegion(any),
        ).thenAnswer((_) => Future<void>.value());

        final model = StudioViewModel();
        await model.setRegion(RegionProfile.us);

        verify(draftService.setRegion(RegionProfile.us)).called(1);
      });
    });
  });
}
