import 'dart:typed_data';

import 'package:printing/printing.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/ats/ats_font_info.dart';
import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';

/// One rasterized page plus the ink-box rect for every node on it, keyed
/// by its index into `AtsExtractedDocument.nodes` — the same index
/// `AtsFindingEvidence.nodeIndex` uses, so a finding's evidence resolves
/// straight into this map with no re-derivation.
class XrayPageData {
  XrayPageData({
    required this.raster,
    required this.rectByNodeIndex,
    required this.orderedNodeIndices,
  });

  final PdfRaster raster;
  final Map<int, AtsPixelRect> rectByNodeIndex;

  /// Extraction order, restricted to this page — the ambient-box paint
  /// order and the flow-lines connection order are the same thing.
  final List<int> orderedNodeIndices;
}

/// Loads and caches one [XrayPageData] per page for [AnalyzerXrayPanel] —
/// the raster/geometry loading concern, kept separate from the panel's
/// camera and selection state.
class XrayPageLoader {
  XrayPageLoader({
    required this.pdfBytes,
    required this.nodes,
    required this.fonts,
  });

  /// Arbitrary but fixed — the raster and `getPageViewportTransform` must
  /// agree on the exact same dpi, or the two spaces are no longer the
  /// same scale (see `PdfExtractionService`'s doc comment).
  static const dpi = 150.0;

  final Uint8List pdfBytes;
  final List<AtsTextNode> nodes;
  final Map<String, AtsFontInfo> fonts;

  final _cache = <int, Future<XrayPageData>>{};

  Future<XrayPageData> load(int pageIndex) =>
      _cache.putIfAbsent(pageIndex, () => _loadPage(pageIndex));

  Future<XrayPageData> _loadPage(int pageIndex) async {
    final orderedNodeIndices = [
      for (var i = 0; i < nodes.length; i++)
        if (nodes[i].pageIndex == pageIndex) i,
    ];

    // A fresh copy for *each* call — see `PdfExtractionServiceWeb`'s doc
    // comment for why `getDocument()` requires this. Both calls below
    // reach `getDocument()`, so reusing `pdfBytes` across them would
    // leave the second one holding a detached buffer.
    final raster = await Printing.raster(
      Uint8List.fromList(pdfBytes),
      pages: [pageIndex],
      dpi: dpi,
    ).first;
    final viewport = await locator<PdfExtractionService>()
        .getPageViewportTransform(
          Uint8List.fromList(pdfBytes),
          pageIndex: pageIndex,
          dpi: dpi,
        );

    final rectByNodeIndex = <int, AtsPixelRect>{
      for (final idx in orderedNodeIndices)
        idx: atsInkBoxRect(
          node: nodes[idx],
          viewport: viewport,
          ascent: fonts[nodes[idx].fontName]?.ascent,
          descent: fonts[nodes[idx].fontName]?.descent,
        ),
    };

    return XrayPageData(
      raster: raster,
      rectByNodeIndex: rectByNodeIndex,
      orderedNodeIndices: orderedNodeIndices,
    );
  }
}
