import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'package:cv_forge/templates/design/cv_pdf_renderer.dart';

/// The `compact` style: left-aligned section headings underlined by a
/// rule, ragged-right prose, and a single combined entry header row
/// ("Role, Company – Location" against its date range). The walk that
/// turns a [ResolvedCv] into a flat, page-splittable widget list lives in
/// [CvPdfRenderer]; everything here is presentation.
class CompactPdfRenderer extends CvPdfRenderer {
  const CompactPdfRenderer();

  @override
  String get contactSeparator => ' | ';

  @override
  CvTypeToken headlineStyle(CvDesignTokens tokens) => tokens.company;

  @override
  pw.Widget bodyText(String text, CvDesignTokens tokens, CvFontSet fonts) =>
      pw.Text(text, style: tokens.body.toPdfStyle(fonts));

  @override
  pw.Widget? sectionHeading(
    ResolvedSection section,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    // The summary sits directly under the header with no heading of its
    // own — the one section type with no title rule above it.
    if (section is ResolvedSummarySection) return null;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(section.title, style: tokens.sectionHeading.toPdfStyle(fonts)),
        pw.SizedBox(height: tokens.sectionRuleGap),
        pw.Container(
          height: tokens.ruleThickness,
          color: PdfColor.fromInt(tokens.ruleColorArgb),
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
  ) => _labelledRow(
    pw.TextSpan(
      children: [
        pw.TextSpan(
          text: '${position.role}, ',
          style: tokens.role.toPdfStyle(fonts),
        ),
        pw.TextSpan(
          text: '${group.company} – ${group.location}',
          style: tokens.company.toPdfStyle(fonts),
        ),
      ],
    ),
    position.dateRange,
    tokens,
    fonts,
  );

  @override
  pw.Widget promotionCompanyHeading(
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => pw.Text(
    '${group.company} – ${group.location}',
    style: tokens.role.toPdfStyle(fonts),
  );

  @override
  pw.Widget promotionPositionHeading(
    ResolvedPosition position,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _labelledRow(
    pw.TextSpan(text: position.role, style: tokens.company.toPdfStyle(fonts)),
    position.dateRange,
    tokens,
    fonts,
  );

  @override
  double promotionPositionIndent(CvDesignTokens tokens) => tokens.bulletIndent;

  @override
  pw.Widget projectHeader(
    ResolvedProject project,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _labelledRow(
    pw.TextSpan(text: project.title, style: tokens.role.toPdfStyle(fonts)),
    project.link,
    tokens,
    fonts,
    rightUrl: project.link == null ? null : withScheme(project.link!),
  );

  /// Grade/details fold into the same line as the institution–qualification
  /// text, comma-separated — the reference template keeps that header to one
  /// line.
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
    final suffix = detail.isEmpty ? '' : ', $detail';

    return _labelledRow(
      pw.TextSpan(
        children: [
          pw.TextSpan(
            text: edu.institution,
            style: tokens.role.toPdfStyle(fonts),
          ),
          pw.TextSpan(
            text: ' – ${edu.qualification}$suffix',
            style: tokens.company.toPdfStyle(fonts),
          ),
        ],
      ),
      edu.yearLabel,
      tokens,
      fonts,
    );
  }

  @override
  pw.Widget publicationHeader(
    ResolvedPublication publication,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final citation = publication.citation;
    final link = publication.link;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(publication.title, style: tokens.role.toPdfStyle(fonts)),
        if (citation != null && citation.trim().isNotEmpty)
          pw.Text(citation, style: tokens.meta.toPdfStyle(fonts)),
        if (link != null && link.trim().isNotEmpty)
          pw.UrlLink(
            destination: withScheme(link),
            child: pw.Text(link, style: tokens.meta.toPdfStyle(fonts)),
          ),
      ],
    );
  }
}

/// A left label + right value on one row — the "role, dates" and
/// "institution, year" rows every section but Skills uses. `pw.Expanded`
/// inside `pw.Row` (rather than a manual width split) is what keeps long
/// role/company text from pushing the date range off the page edge.
/// [rightUrl], when given, makes the right-hand value (e.g. a project
/// link) a clickable hyperlink rather than plain text.
pw.Widget _labelledRow(
  pw.InlineSpan left,
  String? right,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  String? rightUrl,
}) {
  final rightWidget = right == null || right.isEmpty
      ? null
      : pw.Text(right, style: tokens.meta.toPdfStyle(fonts));

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.RichText(text: pw.TextSpan(children: [left])),
      ),
      if (rightWidget != null)
        rightUrl == null
            ? rightWidget
            : pw.UrlLink(destination: rightUrl, child: rightWidget),
    ],
  );
}
