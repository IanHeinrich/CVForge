import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_finding.freezed.dart';

/// The reduced v1 check set the ATS-analyzer spike settled on. Two
/// originally-proposed checks — typographic hierarchy and orphaned dates —
/// were cut deliberately: they're resume-design critiques, not things an
/// ATS text extractor actually fails on, and shipping them with the same
/// confidence as a real parsing-failure finding would erode trust in the
/// findings that do matter. See the spike findings note for the full
/// reasoning.
enum AtsFindingCategory {
  /// No extractable text at all (a scanned/image-only page).
  noTextLayer,

  /// Two or more runs share a baseline at disjoint x-ranges — what a
  /// position-sorting text extractor (e.g. PDFBox with
  /// `setSortByPosition(true)`) would read as one interleaved line. This
  /// simulates *that* algorithm, applied to the extracted coordinates —
  /// not "the file's own reading order", which `pdf.js` already preserves
  /// faithfully (confirmed against a second extractor in the spike).
  columnCrush,

  /// Text that likely won't survive extraction as the words it visually
  /// renders as: PUA/replacement codepoints, or a "phantom glyph" — an
  /// advance width spent with no corresponding character, the specific
  /// failure mode a non-embedded-font PUA bullet produced in the spike.
  garbledText,

  /// None of the canonical section headings (Experience, Education,
  /// Skills, ...) were found in the extracted text.
  missingHeadings,

  /// No email/phone recoverable from either the extracted text or the
  /// document's Link annotations.
  contactInfo,
}

/// How much weight a finding should carry in the UI. Parsing-failure
/// categories ([AtsFindingCategory.noTextLayer], [columnCrush],
/// [garbledText]) are evidence-backed; [missingHeadings] and
/// [contactInfo] are heuristic and should read with visibly less
/// confidence than the others.
enum AtsFindingSeverity { critical, warning, info }

/// One issue surfaced by `AtsAnalyzerService`. Never persisted — produced
/// fresh on every analysis run.
@freezed
abstract class AtsFinding with _$AtsFinding {
  const factory AtsFinding({
    required AtsFindingCategory category,
    required AtsFindingSeverity severity,
    required String title,
    required String message,

    /// `null` for a document-level finding (e.g. [AtsFindingCategory.
    /// noTextLayer] across every page); set when a finding is anchored to
    /// one page.
    int? pageIndex,
  }) = _AtsFinding;
}
