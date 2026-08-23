import 'package:freezed_annotation/freezed_annotation.dart';

import 'ats_document_info.dart';
import 'ats_font_info.dart';
import 'ats_link_annotation.dart';
import 'ats_text_node.dart';

part 'ats_extracted_document.freezed.dart';

/// The full wire shape `PdfExtractionService` marshals out of `pdf.js` —
/// everything `AtsAnalyzerService` needs, and nothing it has to reach back
/// into the interop layer for. This is the seam regression fixtures are
/// captured at: a JSON dump of this shape (with `str` redacted or
/// synthetic) is what makes the analyzer regression-testable on the
/// Flutter VM despite the extraction layer only running in a browser.
@freezed
abstract class AtsExtractedDocument with _$AtsExtractedDocument {
  const factory AtsExtractedDocument({
    required AtsDocumentInfo info,
    required List<AtsTextNode> nodes,

    /// Keyed by `AtsTextNode.fontName`.
    required Map<String, AtsFontInfo> fonts,
    @Default(<AtsLinkAnnotation>[]) List<AtsLinkAnnotation> links,
  }) = _AtsExtractedDocument;
}
