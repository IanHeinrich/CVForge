import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/bullet_list_pdf.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'package:cv_forge/templates/design/section_pagination_pdf.dart';

/// `pw`-only rendering of [ResolvedCv] in the `compact` style — the
/// sole render tree for this template; Studio's live preview rasterizes
/// this same output via `printing.PdfPreview` rather than a second,
/// hand-built Flutter tree, so there's nothing else for this to drift
/// against.
///
/// Takes [tokens] as a parameter, rather than reaching for
/// `compactTokens` directly, so this render tree is genuinely reusable
/// by a future template rather than hard-wired to one token set —
/// `CompactTemplate.buildDocument` is the only caller today, and it
/// supplies its own [CvTemplate.tokens].
///
/// Returns a FLAT top-level widget list, one entry per header/heading/item
/// rather than one enclosing `pw.Column` — feeding `pw.MultiPage.build` a
/// single nested `pw.Column` silently defeats its page-splitting (see
/// `CvTemplate.buildDocument`'s doc comment). See
/// [assembleSectionWidgets]'s doc comment for [preventOrphansAndSplits].
List<pw.Widget> buildCompactPdfContent(
  ResolvedCv cv,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  bool preventOrphansAndSplits = true,
}) {
  final widgets = <pw.Widget>[_header(cv.header, tokens, fonts)];
  for (final section in cv.sections) {
    widgets.add(pw.SizedBox(height: tokens.sectionGap));
    // The summary sits directly under the header with no heading of its
    // own — the one section type with no title rule above it.
    final heading = section is ResolvedSummarySection
        ? null
        : _sectionHeading(section.title, tokens, fonts);
    widgets.addAll(
      assembleSectionWidgets(
        heading: heading,
        body: _sectionBody(
          section,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
        preventOrphansAndSplits: preventOrphansAndSplits,
      ),
    );
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
    // Stretch, not the Column default of center — a pw.Text otherwise
    // shrink-wraps its own box to its content width before centering that
    // box, and (per the `pdf` package's internal text-overflow
    // bookkeeping) that shrink-wrap is inconsistent between a short line
    // and a long one, centering some lines but not others. Stretching
    // gives every line the full row width up front, so textAlign:center
    // has a consistent box to center within.
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
          style: tokens.company.toPdfStyle(fonts),
        ),
      ],
      if (contactParts.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        pw.Wrap(
          alignment: pw.WrapAlignment.center,
          children: [
            for (var i = 0; i < contactParts.length; i++) ...[
              // A fresh pw.Text per separator, not one shared instance —
              // pw widgets store their computed layout box on themselves,
              // so reusing one instance at multiple tree positions
              // corrupts whichever position lays out second.
              if (i > 0) pw.Text(' | ', style: contactStyle),
              contactParts[i],
            ],
          ],
        ),
      ],
    ],
  );
}

/// A PDF hyperlink destination needs an explicit scheme. Vault links are
/// entered casually (e.g. "linkedin.com/in/jordanellery"), so add one
/// rather than requiring the user to type "https://" themselves.
String _withScheme(String url) =>
    url.startsWith('http://') || url.startsWith('https://')
    ? url
    : 'https://$url';

pw.Widget _sectionHeading(
  String title,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(title, style: tokens.sectionHeading.toPdfStyle(fonts)),
      pw.SizedBox(height: tokens.sectionRuleGap),
      pw.Container(
        height: tokens.ruleThickness,
        color: PdfColor.fromInt(tokens.ruleColorArgb),
      ),
      pw.SizedBox(height: tokens.sectionRuleGap),
    ],
  );
}

/// One top-level widget per item within [section]'s body — down to
/// individual bullets within an entry, not just one widget per entry — so
/// `pw.MultiPage` can place a page break between any two of them. See
/// [assembleSectionWidgets]'s doc comment for why that granularity is
/// what makes genuine cross-page splitting between bullets possible at
/// all, and for [preventOrphansAndSplits].
List<pw.Widget> _sectionBody(
  ResolvedSection section,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) => switch (section) {
  ResolvedSummarySection(text: final text) => [_bodyText(text, tokens, fonts)],
  ResolvedSkillsSection(groups: final groups) => _skillGroups(
    groups,
    tokens,
    fonts,
  ),
  ResolvedExperienceSection(groups: final groups) => [
    for (final group in groups)
      ..._companyGroup(
        group,
        tokens,
        fonts,
        preventOrphansAndSplits: preventOrphansAndSplits,
      ),
  ],
  ResolvedProjectsSection(items: final items) => [
    for (final project in items)
      ..._project(
        project,
        tokens,
        fonts,
        preventOrphansAndSplits: preventOrphansAndSplits,
      ),
  ],
  ResolvedEducationSection(items: final items) => [
    for (final edu in items)
      ..._education(
        edu,
        tokens,
        fonts,
        preventOrphansAndSplits: preventOrphansAndSplits,
      ),
  ],
  ResolvedHobbiesSection(items: final items) => [
    _bodyText(items.join(', '), tokens, fonts),
  ],
  ResolvedReferencesSection(text: final text) => [
    _bodyText(text, tokens, fonts),
  ],
  ResolvedPublicationsSection(items: final items) => [
    for (final publication in items)
      ..._publication(
        publication,
        tokens,
        fonts,
        preventOrphansAndSplits: preventOrphansAndSplits,
      ),
  ],
};

