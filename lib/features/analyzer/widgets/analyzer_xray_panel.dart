import 'dart:math' as math;

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'ats_xray_painter.dart';

/// A rasterized backdrop with one box per extracted text run on page 1,
/// drawn by a single [AtsXrayPainter] pass, zoomable/pannable via
/// [InteractiveViewer] (`docs/ats-xray-overlay-handover.md` §6, step 5).
/// Steps 2–3 built this up as one [Positioned] [Container] per node to
/// make a coordinate-math bug easy to spot while debugging; step 4 swapped
/// to a painter once that held up across a whole real page. This panel is
/// mid-evolution: the plan is to merge findings directly onto this page
/// (severity-highlighted evidence boxes) as the feature's primary view,
/// superseding the separate findings tab plus a "Show in X-Ray" jump
/// action originally proposed for evidence-linking — not yet built.
class AnalyzerXrayPanel extends StatefulWidget {
  const AnalyzerXrayPanel({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  State<AnalyzerXrayPanel> createState() => _AnalyzerXrayPanelState();
}

class _AnalyzerXrayPanelState extends State<AnalyzerXrayPanel> {
  /// Arbitrary but fixed — the raster and `getPageViewportTransform` must
  /// agree on the exact same dpi, or the two spaces are no longer the
  /// same scale (see `PdfExtractionService`'s doc comment).
  static const _dpi = 150.0;

  Future<_XrayPoc?>? _pocFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pocFuture ??= _load();
  }

  @override
  void didUpdateWidget(covariant AnalyzerXrayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.pdfBytes != widget.viewModel.pdfBytes) {
      _pocFuture = _load();
    }
  }

  Future<_XrayPoc?> _load() async {
    final bytes = widget.viewModel.pdfBytes;
    final pageNodes = widget.viewModel.extractedNodes
        .where((n) => n.pageIndex == 0)
        .toList();
    if (bytes == null || pageNodes.isEmpty) return null;

    // A fresh copy for *each* call — both `Printing.raster()` and
    // `getPageViewportTransform()` hand their bytes to `getDocument()`,
    // which detaches the underlying buffer (see `PdfExtractionServiceWeb`'s
    // doc comment). Reusing `bytes` directly across both calls would leave
    // the second one holding a detached buffer.
    final raster = await Printing.raster(
      Uint8List.fromList(bytes),
      pages: const [0],
      dpi: _dpi,
    ).first;
    final viewport = await locator<PdfExtractionService>()
        .getPageViewportTransform(
          Uint8List.fromList(bytes),
          pageIndex: 0,
          dpi: _dpi,
        );

    final fonts = widget.viewModel.extractedFonts;
    final boxes = [
      for (final node in pageNodes)
        _XrayBox(
          node: node,
          rect: atsInkBoxRect(
            node: node,
            viewport: viewport,
            ascent: fonts[node.fontName]?.ascent,
            descent: fonts[node.fontName]?.descent,
          ),
        ),
    ];

    return _XrayPoc(raster: raster, boxes: boxes);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_XrayPoc?>(
      future: _pocFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final poc = snapshot.data;
        if (poc == null) {
          return const AppEmptyState(
            icon: RemixIcons.image_line,
            title: 'Nothing to show yet',
            message: 'Page 1 has no extractable text runs to draw boxes on.',
          );
        }
        return _XrayPocView(key: ObjectKey(poc), poc: poc);
      },
    );
  }
}

class _XrayBox {
  const _XrayBox({required this.node, required this.rect});

  final AtsTextNode node;
  final AtsPixelRect rect;
}

class _XrayPoc {
  _XrayPoc({required this.raster, required this.boxes})
    : rects = boxes.map((b) => b.rect).toList();

  final PdfRaster raster;
  final List<_XrayBox> boxes;

  /// Computed once here, not per-build in [_XrayPocView] — [AtsXrayPainter.
  /// shouldRepaint] short-circuits on list identity, which only works if
  /// the same list instance survives across widget rebuilds.
  final List<AtsPixelRect> rects;
}

class _XrayPocView extends StatefulWidget {
  /// Keyed by [poc]'s identity at the call site (see [AnalyzerXrayPanel.
  /// build]) so a new PDF gets a fresh [_transformationController] rather
  /// than inheriting whatever pan/zoom was left over from the previous
  /// page — Flutter would otherwise reuse this State across rebuilds
  /// since the widget's runtimeType doesn't change.
  const _XrayPocView({super.key, required this.poc});

  final _XrayPoc poc;

