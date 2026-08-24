import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'package:cv_forge/templates/design/cv_pdf_renderer.dart';

/// The `classic_centered` style: centered, rule-less section headings, a
/// justified summary paragraph, and a bold/italic two-row entry header
/// (entity + date on row one, role/qualification + location on row two)
/// instead of `compact`'s one combined row. The walk that turns a
/// [ResolvedCv] into a flat, page-splittable widget list lives in
/// [CvPdfRenderer]; everything here is presentation.
class ClassicCenteredPdfRenderer extends CvPdfRenderer {
  const ClassicCenteredPdfRenderer();

  @override
  String get contactSeparator => ' – ';

  @override
  CvTypeToken headlineStyle(CvDesignTokens tokens) => tokens.role;

  /// Fully justified — the reference's summary paragraph reads flush on
  /// both margins, not ragged-right like `compact`'s.
  @override
  pw.Widget bodyText(String text, CvDesignTokens tokens, CvFontSet fonts) =>
      pw.Text(
        text,
        textAlign: pw.TextAlign.justify,
        style: tokens.body.toPdfStyle(fonts),
      );

  /// Centered, bold, no rule — the reference this template clones leans on
  /// whitespace rather than a line to separate sections. "Experience"
  /// reads as "Professional Experience" here, matching that reference,
  /// while `compact` keeps the shorter shared title.
  @override
  pw.Widget sectionHeading(
    ResolvedSection section,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final title = switch (section) {
      ResolvedExperienceSection() => 'Professional Experience',
      _ => section.title,
    };
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: tokens.sectionHeading.toPdfStyle(fonts),
        ),
        pw.SizedBox(height: tokens.sectionRuleGap),
      ],
    );
  }

  @override
  pw.Widget positionHeader(
    ResolvedPosition position,
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _headerRow(group.company, position.dateRange, tokens.role, tokens, fonts),
      _headerRow(position.role, group.location, tokens.company, tokens, fonts),
    ],
  );

  @override
  pw.Widget promotionCompanyHeading(
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _headerRow(group.company, group.location, tokens.role, tokens, fonts);

  @override
  pw.Widget promotionPositionHeading(
    ResolvedPosition position,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _headerRow(
    position.role,
    position.dateRange,
    tokens.company,
    tokens,
    fonts,
  );

  @override
  pw.Widget projectHeader(
    ResolvedProject project,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final link = project.link;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(project.title, style: tokens.role.toPdfStyle(fonts)),
        if (link != null && link.isNotEmpty)
          pw.UrlLink(
            destination: withScheme(link),
            // Italic — matches [CvDesignTokens.company]'s italic second-row
            // treatment elsewhere in this template, for visual consistency.
            child: pw.Text(
              link,
              style: tokens.meta.copyWith(italic: true).toPdfStyle(fonts),
            ),
          ),
      ],
    );
  }

  @override
  pw.Widget educationHeader(
    ResolvedQualification edu,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final detail = [
      edu.grade,
      edu.details,
    ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
    final qualificationLine = detail.isEmpty
        ? edu.qualification
        : '${edu.qualification}, $detail';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _headerRow(edu.institution, edu.location, tokens.role, tokens, fonts),
        _headerRow(
          qualificationLine,
          edu.yearLabel,
          tokens.company,
          tokens,
          fonts,
        ),
      ],
    );
  }

  /// Title, citation, and link all fold onto a single comma-separated line,
  /// none of them bold — the reference this template clones treats a
  /// publication as one plain-body-style entry, unlike `compact`'s
  /// bold-title, own-line-per-field layout.
  @override
  pw.Widget publicationHeader(
    ResolvedPublication publication,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final citation = publication.citation;
    final link = publication.link;
    final bodyStyle = tokens.body.toPdfStyle(fonts);

    final parts = <pw.Widget>[
      pw.Text(publication.title, style: bodyStyle),
      if (citation != null && citation.trim().isNotEmpty)
        pw.Text(citation, style: bodyStyle),
      if (link != null && link.trim().isNotEmpty)
        pw.UrlLink(
          destination: withScheme(link),
          child: pw.Text(link, style: bodyStyle),
        ),
    ];

    return pw.Wrap(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          // A fresh pw.Text per separator — see `CvPdfRenderer.pageHeader`'s
          // matching comment for why one shared instance can't be reused at
          // multiple tree positions.
          if (i > 0) pw.Text(', ', style: bodyStyle),
          parts[i],
        ],
      ],
    );
  }
}

/// One row of the two-row entry header: [left] styled bold/italic per
/// [leftStyle], [right] in the plain `meta` style, right-aligned.
/// `pw.Expanded` keeps a long left value from pushing [right] off the
/// page edge.
pw.Widget _headerRow(
  String left,
  String? right,
  CvTypeToken leftStyle,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(child: pw.Text(left, style: leftStyle.toPdfStyle(fonts))),
      if (right != null && right.isNotEmpty)
        pw.Text(right, style: tokens.meta.toPdfStyle(fonts)),
    ],
  );
}
