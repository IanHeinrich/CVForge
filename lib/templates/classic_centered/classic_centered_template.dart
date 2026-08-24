import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'classic_centered_pdf_renderer.dart';
import 'classic_centered_tokens.dart';

/// A centered-heading, two-row-entry single-column layout, cloned from a
/// reference CV that puts Skills near the bottom rather than up top. See
/// `classic_centered_tokens.dart` for the visual vocabulary and
/// `classic_centered_pdf_renderer.dart` for the render tree.
class ClassicCenteredTemplate implements CvTemplate {
  const ClassicCenteredTemplate();

  @override
  String get id => 'classic_centered';

  // "Classic Centered" described its own layout mechanics rather than
  // selling the reader a reason to pick it — "Traditional" matches its
  // own [tags] (traditional, academic) and reads fine standing alone in
  // the gallery now that grouping under a tag heading doesn't supply
  // that context for it. `id` is unchanged — it's the persisted
  // per-draft template reference, not user-facing.

  @override
  CvDesignTokens get tokens => classicCenteredTokens;

  @override
  Set<TemplateTag> get tags => const {
    TemplateTag.atsSafe,
    TemplateTag.traditional,
    TemplateTag.academic,
  };

  /// Matches the reference CV's own order — Skills sits near the bottom,
  /// just before Publications, not near the top the way `compact`
  /// puts it. Projects/Hobbies/References aren't in the reference at all;
  /// they're placed adjacent to their nearest natural neighbour so a draft
  /// that happens to use them still prints somewhere sensible, with
  /// Publications kept last to match the reference's terminal section.
  @override
  List<CvSectionType> get sectionOrder => const [
    CvSectionType.summary,
    CvSectionType.education,
    CvSectionType.experience,
    CvSectionType.projects,
    CvSectionType.skills,
    CvSectionType.hobbies,
    CvSectionType.references,
    CvSectionType.publications,
  ];

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
        build: (context) => const ClassicCenteredPdfRenderer().build(
          cv,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
      ),
    );
    return doc;
  }

  String _keywords(ResolvedCv cv) => [
    for (final section in cv.sections)
      if (section is ResolvedSkillsSection)
        for (final group in section.groups) ...group.skills,
  ].join(', ');
}
