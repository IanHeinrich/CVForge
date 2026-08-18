import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/render/resolved_cv.dart';
import 'design/cv_design_tokens.dart';
import 'design/cv_font_set.dart';

/// The dual-renderer boundary. A template never sees `CvVault`/`CvDraft` —
/// only the [ResolvedCv] `CvComposer` produces — so the screen preview and
/// the PDF export can't drift on *content*, only on pixels.
abstract interface class CvTemplate {
  String get id;
  String get displayName;
  String get description;
  CvDesignTokens get tokens;

  /// Page content laid out in PDF points, at natural height — the caller
  /// (`CvPageSurface`) owns scaling to fit the viewport, so this widget
  /// stays reusable for a future thumbnail picker too.
  Widget buildPreview(ResolvedCv cv, PdfPageFormat format);

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
