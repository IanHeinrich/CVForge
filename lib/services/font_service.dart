import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

import '../templates/design/cv_font_set.dart';

/// Loads the Roboto TTFs declared under `assets/fonts/` into [pw.Font]
/// objects, caching the result so an export never reloads them.
///
/// `ats_minimal` uses Roboto, not the Liberation Serif this project first
/// evaluated for glyph coverage — Roboto covers the same Latin-1 + smart
/// quotes + en/em dash + €/£ set, verified by the Unicode regression case
/// in `pdf_export_service_test.dart`.
class FontService {
  // Caches the in-flight Future, not just its resolved value — otherwise
  // two calls to load() racing ahead of the first's completion (e.g.
  // warmUp() at startup and an impatient export) would each kick off their
  // own rootBundle.load(), matching the _readyFuture pattern the other
  // services in this project use for the same reason.
  Future<CvFontSet>? _loadFuture;

  /// Loads and caches the font set if it isn't already, then returns it.
  Future<CvFontSet> load() => _loadFuture ??= _loadFonts();

  /// Fire-and-forget warm-up so fonts are already cached by the time a user
  /// clicks export. Not awaited by callers — `load()` still awaits the same
  /// underlying future if a caller races ahead of warm-up finishing.
  Future<void> warmUp() => load();

  Future<CvFontSet> _loadFonts() async {
    final results = await Future.wait([
      _loadFont('assets/fonts/Roboto-Regular.ttf'),
      _loadFont('assets/fonts/Roboto-Bold.ttf'),
      _loadFont('assets/fonts/Roboto-Italic.ttf'),
      _loadFont('assets/fonts/Roboto-BoldItalic.ttf'),
    ]);
    return CvFontSet(
      base: results[0],
      bold: results[1],
      italic: results[2],
      boldItalic: results[3],
    );
  }

  Future<pw.Font> _loadFont(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return pw.Font.ttf(data);
  }
}
