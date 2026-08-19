import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/render/resolved_cv.dart';
import 'design/cv_design_tokens.dart';
import 'design/cv_font_set.dart';

/// The single-renderer boundary. A template never sees `CvVault`/`CvDraft`
/// — only the [ResolvedCv] `CvComposer` produces — so Studio's live
/// preview (a rasterized render of [buildDocument]'s real output, via
/// `printing.PdfPreview`) and the exported PDF can never drift on content
/// *or* pixels: they're the same bytes.
abstract interface class CvTemplate {
  String get id;
  String get displayName;
  String get description;
  CvDesignTokens get tokens;

  /// The complete exportable document. [compress] defaults to `true`;
  /// tests pass `false` so the resulting PDF's content streams stay
  /// greppable. MUST hand `pw.MultiPage.build` a FLAT `List<pw.Widget>` —
  /// wrapping the body in a single `pw.Column` silently defeats page
  /// splitting.
  pw.Document buildDocument(
    ResolvedCv cv,
    PdfPageFormat format,
    CvFontSet fonts, {
    bool compress = true,
  });
}

/// What a template picker needs to list options — deliberately excludes
/// [CvTemplate.tokens] and the render methods, so building a picker UI
/// never touches a renderer.
class CvTemplateDescriptor {
  const CvTemplateDescriptor({
    required this.id,
    required this.displayName,
    required this.description,
  });

  final String id;
  final String displayName;
  final String description;
}
