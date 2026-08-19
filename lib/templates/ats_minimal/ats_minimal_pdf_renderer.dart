import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/render/resolved_cv.dart';
import '../../models/render/resolved_section.dart';
import '../design/cv_design_tokens.dart';
import '../design/cv_design_tokens_pdf.dart';
import '../design/cv_font_set.dart';
import 'ats_minimal_tokens.dart';

/// Horizontal gap between the bullet glyph and the text beside it — a
/// fixed layout constant, not a design token, since it's a spacing
/// artifact of the glyph/text split rather than something a template
/// would want to restyle.
const _bulletGlyphGap = 6.0;

/// `pw`-only rendering of [ResolvedCv] in the `ats_minimal` style, mirroring
/// `ats_minimal_screen_renderer.dart` section-for-section so the two render
/// trees can't drift on content — only on pixels.
///
/// Returns a FLAT top-level widget list, one entry per header/heading/item
/// rather than one enclosing `pw.Column` — feeding `pw.MultiPage.build` a
/// single nested `pw.Column` silently defeats its page-splitting (see
/// `CvTemplate.buildDocument`'s doc comment).
List<pw.Widget> buildAtsMinimalPdfContent(ResolvedCv cv, CvFontSet fonts) {
  final widgets = <pw.Widget>[_header(cv.header, fonts)];
  for (final section in cv.sections) {
    widgets.add(pw.SizedBox(height: atsMinimalTokens.sectionGap));
    // The summary sits directly under the header with no heading of its
    // own — matches the screen renderer's `isSummary` special case.
    if (section is! ResolvedSummarySection) {
      widgets.add(_sectionHeading(section.title, fonts));
    }
    widgets.addAll(_sectionBody(section, fonts));
  }
  return widgets;
}

pw.Widget _header(ResolvedHeader header, CvFontSet fonts) {
  final contactStyle = atsMinimalTokens.contact.toPdfStyle(fonts);

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
        style: atsMinimalTokens.name.toPdfStyle(fonts),
      ),
      if (header.headline.trim().isNotEmpty) ...[
        pw.SizedBox(height: 2),
        pw.Text(
          header.headline,
          textAlign: pw.TextAlign.center,
          style: atsMinimalTokens.company.toPdfStyle(fonts),
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

pw.Widget _sectionHeading(String title, CvFontSet fonts) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(title, style: atsMinimalTokens.sectionHeading.toPdfStyle(fonts)),
      pw.SizedBox(height: atsMinimalTokens.sectionRuleGap),
      pw.Container(
        height: atsMinimalTokens.ruleThickness,
        color: PdfColor.fromInt(atsMinimalTokens.ruleColorArgb),
      ),
      pw.SizedBox(height: atsMinimalTokens.sectionRuleGap),
    ],
  );
}

/// One top-level widget per item within [section]'s body, so `MultiPage`
/// can split between e.g. two experience entries, not just between whole
/// sections.
List<pw.Widget> _sectionBody(ResolvedSection section, CvFontSet fonts) =>
    switch (section) {
      ResolvedSummarySection(text: final text) => [_bodyText(text, fonts)],
      ResolvedSkillsSection(groups: final groups) => _skillGroups(
        groups,
        fonts,
      ),
      ResolvedExperienceSection(groups: final groups) => [
        for (final group in groups) _companyGroup(group, fonts),
      ],
      ResolvedProjectsSection(items: final items) => [
        for (final project in items) _project(project, fonts),
      ],
      ResolvedEducationSection(items: final items) => [
        for (final edu in items) _education(edu, fonts),
      ],
      ResolvedHobbiesSection(items: final items) => [
        _bodyText(items.join(', '), fonts),
      ],
      ResolvedReferencesSection(text: final text) => [_bodyText(text, fonts)],
    };

pw.Widget _bodyText(String text, CvFontSet fonts) =>
    pw.Text(text, style: atsMinimalTokens.body.toPdfStyle(fonts));

