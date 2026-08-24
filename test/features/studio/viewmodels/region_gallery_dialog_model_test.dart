import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_data.dart';
import 'package:cv_forge/features/studio/dialogs/region_gallery/region_gallery_dialog_model.dart';
import 'package:cv_forge/models/region/region_profile.dart';
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

    test('every region declares the presentation values the card renders — '
        'a new region missing one would render a blank cell rather than '
        'fail to compile', () {
      for (final region in RegionProfile.values) {
        final preset = region.preset;
        expect(preset.flag, isNotEmpty, reason: '${region.name} flag');
        expect(
          preset.displayName,
          isNotEmpty,
          reason: '${region.name} displayName',
        );
        expect(
          preset.documentNoun,
          isNotEmpty,
          reason: '${region.name} documentNoun',
        );
        expect(
          preset.page.displayLabel,
          isNotEmpty,
          reason: '${region.name} page label',
        );
        expect(
          preset.dateStyle.displayLabel,
          isNotEmpty,
          reason: '${region.name} date label',
        );
      }
    });
  });
}