  @override
  State<_XrayPocView> createState() => _XrayPocViewState();
}

class _XrayPocViewState extends State<_XrayPocView> {
  final _transformationController = TransformationController();

  /// The viewport size [_fitToViewport] last built a transform for — so a
  /// resize re-fits, but an ordinary rebuild doesn't yank the user's own
  /// pan/zoom back to the initial view.
  Size? _fittedViewport;

  /// Web-only grab/grabbing affordance, the same idea `printing`'s
  /// vendored zoom preview uses (`third_party/printing/lib/src/preview/
  /// custom.dart`'s `_zoomPreview()`/`_updateCursor()`) — copied idea, not
  /// the vendored dependency itself (it's slated for deletion). Starts as
  /// `grab` rather than `MouseCursor.defer` like the vendored version: a
  /// full-page raster is *the* thing to drag here, unlike a preview pane
  /// that's usually just being read, so signalling "draggable" up front
  /// is worth the (harmless) divergence from the precedent.
  MouseCursor _cursor = kIsWeb ? SystemMouseCursors.grab : MouseCursor.defer;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _updateCursor(MouseCursor cursor) {
    if (cursor != _cursor) setState(() => _cursor = cursor);
  }

  /// The whole page, scaled down to fit and centred — the sane opening
  /// view, and what double-tap returns to. Necessary rather than merely
  /// nice because [InteractiveViewer.constrained] is `false` here (see
  /// [build]): the identity transform would otherwise open on the page's
  /// top-left corner at full raster resolution.
  Matrix4 _fitTransform(Size viewport, Size content) {
    if (viewport.isEmpty || content.isEmpty) return Matrix4.identity();
    final scale = math.min(
      viewport.width / content.width,
      viewport.height / content.height,
    );
    // Column-major (`setEntry(row, col, _)`), so column 3 is translation
    // and this composes as `x' = scale * x + dx` — scale first, then
    // centre what's left over.
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, (viewport.width - content.width * scale) / 2)
      ..setEntry(1, 3, (viewport.height - content.height * scale) / 2);
  }

  @override
  Widget build(BuildContext context) {
    final poc = widget.poc;
    final content = Size(
      poc.raster.width.toDouble(),
      poc.raster.height.toDouble(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: context.appSpacing.gapSmall),
          child: Text(
            'PoC: ${poc.boxes.length} box(es) — page 1. Scroll/pinch to '
            'zoom, drag to pan, double-tap to reset.',
            style: context.appTypography.bodySmall,
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewport = constraints.biggest;
              if (viewport != _fittedViewport) {
                _fittedViewport = viewport;
                // Deferred: assigning to the controller notifies
                // InteractiveViewer's listener, which calls setState —
                // illegal during a build.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  _transformationController.value = _fitTransform(
                    viewport,
                    content,
                  );
                });
              }

              return MouseRegion(
                cursor: _cursor,
                child: GestureDetector(
                  onDoubleTap: () => _transformationController.value =
                      _fitTransform(viewport, content),
                  onLongPressDown: kIsWeb
                      ? (_) => _updateCursor(SystemMouseCursors.grabbing)
                      : null,
                  onLongPressCancel: kIsWeb
                      ? () => _updateCursor(SystemMouseCursors.grab)
                      : null,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    // The whole reason the boxes and the page can share one
                    // coordinate space: left at its `true` default,
                    // InteractiveViewer hands its child *tight viewport*
                    // constraints, so the SizedBox below silently collapses
                    // to the viewport — `Positioned.fill` then sizes the
                    // painter's canvas to that, while `Image` letterboxes
                    // itself to its own aspect ratio, leaving the raster,
                    // the canvas, and the box coordinates in three
                    // different spaces. `false` wraps the child in an
                    // unbounded OverflowBox instead, so the SizedBox really
                    // is raster-sized and everything agrees.
                    constrained: false,
                    // Unbounded, because with `constrained: false` the
                    // default zero margin pins a fit-scaled (smaller than
                    // viewport) page against the boundary logic and fights
                    // the centring in [_fitTransform].
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: 0.1,
                    maxScale: 8,
                    onInteractionEnd: kIsWeb
                        ? (_) => _updateCursor(SystemMouseCursors.grab)
                        : null,
                    child: SizedBox.fromSize(
                      size: content,
                      child: Stack(
                        children: [
                          Image(image: PdfRasterImage(poc.raster)),
                          Positioned.fill(
                            child: CustomPaint(
                              painter: AtsXrayPainter(poc.rects),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
