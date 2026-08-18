import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/render/resolved_cv.dart';
import '../cv_template.dart';
import '../design/cv_design_tokens.dart';
import '../design/cv_font_set.dart';
import 'ats_minimal_screen_renderer.dart';
import 'ats_minimal_tokens.dart';

/// A clean, single-column, ATS-friendly layout modelled on the
/// r/EngineeringResumes community template. See `ats_minimal_tokens.dart`
/// for the visual vocabulary and `ats_minimal_screen_renderer.dart` for
/// the Flutter render tree.
class AtsMinimalTemplate implements CvTemplate {
  const AtsMinimalTemplate();

  @override
  String get id => 'ats_minimal';

  @override
  String get displayName => 'ATS Minimal';

  @override
  String get description =>
      'A clean, single-column, sans-serif layout built to pass through '
      'ATS parsers without friction.';

  @override
  CvDesignTokens get tokens => atsMinimalTokens;

  @override
  Widget buildPreview(ResolvedCv cv, PdfPageFormat format) =>
      AtsMinimalScreenRenderer(cv: cv, format: format);

  @override
  pw.Document buildDocument(
    ResolvedCv cv,
    PdfPageFormat format,
    CvFontSet fonts, {
    bool compress = true,
  }) {
    // The PDF renderer is a later sub-phase — the screen preview and the
    // CvTemplate contract both exist ahead of it deliberately, so Studio
    // selection/preview work doesn't need to wait on it.
    throw UnimplementedError(
      'AtsMinimalTemplate.buildDocument: PDF export not implemented yet.',
    );
  }
}
