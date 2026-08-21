import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/bullet_list_pdf.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';

/// `pw`-only rendering of [ResolvedCv] in the `classic_centered` style —
/// the sole render tree for this template; Studio's live preview
/// rasterizes this same output via `printing.PdfPreview`. Distinguishing
/// features vs. `compact`: centered, rule-less section headings; a
/// justified summary paragraph; and a bold/italic two-row entry header
/// (entity + date on row one, role/qualification + location on row two)
/// instead of one combined row.
///
/// Returns a FLAT top-level widget list — see `CvTemplate.buildDocument`'s
/// doc comment for why a single wrapping `pw.Column` would silently defeat
/// `pw.MultiPage`'s page splitting.
List<pw.Widget> buildClassicCenteredPdfContent(
  ResolvedCv cv,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  final widgets = <pw.Widget>[_header(cv.header, tokens, fonts)];
  for (final section in cv.sections) {
    widgets.add(pw.SizedBox(height: tokens.sectionGap));
    if (section is! ResolvedSummarySection) {
      widgets.add(_sectionHeading(section.title, tokens, fonts));
    }
    widgets.addAll(_sectionBody(section, tokens, fonts));
  }
  return widgets;
}

pw.Widget _header(
  ResolvedHeader header,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  final contactStyle = tokens.contact.toPdfStyle(fonts);

  pw.Widget contactPart(String text, {String? url}) {
    final widget = pw.Text(text, style: contactStyle);
    return url == null ? widget : pw.UrlLink(destination: url, child: widget);
  }

  final contactParts = <pw.Widget>[
    if (header.location.trim().isNotEmpty) contactPart(header.location),
    if (header.phone.trim().isNotEmpty) contactPart(header.phone),
    if (header.email.trim().isNotEmpty)
      contactPart(header.email, url: 'mailto:${header.email}'),
    for (final link in header.links)
      if (link.url.trim().isNotEmpty)
        contactPart(link.url, url: _withScheme(link.url)),
  ];

  return pw.Column(
    // Stretch, not the Column default of center — see
    // `compact_pdf_renderer.dart`'s `_header` doc comment for why a
    // shrink-wrapped pw.Text centers inconsistently otherwise.
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(
        header.fullName,
        textAlign: pw.TextAlign.center,
        style: tokens.name.toPdfStyle(fonts),
      ),
      if (header.headline.trim().isNotEmpty) ...[
        pw.SizedBox(height: 2),
        pw.Text(
          header.headline,
          textAlign: pw.TextAlign.center,
          style: tokens.role.toPdfStyle(fonts),
        ),
      ],
      if (contactParts.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Wrap(
          alignment: pw.WrapAlignment.center,
          children: [
            for (var i = 0; i < contactParts.length; i++) ...[
              // A fresh pw.Text per separator — see the matching comment
              // in `compact_pdf_renderer.dart` for why one shared
              // instance can't be reused at multiple tree positions.
              if (i > 0) pw.Text(' – ', style: contactStyle),
              contactParts[i],
            ],
          ],
        ),
      ],
    ],
  );
}

String _withScheme(String url) =>
    url.startsWith('http://') || url.startsWith('https://')
    ? url
    : 'https://$url';

