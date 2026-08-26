import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/bullet_list_pdf.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'package:cv_forge/templates/design/section_pagination_pdf.dart';

/// A PDF hyperlink destination needs an explicit scheme. Vault links are
/// entered casually (e.g. "linkedin.com/in/jordanellery"), so add one
/// rather than requiring the user to type "https://" themselves.
String withScheme(String url) =>
    url.startsWith('http://') || url.startsWith('https://')
    ? url
    : 'https://$url';

/// The render tree every CV template shares, with the parts that actually
/// differ between templates left as overridable hooks.
///
/// What lives here rather than in a template is everything load-bearing
/// for pagination: producing a FLAT top-level widget list, and routing
/// every heading+items group through [assembleSectionWidgets]. See
/// `CvTemplate.buildDocument`'s doc comment for what goes wrong when a
/// renderer nests a `pw.Column` instead — a template that reimplements
/// this walk reintroduces both the stranded-heading and mid-entry-split
/// bugs, so subclasses supply *widgets*, never structure.
///
/// What a subclass overrides is presentation only: how a section heading
/// looks (or whether it appears at all), how body prose is aligned, and
/// how each entry type's header row is laid out.
abstract class CvPdfRenderer {
  const CvPdfRenderer();

  /// Rendered between contact items in the page header.
  String get contactSeparator;

  /// The headline immediately under the name.
  CvTypeToken headlineStyle(CvDesignTokens tokens);

