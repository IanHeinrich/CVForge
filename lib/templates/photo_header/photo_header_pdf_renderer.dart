import 'dart:convert';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'package:cv_forge/templates/design/cv_pdf_renderer.dart';
import 'photo_header_tokens.dart';

/// A tinted full-bleed header band carrying the name, a stacked
/// label/value contact block and a circular photograph, over a body of
/// tracked bold headings on hairline rules with right-aligned dates above
/// each entry.
///
/// Extends [CvPdfRenderer] directly rather than `CompactPdfRenderer`: it
/// overrides every presentation hook, so inheriting from Compact would
/// claim a relationship that no longer exists. The walk that turns a
/// [ResolvedCv] into a flat, page-splittable widget list still comes from
/// the base class, which is the part that must not be reimplemented.
///
/// ### What keeps this ATS-readable
///
/// Nothing an extractor reads moves into the decoration. Name, contact
/// details, headings and body all stay real text in the page *body* —
/// never a `pw.MultiPage` header or footer, which parsers routinely skip —
/// in one column, at full contrast against the tint. The band, the
/// hairlines, the page marks and the photograph are vector fills and a
/// raster; none contributes a text node, so none can be misread.
///
/// Two constructs put text runs on a shared baseline. The contact block's
/// label/value pair is sized to stay well under the 60pt that
/// `AtsAnalyzerService._checkColumnCrush` flags (see
/// [PhotoHeaderStyle.contactLabelWidthPt]). The entry title with its
/// right-aligned date does exceed it — measured at up to ~213pt on a
/// short education line — and so does `CompactPdfRenderer`'s equivalent
/// row, by more (~284pt on the same content).
///
/// That check is modelling a *sidebar*, where merging the two runs
/// left-to-right yields nonsense because they belong to different
/// columns. Here the merge yields the correct reading — "BSc Computer
/// Science at University of Leeds" then "2015" is what the line says — so
/// the finding is a false positive on this pattern rather than a defect
/// to design around. It is called out because the app's own Analyzer will
/// raise it against this template's output, and someone will notice.
///
/// That is as safe as a photo can be made. A photo is still a liability
/// where the market doesn't expect one, which is what `RegionPhotoStance`
/// and Studio's advisory are for.
class PhotoHeaderPdfRenderer extends CvPdfRenderer {
  const PhotoHeaderPdfRenderer({this.style = photoHeaderStyle});

  /// Injectable only so `tool/render_photo_samples.dart` can render
  /// colourways side by side; the app always takes the default.
  final PhotoHeaderStyle style;

  /// Unused: this template stacks contact details as labelled rows rather
  /// than running them together on one line, so there is nothing to
  /// separate. Required by the base class.
  @override
  String get contactSeparator => '';

  @override
  CvTypeToken headlineStyle(CvDesignTokens tokens) => tokens.company;

  @override
  pw.Widget bodyText(String text, CvDesignTokens tokens, CvFontSet fonts) =>
      pw.Text(text, style: tokens.body.toPdfStyle(fonts));

  /// The header occupies exactly the band's remaining height, so the first
  /// section heading starts at the band's bottom edge rather than partway
  /// up it. Derived rather than stated twice: the band is measured from
  /// the top of the page and the content box starts one top margin down.
  double headerHeight(CvDesignTokens tokens, {required bool hasPhoto}) =>
      (hasPhoto ? style.bandHeightPt : style.bandHeightNoPhotoPt) -
      tokens.marginTop;

