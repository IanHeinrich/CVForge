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

/// One region's concrete document conventions — deliberately just two
/// fields. Richer candidates (a document noun, a phone label, a date-style
/// token) were cut because nothing downstream would actually read them.
class RegionPreset {
  const RegionPreset({required this.displayName, required this.page});

  final String displayName;
  final PdfPageFormatToken page;
}

/// Persistence keys on [RegionProfile]'s own enum name, not on anything
/// here — so these values can change between app versions without
/// invalidating a stored draft.
const Map<RegionProfile, RegionPreset> regionPresets = {
  RegionProfile.uk: RegionPreset(
    displayName: 'United Kingdom',
    page: PdfPageFormatToken.a4,
  ),
  RegionProfile.us: RegionPreset(
    displayName: 'United States',
    page: PdfPageFormatToken.letter,
  ),
};

extension RegionProfileX on RegionProfile {
  RegionPreset get preset => regionPresets[this]!;
}
