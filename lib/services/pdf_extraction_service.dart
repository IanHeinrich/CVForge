import 'dart:typed_data';

import 'package:cv_forge/models/ats/ats_extracted_document.dart';

/// Which stage of [PdfExtractionService.extract] failed — mirrors
/// [PdfExportStage]'s precedent so the UI can show different recovery copy
/// per failure mode.
enum PdfExtractionFailure {
  /// The `pdf.js` module itself failed to load — a network/deployment
  /// problem, not a problem with the user's file.
  moduleLoadFailed,

  /// `getDocument()` rejected — corrupt, encrypted, or not a PDF at all.
  invalidPdf,

  /// The document is a pure XFA form. Confirmed against the vendored
  /// bundle: `getTextContent()` follows a completely different,
  /// geometry-free code path for these, so there is nothing the real
  /// implementation can hand `AtsAnalyzerService` — surfaced as a
  /// distinct failure rather than silently returning zero nodes.
  unsupportedXfa,
}

/// Wraps whatever [PdfExtractionService.extract]'s failing stage threw,
/// tagged with [failure] so callers can classify it without inspecting the
/// underlying exception.
class PdfExtractionException implements Exception {
  const PdfExtractionException(this.failure, this.cause);

  final PdfExtractionFailure failure;
  final Object? cause;

  @override
  String toString() =>
      'PdfExtractionException(failure: $failure, cause: $cause)';
}

/// Marshals `pdf.js` output into an [AtsExtractedDocument] — deliberately
/// dumb, no analysis logic (that lives in `AtsAnalyzerService`, pure Dart
/// and fully VM-testable).
///
/// This is an abstract interface, not a concrete class, for a reason
/// specific to this one service: the real implementation
/// (`PdfExtractionServiceWeb`) imports `package:web`/`dart:js_interop`,
/// and `package:web` does not compile under the Dart VM at all — not "is
/// untested there," a genuine compile failure. Every other service in
/// `lib/services/` is registered as its own concrete type via
/// `LazySingleton(classType: X)` in `app.dart`, which `stacked_generator`
/// bakes into the single, centrally-generated `app.locator.dart` —
/// imported by nearly every test file. Registering `PdfExtractionServiceWeb`
/// there directly would pull `package:web` into that same central file's
/// compilation unit and break the *entire* VM-run test suite, not just
/// this feature's — confirmed the hard way; see `main.dart`'s manual
/// registration and its doc comment for how this service is wired instead.
/// `AtsAnalyzerService` has no such problem (pure Dart) and is registered
/// normally.
abstract class PdfExtractionService {
  Future<AtsExtractedDocument> extract(Uint8List bytes);
}