pw.Widget _bodyText(String text, CvDesignTokens tokens, CvFontSet fonts) =>
    pw.Text(text, style: tokens.body.toPdfStyle(fonts));

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

/// One company group flattened to top-level widgets, with [tokens.itemGap]
/// trailing space appended after the group's last piece rather than
/// wrapped around the whole group as padding — since the group is no
/// longer a single widget, there's no single container left to pad.
List<pw.Widget> _companyGroup(
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) {
  final items = group.positions.length == 1
      ? _singlePosition(
          group.positions.single,
          group,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        )
      : _promotionGroup(
          group,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        );
  return [...items, pw.SizedBox(height: tokens.itemGap)];
}

List<pw.Widget> _singlePosition(
  ResolvedPosition position,
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) {
  final header = _labelledRow(
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
  return assembleSectionWidgets(
    heading: header,
    body: [for (final b in position.bullets) buildBulletRow(b, tokens, fonts)],
    gap: tokens.bulletGap,
    preventOrphansAndSplits: preventOrphansAndSplits,
  );
}

/// A promotion: the company is shown once, then each role — its own
/// header glued to its own first bullet, same as any other entry — with
/// its date range and bullets nested beneath.
List<pw.Widget> _promotionGroup(
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) {
  final companyHeading = pw.Text(
    '${group.company} – ${group.location}',
    style: tokens.role.toPdfStyle(fonts),
  );
  final positionItems = <pw.Widget>[
    for (final position in group.positions)
      ...assembleSectionWidgets(
        heading: pw.Padding(
          padding: pw.EdgeInsets.only(
            top: tokens.bulletGap,
            left: tokens.bulletIndent,
          ),
          child: _labelledRow(
            pw.TextSpan(
              text: position.role,
              style: tokens.company.toPdfStyle(fonts),
            ),
            position.dateRange,
            tokens,
            fonts,
          ),
        ),
        body: [
          for (final b in position.bullets) buildBulletRow(b, tokens, fonts),
        ],
        gap: tokens.bulletGap,
        preventOrphansAndSplits: preventOrphansAndSplits,
      ),
  ];
  return assembleSectionWidgets(
    heading: companyHeading,
    body: positionItems,
    preventOrphansAndSplits: preventOrphansAndSplits,
  );
}

List<pw.Widget> _project(
  ResolvedProject project,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) {
  final header = _labelledRow(
    pw.TextSpan(text: project.title, style: tokens.role.toPdfStyle(fonts)),
    project.link,
    tokens,
    fonts,
    rightUrl: project.link == null ? null : _withScheme(project.link!),
  );
  final items = assembleSectionWidgets(
    heading: header,
    body: [for (final b in project.bullets) buildBulletRow(b, tokens, fonts)],
    gap: tokens.bulletGap,
    preventOrphansAndSplits: preventOrphansAndSplits,
  );
  return [...items, pw.SizedBox(height: tokens.itemGap)];
}

List<pw.Widget> _publication(
  ResolvedPublication publication,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) {
  final citation = publication.citation;
  final link = publication.link;
  final header = pw.Column(
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
  );
  final items = assembleSectionWidgets(
    heading: header,
    body: [
      for (final b in publication.bullets) buildBulletRow(b, tokens, fonts),
    ],
    gap: tokens.bulletGap,
    preventOrphansAndSplits: preventOrphansAndSplits,
  );
  return [...items, pw.SizedBox(height: tokens.itemGap)];
}

/// Grade/details fold into the same line as the institution–qualification
/// text, comma-separated — the reference template keeps that header to one
/// line. Bullets, when present, render underneath the header row.
List<pw.Widget> _education(
  ResolvedQualification edu,
  CvDesignTokens tokens,
  CvFontSet fonts, {
  required bool preventOrphansAndSplits,
}) {
  final detail = [
    edu.grade,
    edu.details,
  ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
  final suffix = detail.isEmpty ? '' : ', $detail';

  final header = _labelledRow(
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
  final items = assembleSectionWidgets(
    heading: header,
    body: [for (final b in edu.bullets) buildBulletRow(b, tokens, fonts)],
    gap: tokens.bulletGap,
    preventOrphansAndSplits: preventOrphansAndSplits,
  );
  return [...items, pw.SizedBox(height: tokens.bulletGap)];
}
