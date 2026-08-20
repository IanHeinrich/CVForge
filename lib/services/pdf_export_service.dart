import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'file_download_service.dart';
import 'font_service.dart';
import 'template_registry_service.dart';

/// Which stage of [PdfExportService.export] failed — lets the UI show
/// different recovery copy per failure mode instead of one generic
/// message, since the three stages fail for genuinely different reasons
/// (a font/asset load failure under a deployed `--base-href` is a very
/// different problem from the browser's save dialog being blocked).
enum PdfExportStage { fonts, render, save }

/// Wraps whatever [PdfExportService.export]'s failing stage threw, tagged
/// with [stage] so callers can classify it without inspecting the
/// underlying exception's type or message.
class PdfExportException implements Exception {
  const PdfExportException(this.stage, this.cause);

  final PdfExportStage stage;
  final Object cause;

  @override
  String toString() => 'PdfExportException(stage: $stage, cause: $cause)';
}

/// Resolves a [ResolvedCv] + template id through the matching [CvTemplate],
/// renders it to PDF bytes with the warm, cached font set, and hands the
/// result to [FileDownloadService].
class PdfExportService {
  final _templateRegistry = locator<TemplateRegistryService>();
  final _fontService = locator<FontService>();
  final _fileDownload = locator<FileDownloadService>();

  Future<void> export({
    required ResolvedCv cv,
    required String templateId,
    required String fullName,
    required String draftName,
    PdfPageFormat format = PdfPageFormat.a4,
  }) async {
    final bytes = await render(cv: cv, templateId: templateId, format: format);
    try {
      await _fileDownload.saveFile(
        nameWithoutExtension: _slugify('${fullName}_$draftName'),
        bytes: bytes,
        extension: 'pdf',
        mimeType: MimeType.pdf,
      );
    } catch (e) {
      throw PdfExportException(PdfExportStage.save, e);
    }
  }

  /// Renders to raw bytes without saving — the seam
  /// `pdf_export_service_test.dart` exercises directly, since asserting on
  /// bytes doesn't require faking a browser download.
  ///
  /// Tags a failure with [PdfExportStage.fonts] or [PdfExportStage.render]
  /// depending on which half threw — [export] tags its own save failure
  /// separately, since a caller going through [render] directly (the test
  /// seam above) never reaches that stage.
  Future<Uint8List> render({
    required ResolvedCv cv,
    required String templateId,
    PdfPageFormat format = PdfPageFormat.a4,
    bool compress = true,
  }) async {
    final template = _templateRegistry.byId(templateId);
    final CvFontSet fonts;
    try {
      fonts = await _fontService.load();
    } catch (e) {
      throw PdfExportException(PdfExportStage.fonts, e);
    }
    try {
      final document = template.buildDocument(
        cv,
        format,
        fonts,
        compress: compress,
      );
      // Must await here, not just return the Future — `document.save()`
      // is itself async, and an unawaited return would let a failure
      // inside it propagate past this catch instead of getting tagged
      // with PdfExportStage.render.
      return await document.save();
    } catch (e) {
      throw PdfExportException(PdfExportStage.render, e);
    }
  }

  /// Filename policy: no extension in the returned string — [saveFile]
  /// appends `.pdf` itself, and doing it twice yields `cv.pdf.pdf`.
  String _slugify(String input) {
    final slug = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'cv' : slug;
  }
}
