import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/models/render/resolved_section.dart';
import 'package:cv_forge/templates/cv_template.dart';
import 'package:cv_forge/templates/design/cv_design_tokens.dart';
import 'package:cv_forge/templates/design/cv_design_tokens_pdf.dart';
import 'package:cv_forge/templates/design/cv_font_set.dart';
import 'photo_header_pdf_renderer.dart';
import 'photo_header_tokens.dart';

/// A tinted full-bleed header band with a circular photograph, over a body
/// of tracked bold headings on hairline rules — modelled closely on a
/// reference Lebenslauf layout, for the markets `RegionPhotoStance` marks
/// `expected` or `optional`.
///
/// The photograph comes from the Vault (`ContactBasics.photo`), uploaded
/// once, and this is the only template that prints it: choosing a template
/// is how a user decides whether a given document carries one. See
/// `photo_header_pdf_renderer.dart` for what keeps the rest parseable, and
/// `photo_header_tokens.dart` for where each measurement came from.
class PhotoHeaderTemplate implements CvTemplate {
  const PhotoHeaderTemplate({this.style = photoHeaderStyle});

  /// Injectable only so `tool/render_photo_samples.dart` can render
  /// colourways side by side; the registry always takes the default.
  final PhotoHeaderStyle style;

  @override
  String get id => 'photo_header';

  @override
  CvDesignTokens get tokens => photoHeaderTokens;

  /// [TemplateTag.atsSafe] applies here for the reason it applies to the
  /// other two: every word on the page is real text in a single column,
  /// so a parser reads it cleanly. It was once withheld to warn about the
  /// photograph, which conflated two different risks — see
  /// [TemplateTag.atsSafe]'s own doc comment. The photograph's market
  /// risk is a human screening question, and [description] is where it is
  /// said plainly rather than implied by a missing tag.
  /// [TemplateTag.modern], not [TemplateTag.traditional]: this template is
  /// called "Modern with photo", and Classic Centered is called
  /// "Traditional", so tagging this one `traditional` printed another
  /// template's *name* on this one's card.
  @override
  Set<TemplateTag> get tags => const {
    TemplateTag.atsSafe,
    TemplateTag.photo,
    TemplateTag.modern,
  };

  /// Same order as Compact. A photo changes the header, not what a market
  /// wants to read first.
  @override
  List<CvSectionType> get sectionOrder => CvSectionType.values;

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
    final hasPhoto = cv.header.photoJpegBase64 != null;
    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format,
          margin: tokens.pageMargins,
          buildBackground: (context) =>
              _decoration(context, hasPhoto: hasPhoto),
        ),
        // Pages two and up get back the top margin that page one gives up
        // to seat the name high inside the band. Without this the body
        // would start 32pt from the top of every continuation page against
        // 57pt side margins, which reads as a mistake.
        header: (context) => pw.SizedBox(
          height: context.pageNumber == 1 ? 0 : style.continuationTopPt,
        ),
        build: (context) => PhotoHeaderPdfRenderer(style: style).build(
          cv,
          tokens,
          fonts,
          preventOrphansAndSplits: preventOrphansAndSplits,
        ),
      ),
    );
    return doc;
  }

  /// The band and the two accent marks, painted behind the page.
  ///
  /// A page background rather than widgets in the flat list, because all
  /// three have to bleed past the margins and no widget inside the content
  /// box can reach them. `pw.FullPage(ignoreMargins: true)` is what
  /// escapes them.
  ///
  /// The band and the top mark are page one only — `buildBackground` runs
  /// for every page, so without the check a two-page CV would wear the
  /// band again above its second page of bullets.
  /// `PhotoHeaderPdfRenderer.headerHeight` reserves matching space in the
  /// content box, so the two cannot drift. The foot mark repeats, because
  /// it is a page mark rather than part of the header.
  pw.Widget _decoration(pw.Context context, {required bool hasPhoto}) {
    final firstPage = context.pageNumber == 1;
    return pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(
        children: [
          if (firstPage)
            pw.Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: pw.Container(
                height: hasPhoto
                    ? style.bandHeightPt
                    : style.bandHeightNoPhotoPt,
                color: PdfColor.fromInt(style.bandFillArgb),
              ),
            ),
          if (firstPage)
            pw.Positioned(
              top: style.markTopYPt,
              left: 0,
              child: _mark(style.markTopWidthPt, style.markTopHeightPt),
            ),
          pw.Positioned(
            bottom: 0,
            right: style.markBottomRightPt,
            child: _mark(style.markBottomWidthPt, style.markBottomHeightPt),
          ),
        ],
      ),
    );
  }

  pw.Widget _mark(double width, double height) => pw.Container(
    width: width,
    height: height,
    color: PdfColor.fromInt(style.accentArgb),
  );

  /// Every skill across every visible skill group, comma-separated — see
  /// `CompactTemplate._keywords` for why the metadata dictionary matters.
  String _keywords(ResolvedCv cv) => [
    for (final section in cv.sections)
      if (section is ResolvedSkillsSection)
        for (final group in section.groups) ...group.skills,
  ].join(', ');
}