/// A left label + right value on one row — the "role, dates" and
/// "institution, year" rows every section but Skills uses. `pw.Expanded`
/// inside `pw.Row` (rather than a manual width split) is what keeps long
/// role/company text from pushing the date range off the page edge.
/// [rightUrl], when given, makes the right-hand value (e.g. a project
/// link) a clickable hyperlink rather than plain text.
pw.Widget _labelledRow(
  pw.InlineSpan left,
  String? right,
  CvFontSet fonts, {
  String? rightUrl,
}) {
  final rightWidget = right == null || right.isEmpty
      ? null
      : pw.Text(right, style: atsMinimalTokens.meta.toPdfStyle(fonts));

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
/// `Transform.scale`'s default `Alignment.center` anchors the scale on the
/// *box's* geometric center — the font's full ascent/descent box, not the
/// `•` glyph's own ink. In Roboto, that ink sits slightly above the true
/// box center (measured from `Roboto-Regular.ttf`: ascent 0.9277em,
/// descent -0.2441em, glyph ink spans 0.2612em-0.4741em above the
/// baseline, i.e. an ink center at 0.3677em vs. the box's own center at
/// 0.3599em of its 1.1719em height — only ~0.008em off). Scaling around
/// the mismatched box-center anchor drags the ink away from its natural
/// position by an amount proportional to (scale-1), which is what made it
/// float visibly at `bulletGlyph.sizePt: 25` despite barely registering at
/// `bullet.sizePt: 10`.
///
/// [_bulletGlyphAlignmentY] is the box-center-relative offset that instead
/// anchors the scale exactly on the glyph's own ink center. Because
/// `Transform.scale`'s alignment is a *fraction* of the (fixed,
/// bullet.sizePt-based) box, anchoring on the ink keeps the glyph's ink at
/// its natural, unscaled position — the same place it would sit if printed
/// plain at whatever size — for any `bulletGlyph.sizePt`, not just the one
/// last checked against a real export.
const _bulletGlyphAlignmentY = 0.04416;

pw.Widget _bulletGlyph(CvFontSet fonts) {
  final scale =
      atsMinimalTokens.bulletGlyph.sizePt / atsMinimalTokens.bullet.sizePt;
  final layoutStyle = atsMinimalTokens.bulletGlyph
      .toPdfStyle(fonts)
      .copyWith(fontSize: atsMinimalTokens.bullet.sizePt);
  return pw.Transform.scale(
    scale: scale,
    alignment: const pw.Alignment(0, _bulletGlyphAlignmentY),
    // Roboto has no glyph for a filled circle (●) — it renders as a tofu
    // box. '•' is covered.
    child: pw.Text('•', style: layoutStyle),
  );
}

pw.Widget _bullets(List<ResolvedBullet> bullets, CvFontSet fonts) {
  if (bullets.isEmpty) return pw.SizedBox.shrink();
  return pw.Padding(
    padding: pw.EdgeInsets.only(
      top: atsMinimalTokens.bulletGap,
      left: atsMinimalTokens.bulletIndent,
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (final bullet in bullets)
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: atsMinimalTokens.bulletGap),
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
                _bulletGlyph(fonts),
                pw.SizedBox(width: _bulletGlyphGap),
                pw.Expanded(
                  child: pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        if (bullet.label != null)
                          pw.TextSpan(
                            text: '${bullet.label}: ',
                            style: atsMinimalTokens.bulletLabel.toPdfStyle(
                              fonts,
                            ),
                          ),
                        pw.TextSpan(
                          text: bullet.text,
                          style: atsMinimalTokens.bullet.toPdfStyle(fonts),
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

/// Splits [groups] across [CvDesignTokens.skillColumnCount] columns,
/// filling all of the first column before the next — matches
/// `ats_minimal`'s current single-column token, but generalises to a
/// future template whose token sets more than one.
List<pw.Widget> _skillGroups(List<ResolvedSkillGroup> groups, CvFontSet fonts) {
  final columnCount = atsMinimalTokens.skillColumnCount.clamp(
    1,
    groups.isEmpty ? 1 : groups.length,
  );
  final perColumn = (groups.length / columnCount).ceil();
  final columns = <List<ResolvedSkillGroup>>[
    for (var i = 0; i < columnCount; i++)
      groups.skip(i * perColumn).take(perColumn).toList(),
  ];

  pw.Widget groupLine(ResolvedSkillGroup group) => pw.Padding(
    padding: pw.EdgeInsets.only(bottom: atsMinimalTokens.bulletGap),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '${group.category}: ',
            style: atsMinimalTokens.bulletLabel.toPdfStyle(fonts),
          ),
          pw.TextSpan(
            text: group.skills.join(', '),
            style: atsMinimalTokens.body.toPdfStyle(fonts),
          ),
        ],
      ),
    ),
  );

  if (columnCount <= 1) {
    return [for (final group in groups) groupLine(group)];
  }

  return [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns.length; i++) ...[
          if (i > 0) pw.SizedBox(width: atsMinimalTokens.skillColumnGap),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [for (final group in columns[i]) groupLine(group)],
            ),
          ),
        ],
      ],
    ),
  ];
}

