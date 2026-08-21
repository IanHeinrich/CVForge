import 'dart:math' as math;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_text_node.freezed.dart';

/// One text run as `pdf.js`'s `getTextContent()` reports it — a run, never
/// a single glyph, word, or line; the actual chunking is producer-
/// dependent (confirmed empirically, see the ATS-analyzer spike notes).
/// Never persisted, so no `fromJson`/`toJson`/`schemaVersion` — mirrors
/// `ResolvedCv`'s precedent for extraction-time-only data.
///
/// This is the seam between `PdfExtractionService` (marshalling only, and
/// consequently untestable under `flutter test` — the interop it wraps
/// only runs in a browser) and the pure-Dart `AtsAnalyzerService` that
/// consumes it and is fully VM-testable.
///
/// Deliberately carries the raw transform matrix rather than a derived
/// axis-aligned box: a rotated run (sidebar labels, stamped headers) has
/// no meaningful axis-aligned width/height, and [AtsTextMatrix] exposes
/// the derived quantities (`fontSize`, `rotationRadians`, baseline point)
/// as getters instead, so nothing here silently discards rotation.
@freezed
abstract class AtsTextNode with _$AtsTextNode {
  const factory AtsTextNode({
    required int pageIndex,
    required String str,
    required AtsTextMatrix transform,

    /// The advance width along the text direction — an *advance* box, not
    /// an *ink* box. Confirmed in the spike: a dropped/unmapped glyph
    /// (e.g. a PUA bullet drawn with a non-embedded font) can leave a
    /// nonzero [width] with no corresponding characters in [str] — see
    /// `AtsAnalyzerService`'s phantom-glyph check, which exists because of
    /// exactly that finding.
    required double width,

    /// `pdf.js`'s internal font id (e.g. `g_d0_f1`) — a key into
    /// `AtsExtractedDocument.fonts`, not a user-facing name.
    required String fontName,
  }) = _AtsTextNode;
}

/// The text-rendering matrix `pdf.js` reports per run, exactly as given —
/// confirmed empirically (spike probe output) to already be in the page's
/// default user space: PDF points, origin bottom-left, y-up. That is
/// *not* the same space a rasterized backdrop uses (pixels, DPI-scaled,
/// y-down) — reconciling the two is the X-Ray overlay painter's job via
/// its own `getViewport()` call at the raster's scale, not something
/// folded in here. Own value type — this package must never import
/// `flutter` (no `Matrix4`) or `pdf`.
@freezed
abstract class AtsTextMatrix with _$AtsTextMatrix {
  const AtsTextMatrix._();

  const factory AtsTextMatrix({
    required double a,
    required double b,
    required double c,
    required double d,
    required double e,
    required double f,
  }) = _AtsTextMatrix;

  /// Baseline x — not the box's left edge for a rotated run.
  double get baselineX => e;

  /// Baseline y.
  double get baselineY => f;

  /// The rotation-invariant effective font size.
  double get fontSize => math.sqrt(c * c + d * d);

  /// `0` for unrotated text; nonzero for a rotated run (e.g. a sidebar
  /// label), confirmed present in real synthetic output during the spike.
  double get rotationRadians => math.atan2(b, a);
}
