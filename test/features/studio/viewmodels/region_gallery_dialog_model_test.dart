import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_model.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  group('RegionGalleryDialogModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    RegionGalleryDialogModel buildModel({
      RegionProfile currentRegion = RegionProfile.uk,
    }) => RegionGalleryDialogModel(
      data: RegionGalleryDialogData(currentRegion: currentRegion),
    );

    test('starts with the current region already selected', () {
      final model = buildModel(currentRegion: RegionProfile.us);

      expect(model.selectedRegion, RegionProfile.us);
    });

    test('selectRegion updates selectedRegion and notifies', () {
      final model = buildModel();
      var notified = false;
      model.addListener(() => notified = true);

      model.selectRegion(RegionProfile.us);

      expect(model.selectedRegion, RegionProfile.us);
      expect(notified, isTrue);
    });

    test('re-selecting the already-selected region does not notify', () {
      final model = buildModel(currentRegion: RegionProfile.uk);
      var notified = false;
      model.addListener(() => notified = true);

      model.selectRegion(RegionProfile.uk);

      expect(notified, isFalse);
    });

    test('regions exposes every region in declaration order', () {
      expect(buildModel().regions, RegionProfile.values);
    });

    test('every region declares the presentation values the picker renders '
        '— a new region missing one would render a blank cell rather than '
        'fail to compile', () {
      for (final region in RegionProfile.values) {
        final preset = region.preset;
        final why = region.name;

        expect(preset.flags, isNotEmpty, reason: '$why flags');
        expect(
          preset.flags.length,
          lessThanOrEqualTo(4),
          reason: '$why flags exceeds what RegionFlagStack lays out',
        );
        for (final flag in preset.flags) {
          expect(flag, isNotEmpty, reason: '$why has a blank flag');
        }

        for (final entry in <String, String>{
          'displayName': preset.displayName,
          'coverage': preset.coverage,
          'localName': preset.localName,
          'lengthNote': preset.lengthNote,
          'toneNote': preset.toneNote,
          'page label': preset.page.displayLabel,
          'date label': preset.dateStyle.displayLabel,
          'noun lower': preset.documentNoun.lower,
          'noun capitalized': preset.documentNoun.capitalized,
          'noun plural': preset.documentNoun.plural,
          'noun pluralCapitalized': preset.documentNoun.pluralCapitalized,
          'photo displayLabel': preset.photo.displayLabel,
          'photo promptLabel': preset.photo.promptLabel,
          'personalDetails displayLabel': preset.personalDetails.displayLabel,
          'personalDetails promptLabel': preset.personalDetails.promptLabel,
          'spelling displayLabel': preset.spelling.displayLabel,
          'spelling promptLabel': preset.spelling.promptLabel,
        }.entries) {
          expect(entry.value, isNotEmpty, reason: '$why ${entry.key}');
        }

        expect(
          preset.typicalMaxPages,
          greaterThan(0),
          reason: '$why typicalMaxPages',
        );
        expect(preset.conventions, isNotEmpty, reason: '$why conventions');
        for (final convention in preset.conventions) {
          expect(convention, isNotEmpty, reason: '$why has a blank convention');
        }
      }
    });
  });
}
