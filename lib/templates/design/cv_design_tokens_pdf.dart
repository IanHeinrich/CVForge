import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:cv_forge/models/region/region_profile.dart';
import 'cv_design_tokens.dart';
import 'cv_font_set.dart';

/// PDF-side adapter for [CvDesignTokens]/[CvTypeToken] — the one place a
/// framework-free token becomes a `pw.TextStyle`.
///
/// Not the only file here that imports `pdf`: `bullet_list_pdf.dart`,
/// `section_pagination_pdf.dart`, `cv_markup_pdf.dart` and the renderer
/// itself all do. The convention is the `*_pdf.dart` suffix, and what
/// this file owns specifically is the token→style mapping.
extension CvTypeTokenPdf on CvTypeToken {
  pw.TextStyle toPdfStyle(CvFontSet fonts) => pw.TextStyle(
    font: _selectFont(fonts),
    fontSize: sizePt,
    fontWeight: weight == CvWeight.bold
        ? pw.FontWeight.bold
        : pw.FontWeight.normal,
    fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
    // pw.TextStyle.lineSpacing is already EXTRA points between lines —
    // the same unit lineSpacingPt is stored in, so no conversion is
    // needed here.
    lineSpacing: lineSpacingPt,
    letterSpacing: letterSpacingPt,
    color: colorArgb == null ? null : PdfColor.fromInt(colorArgb!),
  );

  pw.Font _selectFont(CvFontSet fonts) {
    final bold = weight == CvWeight.bold;
    if (bold && italic) return fonts.boldItalic;
    if (bold) return fonts.bold;
    if (italic) return fonts.italic;
    return fonts.base;
  }
}

extension CvDesignTokensPdf on CvDesignTokens {
  pw.EdgeInsets get pageMargins =>
      pw.EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom);
}

extension PdfPageFormatTokenPdf on PdfPageFormatToken {
  PdfPageFormat get toPdfPageFormat => switch (this) {
    PdfPageFormatToken.a4 => PdfPageFormat.a4,
    PdfPageFormatToken.letter => PdfPageFormat.letter,
  };
}