  /// Null renders the section with no heading at all — how a template
  /// drops the heading for, say, a summary that reads as part of the page
  /// header. The title text is the subclass's to choose too, so a template
  /// can rename a section without `CvComposer` knowing.
  pw.Widget? sectionHeading(
    ResolvedSection section,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  /// Summary, hobbies and references prose.
  pw.Widget bodyText(String text, CvDesignTokens tokens, CvFontSet fonts);

  pw.Widget positionHeader(
    ResolvedPosition position,
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  /// The company shown once above a promotion's roles.
  pw.Widget promotionCompanyHeading(
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  /// One role within a promotion. The vertical gap above it is applied by
  /// [_promotionGroup]; only [promotionPositionIndent] shifts it sideways.
  pw.Widget promotionPositionHeading(
    ResolvedPosition position,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  /// How far a promotion's roles indent under their company heading.
  double promotionPositionIndent(CvDesignTokens tokens) => 0;

  pw.Widget projectHeader(
    ResolvedProject project,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  pw.Widget educationHeader(
    ResolvedQualification edu,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  pw.Widget publicationHeader(
    ResolvedPublication publication,
    CvDesignTokens tokens,
    CvFontSet fonts,
  );

  /// Returns a FLAT top-level widget list, one entry per header/heading/
  /// item rather than one enclosing `pw.Column` — feeding
  /// `pw.MultiPage.build` a single nested `pw.Column` silently defeats its
  /// page-splitting (see `CvTemplate.buildDocument`'s doc comment). See
  /// [assembleSectionWidgets]'s doc comment for [preventOrphansAndSplits].
  List<pw.Widget> build(
    ResolvedCv cv,
    CvDesignTokens tokens,
    CvFontSet fonts, {
    bool preventOrphansAndSplits = true,
  }) {
    final widgets = <pw.Widget>[pageHeader(cv.header, tokens, fonts)];
    for (final section in cv.sections) {
      widgets.add(pw.SizedBox(height: tokens.sectionGap));
      widgets.addAll(
        assembleSectionWidgets(
          heading: sectionHeading(section, tokens, fonts),
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

  /// The whole page header. Defaults to [headerTextBlock] alone; override
  /// to place something alongside it — a photograph, say — while still
  /// reusing that block rather than rebuilding the contact line.
  ///
  /// Whatever this returns is the FIRST entry in [build]'s flat top-level
  /// list, so it is free to be a `pw.Row` or any other multi-child layout:
  /// a header is one block that either fits on page one or doesn't. That
  /// licence does not extend to the body, where the nested-`pw.Column`
  /// rule in `CvTemplate.buildDocument`'s doc comment still binds.
  pw.Widget pageHeader(
    ResolvedHeader header,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => headerTextBlock(header, tokens, fonts);

  /// Name, headline and contact line, stacked and centered. Shared whole
  /// — the templates that use it differ only in [contactSeparator] and
  /// [headlineStyle]. A template wanting a different header shape
  /// overrides [pageHeader] and builds its own (see
  /// `PhotoHeaderPdfRenderer`).
  pw.Widget headerTextBlock(
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
          contactPart(link.url, url: withScheme(link.url)),
    ];

    // Deliberately NOT one of [contactParts]. It is a sentence the user
    // wrote, so among the location and the email it reads as one more
    // datum; and as a single cell of a pw.Wrap it could not break, so a
    // long one ran off the right margin instead of wrapping. Its own
    // full-width line fixes both.
    final workAuthorization = header.workAuthorization?.trim() ?? '';

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
            style: headlineStyle(tokens).toPdfStyle(fonts),
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
                if (i > 0) pw.Text(contactSeparator, style: contactStyle),
                contactParts[i],
              ],
            ],
          ),
        ],
        if (workAuthorization.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          // Unlabelled: the user wrote the whole sentence, which is what
          // keeps this from needing a heading transcribed into every
          // document language. A plain pw.Text under the stretched column
          // takes the full width, so it wraps on its own.
          pw.Text(
            workAuthorization,
            textAlign: pw.TextAlign.center,
            style: contactStyle,
          ),
        ],
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
    ResolvedSummarySection(text: final text) => [bodyText(text, tokens, fonts)],
    ResolvedSkillsSection(groups: final groups) => _skillGroups(
      groups,
      tokens,
      fonts,
    ),
    ResolvedExperienceSection(groups: final groups) => interleaveWithGaps([
      for (final group in groups)
        _companyGroup(
          group,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
    ], tokens.itemGap),
    ResolvedProjectsSection(items: final items) => interleaveWithGaps([
      for (final project in items)
        _entry(
          projectHeader(project, tokens, fonts),
          project.bullets,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
    ], tokens.itemGap),
    ResolvedEducationSection(items: final items) => interleaveWithGaps([
      for (final edu in items)
        _entry(
          educationHeader(edu, tokens, fonts),
          edu.bullets,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
      // [itemGap], like every other multi-entry section. This case used
      // [bulletGap] — the gap *inside* an entry — with no stated reason,
      // which left qualifications packed tighter than the projects and
      // publications either side of them.
    ], tokens.itemGap),
    ResolvedLanguagesSection(items: final items) => _languageRows(
      items,
      tokens,
      fonts,
    ),
    ResolvedHobbiesSection(items: final items) => [
      bodyText(items.join(', '), tokens, fonts),
    ],
    ResolvedReferencesSection(text: final text) => [
      bodyText(text, tokens, fonts),
    ],
    ResolvedPublicationsSection(items: final items) => interleaveWithGaps([
      for (final publication in items)
        _entry(
          publicationHeader(publication, tokens, fonts),
          publication.bullets,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
    ], tokens.itemGap),
  };

  /// A heading glued to its own bullets — the shape every project,
  /// qualification, publication and position entry takes, and the one
  /// place [assembleSectionWidgets] is handed an entry's bullets.
  List<pw.Widget> _entry(
    pw.Widget heading,
    List<ResolvedBullet> bullets,
    CvDesignTokens tokens,
    CvFontSet fonts, {
    required bool preventOrphansAndSplits,
  }) => assembleSectionWidgets(
    heading: heading,
    body: [for (final b in bullets) buildBulletRow(b, tokens, fonts)],
    gap: tokens.bulletGap,
    preventOrphansAndSplits: preventOrphansAndSplits,
  );

  /// One company group flattened to top-level widgets — no trailing gap
  /// here; [tokens.itemGap] is interleaved *between* groups by the caller
  /// (see `interleaveWithGaps`'s doc comment for why a trailing spacer as
  /// its own top-level widget can silently produce a blank page).
  List<pw.Widget> _companyGroup(
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts, {
    required bool preventOrphansAndSplits,
  }) {
    if (group.positions.length == 1) {
      final position = group.positions.single;
      return _entry(
        positionHeader(position, group, tokens, fonts),
        position.bullets,
        tokens,
        fonts,
        preventOrphansAndSplits: preventOrphansAndSplits,
      );
    }
    return _promotionGroup(
      group,
      tokens,
      fonts,
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
    final positionItems = <pw.Widget>[
      for (final position in group.positions)
        ..._entry(
          pw.Padding(
            padding: pw.EdgeInsets.only(
              top: tokens.bulletGap,
              left: promotionPositionIndent(tokens),
            ),
            child: promotionPositionHeading(position, tokens, fonts),
          ),
          position.bullets,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
    ];
    return assembleSectionWidgets(
      heading: promotionCompanyHeading(group, tokens, fonts),
      body: positionItems,
      preventOrphansAndSplits: preventOrphansAndSplits,
    );
  }

  /// One language per line, laid out like a skills group — the name as
  /// the inline label, the level as the value beside it. Concrete enough
  /// that a reader scanning for "does this person speak German" finds it
  /// on its own line, and shared by every template for the same reason
  /// [_skillGroups] is: nothing here is a presentation choice a template
  /// would want to make differently.
  List<pw.Widget> _languageRows(
    List<ResolvedLanguage> items,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => [
    for (final language in items)
      pw.Padding(
        padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                // No trailing colon when there is no level to introduce.
                text: language.level == null
                    ? language.name
                    : '${language.name}: ',
                style: tokens.inlineLabel.toPdfStyle(fonts),
              ),
              if (language.level case final level?)
                pw.TextSpan(text: level, style: tokens.body.toPdfStyle(fonts)),
            ],
          ),
        ),
      ),
  ];

  List<pw.Widget> _skillGroups(
    List<ResolvedSkillGroup> groups,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => [
    for (final group in groups)
      pw.Padding(
        padding: pw.EdgeInsets.only(bottom: tokens.bulletGap),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '${group.category}: ',
                style: tokens.inlineLabel.toPdfStyle(fonts),
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
