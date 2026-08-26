import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'package:cv_forge/templates/design/cv_markup_pdf.dart';
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
  pw.TextAlign? get bodyAlign => pw.TextAlign.justify;

  /// Centered, bold, no rule — the reference this template clones leans on
  /// whitespace rather than a line to separate sections. Experience takes
  /// the longer register here, matching that reference, while `compact`
  /// keeps the shorter shared title.
  ///
  /// Both come resolved from the composer. This used to be a literal
  /// "Professional Experience", which overrode the translated title and
  /// so printed English on a CV written in any other language.
  @override
  pw.Widget sectionHeading(
    ResolvedSection section,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final title = switch (section) {
      ResolvedExperienceSection(titleFormal: final formal) => formal,
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
      _headerRow(
        markupSpans(group.company, tokens.role, fonts),
        _metaSpans(position.dateRange, tokens, fonts),
        tokens,
        fonts,
      ),
      _headerRow(
        markupSpans(position.role, tokens.company, fonts),
        markupSpans(group.location, tokens.meta, fonts),
        tokens,
        fonts,
      ),
    ],
  );

  @override
  pw.Widget promotionCompanyHeading(
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _headerRow(
    markupSpans(group.company, tokens.role, fonts),
    markupSpans(group.location, tokens.meta, fonts),
    tokens,
    fonts,
  );

  @override
  pw.Widget promotionPositionHeading(
    ResolvedPosition position,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _headerRow(
    markupSpans(position.role, tokens.company, fonts),
    _metaSpans(position.dateRange, tokens, fonts),
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
        markupText(project.title, tokens.role, fonts),
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
    // Parsed per field and glued with unparsed separators, so a stray
    // marker in `grade` can never pair with one in `details`.
    final detail = [
      edu.grade,
      edu.details,
    ].where((s) => s != null && s.trim().isNotEmpty).cast<String>();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _headerRow(
          markupSpans(edu.institution, tokens.role, fonts),
          markupSpans(edu.location ?? '', tokens.meta, fonts),
          tokens,
          fonts,
        ),
        _headerRow(
          [
            ...markupSpans(edu.qualification, tokens.company, fonts),
            if (detail.isNotEmpty) ...[
              literalSpan(', ', tokens.company, fonts),
              ...markupJoin(detail, ', ', tokens.company, fonts),
            ],
          ],
          _metaSpans(edu.yearLabel, tokens, fonts),
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
      markupText(publication.title, tokens.body, fonts),
      if (citation != null && citation.trim().isNotEmpty)
        markupText(citation, tokens.body, fonts),
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

/// One row of the two-row entry header: [left] styled bold/italic per its
/// own spans, [right] in the plain `meta` style, right-aligned.
/// `pw.Expanded` keeps a long left value from pushing [right] off the
/// page edge.
///
/// Both sides are spans rather than strings because either can be user
/// text — a company and an entry location are typed, a date range and a
/// year label are formatted by `CvComposer` — and only the caller knows
/// which it is holding.
pw.Widget _headerRow(
  List<pw.InlineSpan> left,
  List<pw.InlineSpan>? right,
  CvDesignTokens tokens,
  CvFontSet fonts,
) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: pw.RichText(text: pw.TextSpan(children: left)),
      ),
      if (right != null && right.isNotEmpty)
        pw.RichText(text: pw.TextSpan(children: right)),
    ],
  );
}

/// [value] as `meta`-styled spans, or null when there is nothing to show
/// — the shape [_headerRow]'s right-hand side wants for a composer
/// formatted value that is never parsed for emphasis.
List<pw.InlineSpan>? _metaSpans(
  String? value,
  CvDesignTokens tokens,
  CvFontSet fonts,
) => value == null || value.isEmpty
    ? null
    : [literalSpan(value, tokens.meta, fonts)];
