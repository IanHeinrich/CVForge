import 'package:stacked/stacked.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/services/ats_analyzer_service.dart';
import 'package:cv_forge/services/file_upload_service.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';

/// Drives the "upload a PDF, see what an ATS would struggle with" flow.
/// Unlike most top-level ViewModels in this app, there is no persisted
/// state to load on [initialise] — analysis only ever happens in response
/// to the user picking a file — so this is a plain [BaseViewModel], not a
/// [ReactiveViewModel]/[Initialisable]: nothing here listens to another
/// service's state, and `AnalyzerView` passes `isLoading`/`hasError:
/// false` straight through to `AppChrome.gated` rather than gating on an
/// init load that doesn't exist.
class AnalyzerViewModel extends BaseViewModel {
  final _fileUpload = locator<FileUploadService>();
  final _extraction = locator<PdfExtractionService>();
  final _analyzer = locator<AtsAnalyzerService>();

  static const _analyzeBusyKey = 'analyzer_analyze';

  AtsAnalysisResult? _result;
  AtsAnalysisResult? get result => _result;
  bool get hasResult => _result != null;

  bool get isAnalyzing => busy(_analyzeBusyKey);
  bool get hasAnalyzeError => hasErrorForKey(_analyzeBusyKey);

  Future<void> pickAndAnalyze() =>
      runBusyFuture(_pickAndAnalyze(), busyObject: _analyzeBusyKey);

  // A real `async` wrapper, not `runBusyFuture(_fileUpload.pickPdfFile()...)`
  // called inline — see `VaultViewModel._load`'s doc comment for exactly
  // why a call that can throw synchronously needs this indirection.
  Future<void> _pickAndAnalyze() async {
    final bytes = await _fileUpload.pickPdfFile();
    if (bytes == null) return; // user cancelled — not an error
    final extracted = await _extraction.extract(bytes);
    _result = _analyzer.analyze(extracted);
    notifyListeners();
  }

  /// Back to the upload prompt — clears the previous result without
  /// touching error state, since [pickAndAnalyze] already clears its own
  /// key's error the moment it runs again.
  void reset() {
    _result = null;
    notifyListeners();
  }

  /// Per-failure-mode copy, the same [PdfExportStage]/`BackupFailure`
  /// precedent every other exception-tagged service in this app follows.
  String get analyzeErrorMessage {
    final error = this.error(_analyzeBusyKey);
    if (error is! PdfExtractionException) {
      return "Couldn't analyze that file — try again.";
    }
    return switch (error.failure) {
      PdfExtractionFailure.moduleLoadFailed =>
        "Couldn't load the PDF engine — check your connection and try "
            'again.',
      PdfExtractionFailure.invalidPdf =>
        "That file doesn't look like a valid PDF, or it's password-"
            'protected.',
      PdfExtractionFailure.unsupportedXfa =>
        'This is an interactive PDF form, which works differently from a '
            "typical resume and can't be analyzed the same way.",
    };
  }
}
