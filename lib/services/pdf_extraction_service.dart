import 'dart:typed_data';

import 'package:cv_forge/models/ats/ats_extracted_document.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';

/// Which stage of [PdfExtractionService.extract] failed, so the UI can
/// show recovery copy per mode. Mirrors [PdfExportStage].
enum PdfExtractionFailure {
  /// The `pdf.js` module failed to load — a network/deployment problem,
  /// not a problem with the user's file.
  moduleLoadFailed,

  /// `getDocument()` rejected — corrupt, encrypted, or not a PDF at all.
  invalidPdf,

  /// A pure XFA form. Confirmed against the vendored bundle:
  /// `getTextContent()` takes a geometry-free path for these, so there is
  /// nothing to hand `AtsAnalyzerService` — hence a distinct failure
  /// rather than silently returning zero nodes.
  unsupportedXfa,
}

/// Wraps whatever the failing stage threw, tagged with [failure] so
/// callers classify it without inspecting the underlying exception.
class PdfExtractionException implements Exception {
  const PdfExtractionException(this.failure, this.cause);

  final PdfExtractionFailure failure;
  final Object? cause;

  @override
  String toString() =>
      'PdfExtractionException(failure: $failure, cause: $cause)';
}

/// Marshals `pdf.js` output into an [AtsExtractedDocument] — no analysis
/// logic, which lives in the pure-Dart `AtsAnalyzerService`.
///
/// An abstract interface rather than a concrete class because
/// `PdfExtractionServiceWeb` imports `package:web`, which does not compile
/// under the Dart VM at all. Registering it through `app.dart` would pull
/// that import into the centrally-generated `app.locator.dart` and break
/// the *entire* VM-run test suite — so `main.dart` registers it by hand.
abstract class PdfExtractionService {
  Future<AtsExtractedDocument> extract(Uint8List bytes);

  /// The page-space → pixel-space transform for one page at [dpi]. Pass
  /// the same [dpi] as `Printing.raster`, so the two agree on scale.
  ///
  /// Separate from [extract] because it is a per-page-about-to-render
  /// cost, and it re-derives via `pdf.js`'s own `getViewport()` rather
  /// than rescaling a cached matrix — one less place a sign or scale
  /// error can hide.
  Future<AtsTextMatrix> getPageViewportTransform(
    Uint8List bytes, {
    required int pageIndex,
    required double dpi,
  });
}
