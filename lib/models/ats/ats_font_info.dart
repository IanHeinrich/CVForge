import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_font_info.freezed.dart';

/// Font metadata `pdf.js` only exposes after `page.getOperatorList()` has
/// run and `page.commonObjs` has been populated — not part of
/// `getTextContent()` at all (confirmed by reading the vendored bundle
/// during the spike). Keyed by `AtsTextNode.fontName` in
/// `AtsExtractedDocument.fonts`.
@freezed
abstract class AtsFontInfo with _$AtsFontInfo {
  const factory AtsFontInfo({
    /// The real PDF base font name, e.g. `Helvetica-Bold` or a subset
    /// font's `ABCDEF+Calibri`. The `ABCDEF+` subset prefix is the
    /// strongest available correlate of a missing/wrong ToUnicode map —
    /// see `AtsAnalyzerService`'s garbled-text heuristic.
    required String name,
    required bool bold,
    required bool italic,

    /// `true` when the font isn't embedded and `pdf.js` substituted a
    /// fallback to render it — confirmed via the spike's synthetic
    /// Helvetica corpus (non-embedded, `missingFile: true`) vs cv-forge's
    /// own embedded Roboto (`missingFile: false`).
    required bool missingFile,
    required bool isType3Font,
    required bool isInvalidPDFjsFont,
  }) = _AtsFontInfo;
}
