/// Region-specific document conventions (page format, date/spelling
/// normalisation). The seam [CvComposer.compose] and every call site were
/// already signed for — [RegionPreset] is where a region's concrete
/// differences (currently just page size) actually live.
enum RegionProfile { uk, us }

/// A page-size token, not `package:pdf`'s `PdfPageFormat` directly — this
/// file (like the rest of `lib/models/`) must never import `pdf`. The
/// enum->`PdfPageFormat` mapping lives with the other pdf adapters, in
/// `lib/templates/design/cv_design_tokens_pdf.dart`.
enum PdfPageFormatToken { a4, letter }

/// `CvComposer._formatDateRange`'s seam — both regions render "Mon YYYY"
/// today (see that method's own comment), but the switch lives on this
/// enum, not on [RegionProfile] directly, so a region with a different
/// convention doesn't require a composer change, only a new preset value
/// here and a new case there.
enum RegionDateStyle { monYyyy }

/// One region's concrete document conventions. [documentNoun] and
/// [dateStyle] were added once each gained a real consumer (ATS Check's
/// copy, `CvComposer`'s date-range seam) — richer candidates like a phone
/// label, a photo expectation, or a date-of-birth expectation are still
/// cut because nothing downstream reads them yet. See
/// `docs/ux/7.5-template-region-scaling.md`'s "Deferred" section.
class RegionPreset {
  const RegionPreset({
    required this.displayName,
    required this.flag,
    required this.page,
    required this.documentNoun,
    required this.dateStyle,
  });

  final String displayName;

  /// The region's flag as an emoji, for the region picker's card. A plain
  /// string, not an asset — a regional-indicator pair needs no bundled
  /// image, scales with the text around it, and costs nothing to add for
  /// a new region.
  final String flag;

  final PdfPageFormatToken page;

  /// "CV" or "Résumé" — what this region calls the document. Read by the
  /// app's own chrome copy (e.g. ATS Check's upload prompt), never printed
  /// inside the rendered document itself.
  final String documentNoun;

  final RegionDateStyle dateStyle;
}

extension PdfPageFormatTokenLabel on PdfPageFormatToken {
  /// Includes the physical dimensions, since "A4" versus "Letter" only
  /// means something to a reader who already knows the difference — the
  /// region picker exists partly to explain it.
  String get displayLabel => switch (this) {
    PdfPageFormatToken.a4 => 'A4 (210 × 297 mm)',
    PdfPageFormatToken.letter => 'US Letter (8.5 × 11 in)',
  };
}

extension RegionDateStyleLabel on RegionDateStyle {
  String get displayLabel => switch (this) {
    RegionDateStyle.monYyyy => 'Mon YYYY (e.g. Jun 2023)',
  };
}

/// Persistence keys on [RegionProfile]'s own enum name, not on anything
/// here — so these values can change between app versions without
/// invalidating a stored draft.
const Map<RegionProfile, RegionPreset> regionPresets = {
  RegionProfile.uk: RegionPreset(
    displayName: 'United Kingdom',
    flag: '🇬🇧',
    page: PdfPageFormatToken.a4,
    documentNoun: 'CV',
    dateStyle: RegionDateStyle.monYyyy,
  ),
  RegionProfile.us: RegionPreset(
    displayName: 'United States',
    flag: '🇺🇸',
    page: PdfPageFormatToken.letter,
    documentNoun: 'résumé',
    dateStyle: RegionDateStyle.monYyyy,
  ),
};

extension RegionProfileX on RegionProfile {
  RegionPreset get preset => regionPresets[this]!;
}
