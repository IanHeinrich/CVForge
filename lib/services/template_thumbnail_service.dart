import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'pdf_export_service.dart';

/// One cached thumbnail, keyed on the (templateId, cv) pair it was
/// rendered from — see [TemplateThumbnailService.thumbnail]'s doc comment
/// for why the [cv] itself, not just its id, is part of the key.
class _CacheEntry {
  const _CacheEntry(this.cv, this.bytes);

  final ResolvedCv cv;
  final Uint8List bytes;
}

/// A rasterised first page per (template, content) pair, for the template
/// gallery. Renders through [PdfExportService.render] and
/// `Printing.raster` so a thumbnail can never show something the exported
/// PDF wouldn't — same reasoning as `CvTemplate`'s doc comment gives for
/// the live preview: same bytes, not a second hand-built render.
class TemplateThumbnailService {
  /// [raster] is injectable purely so tests can substitute a fake —
  /// `Printing.raster`'s non-web implementation shells out to a native
  /// pdfium binary via FFI that isn't available under `flutter test` on
  /// Linux CI (only macOS/iOS are supported there), unlike
  /// [PdfExportService.render], which stays pure Dart via `package:pdf`.
  TemplateThumbnailService({
    Stream<PdfRaster> Function(
      Uint8List document, {
      List<int>? pages,
      double dpi,
    })?
    raster,
  }) : _raster = raster ?? Printing.raster;

  final _pdfExportService = locator<PdfExportService>();
  final Stream<PdfRaster> Function(
    Uint8List document, {
    List<int>? pages,
    double dpi,
  })
  _raster;

  /// Keyed on templateId; each entry additionally carries the [ResolvedCv]
  /// it was rendered from so a lookup can tell a still-valid entry from a
  /// stale one (see [thumbnail]'s cache-eviction rule) without needing
  /// `ResolvedCv` in the map key itself, which would leak one entry per
  /// edit rather than one per template.
  final _cache = <String, _CacheEntry>{};

  /// Low `dpi` — this is a card-sized thumbnail, not a working preview —
  /// keeps the fifteen-template gallery-open cost (see the doc's Risk 1)
  /// small even though nothing here is debounced.
  static const _thumbnailDpi = 48.0;

  /// Renders (or returns the cached raster for) [templateId]'s first page
  /// of [cv]. The cache is bounded to one entry per template: a lookup
  /// whose cached [cv] no longer equals the one passed in is treated as
  /// stale and evicted before re-rendering, rather than accumulating one
  /// entry per keystroke the way a `(templateId, cv)`-keyed map would.
  /// `ResolvedCv`'s `@freezed` value equality is what makes that
  /// comparison — and the eviction it drives — correct without a revision
  /// counter.
  ///
  /// Throws [PdfExportException] (propagated from [PdfExportService.render])
  /// rather than returning empty bytes — the gallery's failed-card state
  /// is the caller's responsibility, not this service's.
  Future<Uint8List> thumbnail({
    required ResolvedCv cv,
    required String templateId,
    required PdfPageFormat format,
  }) async {
    final cached = _cache[templateId];
    if (cached != null && cached.cv == cv) return cached.bytes;

    final pdfBytes = await _pdfExportService.render(
      cv: cv,
      templateId: templateId,
      format: format,
    );
    final raster = await _raster(
      pdfBytes,
      pages: const [0],
      dpi: _thumbnailDpi,
    ).first;
    final png = await raster.toPng();

    _cache[templateId] = _CacheEntry(cv, png);
    return png;
  }
}
