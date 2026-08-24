import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/draft/cv_draft.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/models/vault/contact_basics.dart';
import 'package:cv_forge/models/vault/cv_vault.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pdf/pdf.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';
import '../../../helpers/test_helpers.mocks.dart';

/// One case per page-level, singleton text override (tailored summary,
/// headline, references note) — each is "draft override, falling back to
/// the Vault's own value, normalized through the same blank/identical
/// input collapses to null rule" (see `StudioViewModel._TextOverride`),
/// differing only in which Vault field seeds it, which draft field
/// stores it, and which `DraftService` setter applies it. Drives the
/// three shared assertions below instead of writing them out three times.
typedef _SingletonOverrideCase = ({
  String label,
  CvVault Function(String value) vaultWithValue,
  CvDraft Function(String override) draftWithOverride,
  Future<void> Function(StudioViewModel model, String value) setOverride,
  Future<void> Function(StudioViewModel model) revert,
  void Function(MockDraftService draftService) stubSetter,
  void Function(MockDraftService draftService) verifyNullOverride,
});

final _singletonOverrideCases = <_SingletonOverrideCase>[
  (
    label: 'tailored summary',
    vaultWithValue: (v) =>
        vaultWith(basics: ContactBasics.empty().copyWith(summary: v)),
    draftWithOverride: (v) => draftWith(tailoredSummary: v),
    setOverride: (model, v) => model.setTailoredSummary(v),
    revert: (model) => model.revertSummaryToVault(),
    stubSetter: (ds) => when(
      ds.setTailoredSummary(any),
    ).thenAnswer((_) => Future<void>.value()),
    verifyNullOverride: (ds) => verify(ds.setTailoredSummary(null)).called(1),
  ),
  (
    label: 'headline',
    vaultWithValue: (v) =>
        vaultWith(basics: ContactBasics.empty().copyWith(headline: v)),
    draftWithOverride: (v) => draftWith(headlineOverride: v),
    setOverride: (model, v) => model.setHeadlineOverride(v),
    revert: (model) => model.revertHeadlineToVault(),
    stubSetter: (ds) => when(
      ds.setHeadlineOverride(any),
    ).thenAnswer((_) => Future<void>.value()),
    verifyNullOverride: (ds) => verify(ds.setHeadlineOverride(null)).called(1),
  ),
  (
    label: 'references note',
    vaultWithValue: (v) => vaultWith(referencesNote: v),
    draftWithOverride: (v) => draftWith(referencesOverride: v),
    setOverride: (model, v) => model.setReferencesOverride(v),
    revert: (model) => model.revertReferencesToVault(),
    stubSetter: (ds) => when(
      ds.setReferencesOverride(any),
    ).thenAnswer((_) => Future<void>.value()),
    verifyNullOverride: (ds) =>
        verify(ds.setReferencesOverride(null)).called(1),
  ),
];

void main() {
  group('StudioViewModel Tests - overrides -', () {
    late MockVaultService vaultService;
    late MockDraftService draftService;

    const experience = sampleExperience;
    const education = sampleEducation;

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

    for (final c in _singletonOverrideCases) {
      group('${c.label} override -', () {
        setUp(() => c.stubSetter(draftService));

        test('blank input stores null so the draft stays inherited', () async {
          when(vaultService.vault).thenReturn(c.vaultWithValue('Vault text'));
          when(draftService.draft).thenReturn(draftWith());

          await c.setOverride(StudioViewModel(), '   ');

          c.verifyNullOverride(draftService);
        });

        test('input identical to the Vault value stores null rather than '
            'an identical-but-separate override', () async {
          when(vaultService.vault).thenReturn(c.vaultWithValue('Same text'));
          when(draftService.draft).thenReturn(draftWith());

          await c.setOverride(StudioViewModel(), 'Same text');

          c.verifyNullOverride(draftService);
        });

        test('revert clears the override', () async {
          when(vaultService.vault).thenReturn(c.vaultWithValue('Vault text'));
          when(
            draftService.draft,
          ).thenReturn(c.draftWithOverride('Tailored text'));

          await c.revert(StudioViewModel());

          c.verifyNullOverride(draftService);
        });
      });
    }

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
    });

    group('references override -', () {
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

      test('every region resolves its own page format, including the two '
          'Latin American presets that exist only to differ on it', () {
        when(vaultService.vault).thenReturn(vaultWith());

        const expected = {
          RegionProfile.uk: PdfPageFormat.a4,
          RegionProfile.us: PdfPageFormat.letter,
          RegionProfile.anz: PdfPageFormat.a4,
          RegionProfile.dach: PdfPageFormat.a4,
          RegionProfile.nordics: PdfPageFormat.a4,
          RegionProfile.europe: PdfPageFormat.a4,
          RegionProfile.latamLetter: PdfPageFormat.letter,
          RegionProfile.latamA4: PdfPageFormat.a4,
        };
        expect(
          expected.keys.toSet(),
          RegionProfile.values.toSet(),
          reason: 'a new region needs a page format asserted here',
        );

        for (final entry in expected.entries) {
          when(draftService.draft).thenReturn(draftWith(region: entry.key));
          expect(
            StudioViewModel().pageFormat,
            entry.value,
            reason: entry.key.name,
          );
        }
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

    group('pageCountWarning -', () {
      StudioViewModel modelFor(RegionProfile region, {int? pages}) {
        when(vaultService.vault).thenReturn(vaultWith());
        when(draftService.draft).thenReturn(draftWith(region: region));
        final model = StudioViewModel();
        if (pages != null) model.setPageCount(pages);
        return model;
      }

      test('stays silent before anything has rendered — no page count is '
          'not the same as a page count that is fine', () {
        expect(modelFor(RegionProfile.uk).pageCountWarning, isNull);
      });

      test('silent at exactly the typical maximum, speaks above it', () {
        final max = RegionProfile.uk.preset.typicalMaxPages;

        expect(modelFor(RegionProfile.uk, pages: max).pageCountWarning, isNull);
        expect(
          modelFor(RegionProfile.uk, pages: max + 1).pageCountWarning,
          isNotNull,
        );
      });

      test('the same page count warns in one region and not another, which '
          'is the whole point of tying it to region', () {
        expect(
          modelFor(RegionProfile.uk, pages: 3).pageCountWarning,
          isNotNull,
        );
        expect(modelFor(RegionProfile.anz, pages: 3).pageCountWarning, isNull);
      });

      test('names the region and offers the template as well as the '
          'content, since page count follows both', () {
        final warning = modelFor(RegionProfile.us, pages: 5).pageCountWarning;

        expect(warning, contains(RegionProfile.us.preset.displayName));
        expect(warning, contains(RegionProfile.us.preset.lengthNote));
        expect(warning, contains('template'));
      });
    });
  });
}
