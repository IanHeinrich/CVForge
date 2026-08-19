import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/render/resolved_cv.dart';
import '../../models/render/resolved_section.dart';
import '../cv_template.dart';
import '../design/cv_design_tokens.dart';
import '../design/cv_design_tokens_pdf.dart';
import '../design/cv_font_set.dart';
import 'ats_minimal_pdf_renderer.dart';
import 'ats_minimal_tokens.dart';

/// A clean, single-column, ATS-friendly layout modelled on the
/// r/EngineeringResumes community template. See `ats_minimal_tokens.dart`
/// for the visual vocabulary and `ats_minimal_pdf_renderer.dart` for the
/// render tree — Studio's live preview and the exported PDF are both this
/// same tree, rasterized by `printing.PdfPreview` for the former.
class AtsMinimalTemplate implements CvTemplate {
  const AtsMinimalTemplate();

  @override
  String get id => 'ats_minimal';

  @override
  String get displayName => 'ATS Minimal';

  @override
  String get description =>
      'A clean, single-column, sans-serif layout built to pass through '
      'ATS parsers without friction.';

  @override
  CvDesignTokens get tokens => atsMinimalTokens;

  @override
  pw.Document buildDocument(
    ResolvedCv cv,
    PdfPageFormat format,
    CvFontSet fonts, {
    bool compress = true,
  }) {
    final doc = pw.Document(
      compress: compress,
      title: '${cv.header.fullName} - CV',
      author: cv.header.fullName,
      creator: 'CVForge',
      subject: 'Curriculum Vitae',
      keywords: _keywords(cv),
    );
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: tokens.pageMargins,
        build: (context) => buildAtsMinimalPdfContent(cv, fonts),
      ),
    );
    return doc;
  }

  /// Every skill across every visible skill group, comma-separated —
  /// recruiter platforms and ATS indexers read the PDF's own metadata
  /// dictionary for these on upload, not just the visible page content.
  String _keywords(ResolvedCv cv) => [
    for (final section in cv.sections)
      if (section is ResolvedSkillsSection)
        for (final group in section.groups) ...group.skills,
  ].join(', ');
}
