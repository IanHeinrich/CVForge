import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';

import '../models/render/resolved_cv.dart';
import 'file_download_service.dart';
import 'font_service.dart';
import 'template_registry_service.dart';

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
    await _fileDownload.saveFile(
      nameWithoutExtension: _slugify('${fullName}_$draftName'),
      bytes: bytes,
      extension: 'pdf',
      mimeType: MimeType.pdf,
    );
  }

  /// Renders to raw bytes without saving — the seam
  /// `pdf_export_service_test.dart` exercises directly, since asserting on
  /// bytes doesn't require faking a browser download.
  Future<Uint8List> render({
    required ResolvedCv cv,
    required String templateId,
    PdfPageFormat format = PdfPageFormat.a4,
    bool compress = true,
  }) async {
    final template = _templateRegistry.byId(templateId);
    final fonts = await _fontService.load();
    final document = template.buildDocument(
      cv,
      format,
      fonts,
      compress: compress,
    );
    return document.save();
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
