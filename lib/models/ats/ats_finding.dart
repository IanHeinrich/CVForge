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

/// One evidence node for a finding — an index into
/// `AtsExtractedDocument.nodes`, plus [pageIndex] denormalised alongside
/// it. [pageIndex] is technically derivable from the node itself, but the
/// X-Ray rail groups evidence by page on every rebuild, and re-deriving it
/// from a full-document node list on every group-by would be needless
/// work; `AtsAnalyzerService` always has both the index and the node in
/// hand when it builds one of these, so the two values can't drift.
@freezed
abstract class AtsFindingEvidence with _$AtsFindingEvidence {
  const factory AtsFindingEvidence({
    required int pageIndex,
    required int nodeIndex,
  }) = _AtsFindingEvidence;
}

/// How a finding's [AtsFinding.evidence] nodes relate to each other —
/// drives the X-Ray overlay's rendering and camera framing, not just a
/// cosmetic tag:
///
/// - [scattered]: each node is an independent instance of the same
///   problem (e.g. [AtsFindingCategory.garbledText] — a dozen unrelated
///   runs with a PUA glyph each). No relationship is drawn between them.
/// - [span]: the nodes are endpoints and the space *between* them is the
///   finding (e.g. [AtsFindingCategory.columnCrush] — the gap is what a
///   position-sorting extractor will misread). The overlay draws a
///   connector across the gap and frames the union, not each node in
///   isolation.
enum AtsEvidenceShape { scattered, span }

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

    /// The text run(s) that produced this finding, for the X-Ray overlay
    /// to draw evidence boxes on. Empty for a finding with no natural node
    /// evidence ([AtsFindingCategory.noTextLayer], [missingHeadings],
    /// [contactInfo]).
    @Default(<AtsFindingEvidence>[]) List<AtsFindingEvidence> evidence,
    @Default(AtsEvidenceShape.scattered) AtsEvidenceShape evidenceShape,
  }) = _AtsFinding;
}