  @override
  pw.Widget pageHeader(
    ResolvedHeader header,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final photo = header.photoJpegBase64;

    return pw.SizedBox(
      height: headerHeight(tokens, hasPhoto: photo != null),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: _nameAndContact(header, tokens, fonts)),
          // No photo in the Vault yet: the band stays (it is the whole
          // look of this template) but shrinks, and the text takes the
          // full width. Reserving an empty circle would read as a broken
          // image.
          if (photo != null) ...[
            _photo(photo),
            pw.SizedBox(width: style.photoInsetPt),
          ],
        ],
      ),
    );
  }

  /// Name, then one labelled row per contact detail.
  ///
  /// The gap between the name and the first row is expressed as the
  /// reference states it — baseline to baseline — minus the space the name
  /// and the row's own line box already account for, so the number in
  /// [PhotoHeaderStyle.nameToContactPt] stays comparable with the source.
  pw.Widget _nameAndContact(
    ResolvedHeader header,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final rows = <_ContactRow>[
      if (header.location.trim().isNotEmpty)
        _ContactRow('Location', header.location),
      if (header.phone.trim().isNotEmpty) _ContactRow('Phone', header.phone),
      if (header.email.trim().isNotEmpty)
        _ContactRow('Email', header.email, url: 'mailto:${header.email}'),
      for (final link in header.links)
        if (link.url.trim().isNotEmpty)
          _ContactRow(
            link.label.trim().isEmpty ? 'Link' : link.label,
            link.url,
            url: withScheme(link.url),
          ),
    ];

    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(header.fullName, style: tokens.name.toPdfStyle(fonts)),
        if (header.headline.trim().isNotEmpty)
          pw.Text(
            header.headline,
            style: headlineStyle(tokens).toPdfStyle(fonts),
          ),
        if (rows.isNotEmpty) ...[
          pw.SizedBox(height: style.nameToContactPt - tokens.name.sizePt),
          for (final row in rows) _contactRow(row, tokens, fonts),
        ],
      ],
    );
  }

  /// One "Label:  value" row on a shared baseline.
  ///
  /// A fixed-width label box rather than a `pw.Table` or tab stops: it is
  /// the only thing that aligns the values into a column while keeping the
  /// label-to-value gap small and predictable, which is what stops this
  /// reading as a two-column layout to a parser (see the class doc).
  pw.Widget _contactRow(
    _ContactRow row,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    final style = tokens.contact.toPdfStyle(fonts);
    final value = pw.Text(row.value, style: style);

    return pw.SizedBox(
      height: this.style.contactLineHeightPt,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: this.style.contactLabelWidthPt,
            child: pw.Text(
              '${row.label}:',
              style: tokens.contact
                  .copyWith(colorArgb: tokens.mutedInkArgb)
                  .toPdfStyle(fonts),
            ),
          ),
          pw.Expanded(
            child: row.url == null
                ? value
                : pw.UrlLink(destination: row.url!, child: value),
          ),
        ],
      ),
    );
  }

  /// The circle.
  ///
  /// `pw.ClipOval` does the masking, NOT `BoxDecoration(shape:
  /// BoxShape.circle, image: ...)` — verified against `package:pdf`
  /// 3.13.0's source, `DecorationImage.paint` clips with `drawBox`, a
  /// rectangular path, whatever the decoration's shape is. That
  /// combination silently paints a square photo over a round background.
  ///
  /// The ring is a second, outer container rather than a border on the
  /// clip, because a border drawn inside the clip would be masked to half
  /// its width by the very oval it is tracing.
  pw.Widget _photo(String jpegBase64) => pw.Container(
    width: style.photoDiameterPt,
    height: style.photoDiameterPt,
    decoration: pw.BoxDecoration(
      shape: pw.BoxShape.circle,
      border: pw.Border.all(
        color: PdfColor.fromInt(style.photoRingArgb),
        width: style.photoRingPt,
      ),
    ),
    child: pw.Padding(
      padding: pw.EdgeInsets.all(style.photoRingPt),
      child: pw.ClipOval(
        child: pw.Image(
          pw.MemoryImage(base64Decode(jpegBase64)),
          // The stored image is already square (see
          // `ProfilePhotoService.cropAspectRatio`), so cover has nothing
          // left to trim — it is here so a photo saved before the crop
          // became square still fills the circle rather than letterboxing
          // inside it.
          fit: pw.BoxFit.cover,
        ),
      ),
    ),
  );

  /// Tracked bold over a hairline spanning the full content width.
  ///
  /// Unlike Compact, the summary keeps its heading: this template's
  /// summary sits below a band rather than directly under a name, so
  /// without one it reads as an orphaned paragraph.
  @override
  pw.Widget? sectionHeading(
    ResolvedSection section,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      pw.Text(section.title, style: tokens.sectionHeading.toPdfStyle(fonts)),
      pw.SizedBox(height: tokens.sectionRuleGap),
      pw.Container(
        height: tokens.ruleThickness,
        color: PdfColor.fromInt(tokens.ruleColorArgb),
      ),
      pw.SizedBox(height: style.afterRuleGapPt),
    ],
  );

  /// The entry's title with its date range right-aligned on the same
  /// line.
  ///
  /// A deliberate deviation from the reference, which sets the date on its
  /// own line above. Tying the two together reads better — the date is an
  /// attribute of the role, not a heading over it — and reclaims a line
  /// per entry, which this template's open type scale can use.
  ///
  /// `pw.Expanded` on the title (rather than a fixed split) is what keeps
  /// a long role or institution from pushing the date off the page edge;
  /// `CrossAxisAlignment.start` keeps the date on the title's *first*
  /// line when the title wraps.
  pw.Widget _datedEntry(
    String? date,
    pw.Widget title,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) {
    if (date == null || date.trim().isEmpty) return title;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: title),
        pw.SizedBox(width: tokens.sectionGap),
        pw.Text(date, style: tokens.meta.toPdfStyle(fonts)),
      ],
    );
  }

  @override
  pw.Widget positionHeader(
    ResolvedPosition position,
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _datedEntry(
    position.dateRange,
    pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: position.role,
            style: tokens.role.toPdfStyle(fonts),
          ),
          pw.TextSpan(
            text: ' at ${group.company}, ${group.location}',
            style: tokens.company.toPdfStyle(fonts),
          ),
        ],
      ),
    ),
    tokens,
    fonts,
  );

  @override
  pw.Widget promotionCompanyHeading(
    ResolvedCompanyGroup group,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => pw.Text(
    '${group.company}, ${group.location}',
    style: tokens.role.toPdfStyle(fonts),
  );

  @override
  pw.Widget promotionPositionHeading(
    ResolvedPosition position,
    CvDesignTokens tokens,
    CvFontSet fonts,
  ) => _datedEntry(
    position.dateRange,
    pw.Text(position.role, style: tokens.company.toPdfStyle(fonts)),
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
  ) {
    final link = project.link;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(project.title, style: tokens.role.toPdfStyle(fonts)),
        if (link != null && link.trim().isNotEmpty)
          pw.UrlLink(
            destination: withScheme(link),
            child: pw.Text(link, style: tokens.meta.toPdfStyle(fonts)),
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
    final suffix = detail.isEmpty ? '' : ', $detail';
    final location = edu.location;
    final where = location == null || location.trim().isEmpty
        ? edu.institution
        : '${edu.institution}, $location';

    return _datedEntry(
      edu.yearLabel,
      pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: edu.qualification,
              style: tokens.role.toPdfStyle(fonts),
            ),
            pw.TextSpan(
              text: ' at $where$suffix',
              style: tokens.company.toPdfStyle(fonts),
            ),
          ],
        ),
      ),
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

/// One labelled contact detail. A tiny private record-like class rather
/// than a tuple so the call site reads as "Address / value", which is
/// exactly what it prints.
class _ContactRow {
  const _ContactRow(this.label, this.value, {this.url});

  final String label;
  final String value;
  final String? url;
}