/// Centered, bold, no rule — the reference this template clones leans on
/// whitespace rather than a line to separate sections.
pw.Widget _sectionHeading(
  String title,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
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

List<pw.Widget> _sectionBody(
  ResolvedSection section,
  CvDesignTokens tokens,
  CvFontSet fonts,
) => switch (section) {
  ResolvedSummarySection(text: final text) => [_bodyText(text, tokens, fonts)],
  ResolvedSkillsSection(groups: final groups) => _skillGroups(
    groups,
    tokens,
    fonts,
  ),
  ResolvedExperienceSection(groups: final groups) => [
    for (final group in groups) _companyGroup(group, tokens, fonts),
  ],
  ResolvedProjectsSection(items: final items) => [
    for (final project in items) _project(project, tokens, fonts),
  ],
  ResolvedEducationSection(items: final items) => [
    for (final edu in items) _education(edu, tokens, fonts),
  ],
  ResolvedHobbiesSection(items: final items) => [
    _bodyText(items.join(', '), tokens, fonts),
  ],
  ResolvedReferencesSection(text: final text) => [
    _bodyText(text, tokens, fonts),
  ],
  ResolvedPublicationsSection(items: final items) => [
    for (final publication in items) _publication(publication, tokens, fonts),
  ],
};

/// Fully justified — the reference's summary paragraph reads flush on
/// both margins, not ragged-right like `compact`'s.
pw.Widget _bodyText(String text, CvDesignTokens tokens, CvFontSet fonts) =>
    pw.Text(
      text,
      textAlign: pw.TextAlign.justify,
      style: tokens.body.toPdfStyle(fonts),
    );

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

pw.Widget _companyGroup(
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: tokens.itemGap),
    child: group.positions.length == 1
        ? _singlePosition(group.positions.single, group, tokens, fonts)
        : _promotionGroup(group, tokens, fonts),
  );
}

pw.Widget _singlePosition(
  ResolvedPosition position,
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _headerRow(group.company, position.dateRange, tokens.role, tokens, fonts),
      _headerRow(position.role, group.location, tokens.company, tokens, fonts),
      buildBulletList(position.bullets, tokens, fonts),
    ],
  );
}

/// A promotion: the company/location header shows once, then each role
/// with its own date range and bullets nested beneath.
pw.Widget _promotionGroup(
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _headerRow(group.company, group.location, tokens.role, tokens, fonts),
      for (final position in group.positions)
        pw.Padding(
          padding: pw.EdgeInsets.only(top: tokens.bulletGap),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _headerRow(
                position.role,
                position.dateRange,
                tokens.company,
                tokens,
                fonts,
              ),
              buildBulletList(position.bullets, tokens, fonts),
            ],
          ),
        ),
    ],
  );
}

pw.Widget _project(
  ResolvedProject project,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  final link = project.link;
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: tokens.itemGap),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(project.title, style: tokens.role.toPdfStyle(fonts)),
        if (link != null && link.isNotEmpty)
          pw.UrlLink(
            destination: _withScheme(link),
            child: pw.Text(link, style: tokens.meta.toPdfStyle(fonts)),
          ),
        buildBulletList(project.bullets, tokens, fonts),
      ],
    ),
  );
}

pw.Widget _education(
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

  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
    child: pw.Column(
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
    ),
  );
}

/// [Publication.link] renders as its own line, deliberately never spliced
/// into [citation] — a long DOI/URL sits on a line of its own rather than
/// competing with a long title/citation for right-aligned space the way
/// `compact`'s single-row project link does.
pw.Widget _publication(
  ResolvedPublication publication,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  final citation = publication.citation;
  final link = publication.link;
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: tokens.itemGap),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(publication.title, style: tokens.role.toPdfStyle(fonts)),
        if (citation != null && citation.trim().isNotEmpty)
          pw.Text(citation, style: tokens.meta.toPdfStyle(fonts)),
        if (link != null && link.trim().isNotEmpty)
          pw.UrlLink(
            destination: _withScheme(link),
            child: pw.Text(link, style: tokens.meta.toPdfStyle(fonts)),
          ),
      ],
    ),
  );
}

List<pw.Widget> _skillGroups(
  List<ResolvedSkillGroup> groups,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return [
    for (final group in groups)
      pw.Padding(
        padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '${group.category}: ',
                style: tokens.bulletLabel.toPdfStyle(fonts),
              ),
              pw.TextSpan(
                text: group.skills.join(', '),
                style: tokens.body.toPdfStyle(fonts),
              ),
            ],
          ),
        ),
      ),
  ];
}
