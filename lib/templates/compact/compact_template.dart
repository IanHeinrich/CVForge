import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'compact_pdf_renderer.dart';
import 'compact_tokens.dart';

/// A clean, single-column, ATS-friendly layout modelled on the
/// r/EngineeringResumes community template. See `compact_tokens.dart`
/// for the visual vocabulary and `compact_pdf_renderer.dart` for the
/// render tree — Studio's live preview and the exported PDF are both this
/// same tree, rasterized by `printing.PdfPreview` for the former.
class CompactTemplate implements CvTemplate {
  const CompactTemplate();

  @override
  String get id => 'compact';

  @override
  String get displayName => 'Compact';

  @override
  String get description =>
      'A clean, single-column, sans-serif layout built to pass through '
      'ATS parsers without friction.';

  @override
  CvDesignTokens get tokens => compactTokens;

  @override
  Set<TemplateTag> get tags => const {TemplateTag.atsSafe, TemplateTag.compact};

  @override
  List<CvSectionType> get sectionOrder => CvSectionType.values;

  @override
  pw.Document buildDocument(
    ResolvedCv cv,
    PdfPageFormat format,
    CvFontSet fonts, {
    bool compress = true,
    bool preventOrphansAndSplits = true,
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
        build: (context) => const CompactPdfRenderer().build(
          cv,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
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
