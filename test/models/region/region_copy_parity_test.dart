import 'package:cv_forge/l10n/generated/app_localizations_en.dart';
import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/common/l10n/region_labels.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every region's prose exists twice: once in `RegionPreset`, which is
/// joined into the AI Assistant's prompt and stays English because the
/// model is instructed in English, and once in the ARB, which the picker
/// renders and translators translate. `region_labels.dart` documents that
/// pair and warns it can drift.
///
/// It drifted twice before this test existed, in both directions: the
/// ARB's DACH bullet still said a photo-printing template was "planned"
/// after `photo_header` shipped, and a spelling bullet was hedged in the
/// ARB while `RegionPreset` kept the unhedged wording. Both read as
/// correct in isolation, which is exactly why neither was noticed.
///
/// The check is exact rather than "agree in substance" — a looser one
/// cannot be written down, and the two have been character-identical in
/// English all along. A deliberate divergence should be a named carve-out
/// here, not a silent inequality.
void main() {
  final l10n = AppLocalizationsEn();

  group('RegionPreset and the English ARB say the same thing -', () {
    for (final region in RegionProfile.values) {
      final preset = region.preset;

      test('${region.name} scalar fields match', () {
        expect(region.displayName(l10n), preset.displayName);
        expect(region.coverage(l10n), preset.coverage);
        expect(region.lengthNote(l10n), preset.lengthNote);
        expect(region.toneNote(l10n), preset.toneNote);
      });

      test('${region.name} conventions match', () {
        // Length first: a bullet added to one copy and not the other is
        // the drift most likely to go unread, since every bullet that
        // *is* present still reads correctly.
        expect(
          region.conventions(l10n).length,
          preset.conventions.length,
          reason:
              'RegionPreset.conventions and the region${_pascal(region.name)}'
              'ConventionN keys are different lengths. Adding a bullet means '
              'adding it to both, plus app_es.arb.',
        );
        expect(region.conventions(l10n), preset.conventions);
      });
    }
  });
}

String _pascal(String name) => name[0].toUpperCase() + name.substring(1);
