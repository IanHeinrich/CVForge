import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/models/region/region_profile.dart';

/// The region picker's own prose, translated.
///
/// `RegionPreset` still carries the English original, and deliberately so:
/// that copy is joined into the AI Assistant's region block, which is written
/// in English because the model is instructed in English. Translating a
/// prompt changes model behaviour, so the two consumers keep separate text —
/// the same `displayLabel`/`promptLabel` split `region_profile.dart` already
/// documents, applied one level up.
///
/// The consequence to know about: the English here and the English in
/// `region_presets.dart` are two copies that can drift. They need to agree in
/// substance, not in wording.
///
/// `localName` is *not* here. It is the market's own word for the document
/// ("Lebenslauf", "Hoja de Vida"), and translating it would defeat the entire
/// point of the field.
extension RegionPresetLabels on RegionProfile {
  String displayName(AppLocalizations l10n) => switch (this) {
    RegionProfile.uk => l10n.regionUkDisplayName,
    RegionProfile.us => l10n.regionUsDisplayName,
    RegionProfile.anz => l10n.regionAnzDisplayName,
    RegionProfile.dach => l10n.regionDachDisplayName,
    RegionProfile.nordics => l10n.regionNordicsDisplayName,
    RegionProfile.europe => l10n.regionEuropeDisplayName,
    RegionProfile.latamLetter => l10n.regionLatamLetterDisplayName,
    RegionProfile.latamA4 => l10n.regionLatamA4DisplayName,
  };

  String coverage(AppLocalizations l10n) => switch (this) {
    RegionProfile.uk => l10n.regionUkCoverage,
    RegionProfile.us => l10n.regionUsCoverage,
    RegionProfile.anz => l10n.regionAnzCoverage,
    RegionProfile.dach => l10n.regionDachCoverage,
    RegionProfile.nordics => l10n.regionNordicsCoverage,
    RegionProfile.europe => l10n.regionEuropeCoverage,
    RegionProfile.latamLetter => l10n.regionLatamLetterCoverage,
    RegionProfile.latamA4 => l10n.regionLatamA4Coverage,
  };

  String lengthNote(AppLocalizations l10n) => switch (this) {
    RegionProfile.uk => l10n.regionUkLengthNote,
    RegionProfile.us => l10n.regionUsLengthNote,
    RegionProfile.anz => l10n.regionAnzLengthNote,
    RegionProfile.dach => l10n.regionDachLengthNote,
    RegionProfile.nordics => l10n.regionNordicsLengthNote,
    RegionProfile.europe => l10n.regionEuropeLengthNote,
    RegionProfile.latamLetter => l10n.regionLatamLetterLengthNote,
    RegionProfile.latamA4 => l10n.regionLatamA4LengthNote,
  };

  String toneNote(AppLocalizations l10n) => switch (this) {
    RegionProfile.uk => l10n.regionUkToneNote,
    RegionProfile.us => l10n.regionUsToneNote,
    RegionProfile.anz => l10n.regionAnzToneNote,
    RegionProfile.dach => l10n.regionDachToneNote,
    RegionProfile.nordics => l10n.regionNordicsToneNote,
    RegionProfile.europe => l10n.regionEuropeToneNote,
    RegionProfile.latamLetter => l10n.regionLatamLetterToneNote,
    RegionProfile.latamA4 => l10n.regionLatamA4ToneNote,
  };

  List<String> conventions(AppLocalizations l10n) => switch (this) {
    RegionProfile.uk => [
      l10n.regionUkConvention1,
      l10n.regionUkConvention2,
      l10n.regionUkConvention3,
      l10n.regionUkConvention4,
      l10n.regionUkConvention5,
      l10n.regionUkConvention6,
    ],
    RegionProfile.us => [
      l10n.regionUsConvention1,
      l10n.regionUsConvention2,
      l10n.regionUsConvention3,
      l10n.regionUsConvention4,
      l10n.regionUsConvention5,
      l10n.regionUsConvention6,
      l10n.regionUsConvention7,
    ],
    RegionProfile.anz => [
      l10n.regionAnzConvention1,
      l10n.regionAnzConvention2,
      l10n.regionAnzConvention3,
      l10n.regionAnzConvention4,
      l10n.regionAnzConvention5,
      l10n.regionAnzConvention6,
    ],
    RegionProfile.dach => [
      l10n.regionDachConvention1,
      l10n.regionDachConvention2,
      l10n.regionDachConvention3,
      l10n.regionDachConvention4,
      l10n.regionDachConvention5,
      l10n.regionDachConvention6,
    ],
    RegionProfile.nordics => [
      l10n.regionNordicsConvention1,
      l10n.regionNordicsConvention2,
      l10n.regionNordicsConvention3,
      l10n.regionNordicsConvention4,
      l10n.regionNordicsConvention5,
      l10n.regionNordicsConvention6,
    ],
    RegionProfile.europe => [
      l10n.regionEuropeConvention1,
      l10n.regionEuropeConvention2,
      l10n.regionEuropeConvention3,
      l10n.regionEuropeConvention4,
      l10n.regionEuropeConvention5,
      l10n.regionEuropeConvention6,
    ],
    RegionProfile.latamLetter => [
      l10n.regionLatamLetterConvention1,
      l10n.regionLatamLetterConvention2,
      l10n.regionLatamLetterConvention3,
      l10n.regionLatamLetterConvention4,
      l10n.regionLatamLetterConvention5,
      l10n.regionLatamLetterConvention6,
      l10n.regionLatamLetterConvention7,
    ],
    RegionProfile.latamA4 => [
      l10n.regionLatamA4Convention1,
      l10n.regionLatamA4Convention2,
      l10n.regionLatamA4Convention3,
      l10n.regionLatamA4Convention4,
      l10n.regionLatamA4Convention5,
      l10n.regionLatamA4Convention6,
      l10n.regionLatamA4Convention7,
    ],
  };
}
