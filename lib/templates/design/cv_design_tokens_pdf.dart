import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'cv_design_tokens.dart';
import 'cv_font_set.dart';

/// PDF-side adapter for [CvDesignTokens]/[CvTypeToken] — the ONLY file
/// under `templates/design/` allowed to import `pdf`.
extension CvTypeTokenPdf on CvTypeToken {
  pw.TextStyle toPdfStyle(CvFontSet fonts) => pw.TextStyle(
    font: _selectFont(fonts),
    fontSize: sizePt,
    fontWeight: weight == CvWeight.bold
        ? pw.FontWeight.bold
        : pw.FontWeight.normal,
    fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
    // pw.TextStyle.lineSpacing is already EXTRA points between lines —
    // the same unit this token stores it in, no conversion needed
    // (contrast the Flutter adapter, which must convert to a
    // multiplier).
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
