import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_font_info.freezed.dart';

/// Font metadata `pdf.js` only exposes after `page.getOperatorList()` has
/// run and `page.commonObjs` has been populated — not part of
/// `getTextContent()` at all (confirmed by reading the vendored bundle).
/// Keyed by `AtsTextNode.fontName` in
/// `AtsExtractedDocument.fonts`.
@freezed
abstract class AtsFontInfo with _$AtsFontInfo {
  const factory AtsFontInfo({
    /// `true` when the font isn't embedded and `pdf.js` substituted a
    /// fallback to render it.
    required bool missingFile,

    /// Fraction of em, PDF font-metric convention (ascent positive,
    /// descent negative). `null` when `pdf.js` doesn't report it for this
    /// font — the X-Ray overlay's ink-box derivation falls back to
    /// typical defaults in that case rather than requiring these
    /// (`AtsMatrixMath.atsInkBoxRect`).
    double? ascent,
    double? descent,
  }) = _AtsFontInfo;
}