pw.Widget _companyGroup(ResolvedCompanyGroup group, CvFontSet fonts) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: atsMinimalTokens.itemGap),
    child: group.positions.length == 1
        ? _singlePosition(group.positions.single, group, fonts)
        : _promotionGroup(group, fonts),
  );
}

pw.Widget _singlePosition(
  ResolvedPosition position,
  ResolvedCompanyGroup group,
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
              style: atsMinimalTokens.role.toPdfStyle(fonts),
            ),
            pw.TextSpan(
              text: '${group.company} – ${group.location}',
              style: atsMinimalTokens.company.toPdfStyle(fonts),
            ),
          ],
        ),
        position.dateRange,
        fonts,
      ),
      _bullets(position.bullets, fonts),
    ],
  );
}

/// A promotion: the company is shown once, then each role with its own
/// date range and bullets nested beneath.
pw.Widget _promotionGroup(ResolvedCompanyGroup group, CvFontSet fonts) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(
        '${group.company} – ${group.location}',
        style: atsMinimalTokens.role.toPdfStyle(fonts),
      ),
      for (final position in group.positions)
        pw.Padding(
          padding: pw.EdgeInsets.only(
            top: atsMinimalTokens.bulletGap,
            left: atsMinimalTokens.bulletIndent,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _labelledRow(
                pw.TextSpan(
                  text: position.role,
                  style: atsMinimalTokens.company.toPdfStyle(fonts),
                ),
                position.dateRange,
                fonts,
              ),
              _bullets(position.bullets, fonts),
            ],
          ),
        ),
    ],
  );
}

pw.Widget _project(ResolvedProject project, CvFontSet fonts) {
  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: atsMinimalTokens.itemGap),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _labelledRow(
          pw.TextSpan(
            text: project.title,
            style: atsMinimalTokens.role.toPdfStyle(fonts),
          ),
          project.link,
          fonts,
          rightUrl: project.link == null ? null : _withScheme(project.link!),
        ),
        _bullets(project.bullets, fonts),
      ],
    ),
  );
}

/// Grade/details fold into the same line as the institution–qualification
/// text, comma-separated — the reference template keeps one education
/// entry to one line, with no second row underneath.
pw.Widget _education(ResolvedQualification edu, CvFontSet fonts) {
  final detail = [
    edu.grade,
    edu.details,
  ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
  final suffix = detail.isEmpty ? '' : ', $detail';

  return pw.Padding(
    padding: pw.EdgeInsets.only(bottom: atsMinimalTokens.bulletGap),
    child: _labelledRow(
      pw.TextSpan(
        children: [
          pw.TextSpan(
            text: edu.institution,
            style: atsMinimalTokens.role.toPdfStyle(fonts),
          ),
          pw.TextSpan(
            text: ' – ${edu.qualification}$suffix',
            style: atsMinimalTokens.company.toPdfStyle(fonts),
          ),
        ],
      ),
      edu.yearLabel,
      fonts,
    ),
  );
}
