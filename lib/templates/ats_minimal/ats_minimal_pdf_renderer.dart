import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';

/// Horizontal gap between the bullet glyph and the text beside it — a
/// fixed layout constant, not a design token, since it's a spacing
/// artifact of the glyph/text split rather than something a template
/// would want to restyle.
const _bulletGlyphGap = 6.0;

/// `pw`-only rendering of [ResolvedCv] in the `ats_minimal` style — the
/// sole render tree for this template; Studio's live preview rasterizes
/// this same output via `printing.PdfPreview` rather than a second,
/// hand-built Flutter tree, so there's nothing else for this to drift
/// against.
///
/// Takes [tokens] as a parameter, rather than reaching for
/// `atsMinimalTokens` directly, so this render tree is genuinely reusable
/// by a future template rather than hard-wired to one token set —
/// `AtsMinimalTemplate.buildDocument` is the only caller today, and it
/// supplies its own [CvTemplate.tokens].
///
/// Returns a FLAT top-level widget list, one entry per header/heading/item
/// rather than one enclosing `pw.Column` — feeding `pw.MultiPage.build` a
/// single nested `pw.Column` silently defeats its page-splitting (see
/// `CvTemplate.buildDocument`'s doc comment).
List<pw.Widget> buildAtsMinimalPdfContent(
  ResolvedCv cv,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  final widgets = <pw.Widget>[_header(cv.header, tokens, fonts)];
  for (final section in cv.sections) {
    widgets.add(pw.SizedBox(height: tokens.sectionGap));
    // The summary sits directly under the header with no heading of its
    // own — the one section type with no title rule above it.
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

/// One top-level widget per item within [section]'s body, so `MultiPage`
/// can split between e.g. two experience entries, not just between whole
/// sections.
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

/// The bullet glyph, laid out at [CvDesignTokens.bullet]'s font size (so
/// its box never grows or shrinks the row it sits in — that row's height
/// is what drives `bulletGap`-based spacing between bullets) and then
/// visually scaled to [CvDesignTokens.bulletGlyph]'s size via
/// `Transform.scale`, which paints larger/smaller without touching the
/// layout box. This is what lets `bulletGlyph.sizePt` be tuned freely
/// without the vertical rhythm between bullets/items changing.
///
/// [_bulletGlyphAlignmentY] anchors that scale on the `•` glyph's own ink
/// center rather than `Transform.scale`'s default box-center (the font's
/// full ascent/descent box). In Roboto the two are only ~0.008em apart
/// (measured from `Roboto-Regular.ttf`: ink center at 0.3677em vs. box
/// center at 0.3599em, of a 1.1719em box) — negligible at
/// `bullet.sizePt`, but scaling around the mismatched box-center anchor
/// drags the ink away from its natural position by an amount proportional
/// to `(scale - 1)`, which becomes visible at a large `bulletGlyph.sizePt`.
/// Anchoring on the ink instead keeps it at its natural, unscaled
/// position for any `bulletGlyph.sizePt`.
const _bulletGlyphAlignmentY = 0.04416;

pw.Widget _bulletGlyph(CvDesignTokens tokens, CvFontSet fonts) {
  final scale = tokens.bulletGlyph.sizePt / tokens.bullet.sizePt;
  final layoutStyle = tokens.bulletGlyph
      .toPdfStyle(fonts)
      .copyWith(fontSize: tokens.bullet.sizePt);
  return pw.Transform.scale(
    scale: scale,
    alignment: const pw.Alignment(0, _bulletGlyphAlignmentY),
    // Roboto has no glyph for a filled circle (●) — it renders as a tofu
    // box. '•' is covered.
    child: pw.Text('•', style: layoutStyle),
  );
}

pw.Widget _bullets(
  List<ResolvedBullet> bullets,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  if (bullets.isEmpty) return pw.SizedBox.shrink();
  return pw.Padding(
    padding: pw.EdgeInsets.only(
      top: tokens.bulletGap,
      left: tokens.bulletIndent,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final bullet in bullets)
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
            // A Row with a start-aligned cross axis, not an inline
            // TextSpan — mixed-size spans in one RichText share a
            // baseline, so once bulletGlyph's size diverges from bullet's,
            // the glyph reads as floating above/below the text rather than
            // centered on it. Laying the glyph out as its own flex child
            // lets it align against the text independently of its own
            // font size. `start`, not `center`: for a bullet that wraps
            // to multiple lines, the glyph should sit against the FIRST
            // line, not centered against the whole multi-line block —
            // matches the reference template. Doesn't change anything for
            // a single-line bullet, since `_bulletGlyph`'s box height is
            // pinned to `bullet.sizePt` (see its doc comment), the same
            // font size the body RichText uses, so both children's boxes
            // are the same height and `start`/`center` coincide.
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _bulletGlyph(tokens, fonts),
                pw.SizedBox(width: _bulletGlyphGap),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        if (bullet.label != null)
                          pw.TextSpan(
                            text: '${bullet.label}: ',
                            style: tokens.bulletLabel.toPdfStyle(fonts),
                          ),
                        pw.TextSpan(
                          text: bullet.text,
                          style: tokens.bullet.toPdfStyle(fonts),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
      _labelledRow(
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
      ),
      _bullets(position.bullets, tokens, fonts),
    ],
  );
}

/// A promotion: the company is shown once, then each role with its own
/// date range and bullets nested beneath.
pw.Widget _promotionGroup(
  ResolvedCompanyGroup group,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(
        '${group.company} – ${group.location}',
        style: tokens.role.toPdfStyle(fonts),
      ),
      for (final position in group.positions)
        pw.Padding(
          padding: pw.EdgeInsets.only(
            top: tokens.bulletGap,
            left: tokens.bulletIndent,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _labelledRow(
                pw.TextSpan(
                  text: position.role,
                  style: tokens.company.toPdfStyle(fonts),
                ),
                position.dateRange,
                tokens,
                fonts,
              ),
              _bullets(position.bullets, tokens, fonts),
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
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: tokens.itemGap),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _labelledRow(
          pw.TextSpan(
            text: project.title,
            style: tokens.role.toPdfStyle(fonts),
          ),
          project.link,
          tokens,
          fonts,
          rightUrl: project.link == null ? null : _withScheme(project.link!),
        ),
        _bullets(project.bullets, tokens, fonts),
      ],
    ),
  );
}

/// Grade/details fold into the same line as the institution–qualification
/// text, comma-separated — the reference template keeps one education
/// entry to one line, with no second row underneath.
pw.Widget _education(
  ResolvedQualification edu,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  final detail = [
    edu.grade,
    edu.details,
  ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
  final suffix = detail.isEmpty ? '' : ', $detail';

  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
    child: _labelledRow(
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
    ),
  );
}
