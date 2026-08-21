import 'dart:math' as math;

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'analyzer_xray_rail.dart';
import 'ats_xray_painter.dart';

/// The X-Ray overlay: a rasterized page backdrop with severity-styled
/// evidence boxes, paired with [AnalyzerXrayRail] as the feature's primary
/// view — see `docs/ats-xray-overlay-handover.md`'s "Next step" section
/// for the design pivot this supersedes (findings and X-Ray were
/// originally two tabs cross-referenced by a "Show in X-Ray" jump action;
/// this merges them, since a findings list with no way to see *where*
/// each problem is defeats the point of a visual overlay).
///
/// Desktop gets a side-by-side split (rail | page); mobile/tablet share a
/// tabbed layout — the `StudioViewDesktop`/`.compact` precedent, but
/// inlined as two builder methods on one `State` rather than two widget
/// classes: the split shares camera/selection/page state and callbacks
/// deeply enough that passing all of it across a widget boundary would be
/// pure boilerplate for no reuse benefit (unlike Studio's panes, which
/// are genuinely independent).
class AnalyzerXrayPanel extends StatefulWidget {
  const AnalyzerXrayPanel({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  State<AnalyzerXrayPanel> createState() => _AnalyzerXrayPanelState();
}

/// One rasterized page plus the ink-box rect for every node on it, keyed
/// by its index into `AtsExtractedDocument.nodes` — the same index
/// `AtsFindingEvidence.nodeIndex` uses, so a finding's evidence resolves
/// straight into this map with no re-derivation.
class _XrayPageData {
  _XrayPageData({
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

/// What the next resolved [_XrayPageData] should frame the camera on —
/// set by [_AnalyzerXrayPanelState._selectFinding]/`_step`, consumed once
/// the target page's raster/rects have loaded (camera framing needs real
/// rect data, which is only available after that async load resolves).
sealed class _FrameRequest {}

class _FrameUnion extends _FrameRequest {
  _FrameUnion(this.finding);
  final AtsFinding finding;
}

class _FrameSingle extends _FrameRequest {
  _FrameSingle(this.nodeIndex);
  final int nodeIndex;
}

class _AnalyzerXrayPanelState extends State<AnalyzerXrayPanel>
    with SingleTickerProviderStateMixin {
  /// Arbitrary but fixed — the raster and `getPageViewportTransform` must
  /// agree on the exact same dpi, or the two spaces are no longer the
  /// same scale (see `PdfExtractionService`'s doc comment).
  static const _dpi = 150.0;

  static const _railWidth = 340.0;

  final _pageCache = <int, Future<_XrayPageData>>{};
  int _pageIndex = 0;
  AtsFinding? _selectedFinding;
  int _stepIndex = 0;
  bool _showFlowLines = false;
  _FrameRequest? _pendingFrame;

  /// A [ValueNotifier], not a plain field behind `setState` — hover fires
  /// on every mouse-move across dense text, and the previous `setState`
  /// rebuilt the *entire* panel (rail, camera, the whole `InteractiveViewer`
  /// subtree) on every one of those events. Fixing the peek line's height
  /// and memoizing the painter's boxes stopped the pan/zoom feedback loop
  /// that caused, but the full-panel rebuild itself was still real,
  /// visible churn on every hover — this confines a hover update to just
  /// the peek text's own small `ValueListenableBuilder` instead.
  final _hoveredNodeIndex = ValueNotifier<int?>(null);

  final _transformationController = TransformationController();

  /// The viewport size the camera was last positioned for — a resize (or
  /// a page/selection change, which resets this to `null`) re-derives the
  /// transform; an ordinary rebuild doesn't yank the user's own pan/zoom
  /// back.
  Size? _fittedViewport;

  /// One controller reused for every camera move, not recreated per move.
  /// The previous approach created a fresh `AnimationController` each
  /// call and disposed it in `whenComplete` — but `whenComplete` doesn't
  /// clear the field it disposed, so the *next* call's `?.dispose()` hit
  /// an already-disposed controller, threw inside a post-frame callback,
  /// and silently aborted before ever touching
  /// `_transformationController`. That's why only the first click ever
  /// panned: every later `_animateCameraTo` call was throwing before it
  /// could animate anything.
  late final AnimationController _cameraAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      );
  void Function()? _cameraAnimationListener;

  /// Web-only grab/grabbing affordance, the same idea `printing`'s
  /// vendored zoom preview uses (`third_party/printing/lib/src/preview/
  /// custom.dart`'s `_zoomPreview()`/`_updateCursor()`) — copied idea, not
  /// the vendored dependency itself (it's slated for deletion).
  MouseCursor _cursor = kIsWeb ? SystemMouseCursors.grab : MouseCursor.defer;

  @override
  void didUpdateWidget(covariant AnalyzerXrayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel.pdfBytes != widget.viewModel.pdfBytes) {
      _pageCache.clear();
      _pageIndex = 0;
      _selectedFinding = null;
      _stepIndex = 0;
      _hoveredNodeIndex.value = null;
      _pendingFrame = null;
      _fittedViewport = null;
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _cameraAnimationController.dispose();
    _hoveredNodeIndex.dispose();
    super.dispose();
  }

  // --- page loading ------------------------------------------------------

  Future<_XrayPageData> _pageData(int pageIndex) =>
      _pageCache.putIfAbsent(pageIndex, () => _loadPage(pageIndex));

  Future<_XrayPageData> _loadPage(int pageIndex) async {
    final bytes = widget.viewModel.pdfBytes!;
    final nodes = widget.viewModel.extractedNodes;
    final orderedNodeIndices = [
      for (var i = 0; i < nodes.length; i++)
        if (nodes[i].pageIndex == pageIndex) i,
    ];

    // A fresh copy for *each* call — both `Printing.raster()` and
    // `getPageViewportTransform()` hand their bytes to `getDocument()`,
    // which detaches the underlying buffer (see `PdfExtractionServiceWeb`'s
    // doc comment). Reusing `bytes` directly across both calls would leave
    // the second one holding a detached buffer.
    final raster = await Printing.raster(
      Uint8List.fromList(bytes),
      pages: [pageIndex],
      dpi: _dpi,
    ).first;
    final viewport = await locator<PdfExtractionService>()
        .getPageViewportTransform(
          Uint8List.fromList(bytes),
          pageIndex: pageIndex,
          dpi: _dpi,
        );

    final fonts = widget.viewModel.extractedFonts;
    final rectByNodeIndex = <int, AtsPixelRect>{
      for (final idx in orderedNodeIndices)
        idx: atsInkBoxRect(
          node: nodes[idx],
          viewport: viewport,
          ascent: fonts[nodes[idx].fontName]?.ascent,
          descent: fonts[nodes[idx].fontName]?.descent,
        ),
    };

    return _XrayPageData(
      raster: raster,
      rectByNodeIndex: rectByNodeIndex,
      orderedNodeIndices: orderedNodeIndices,
    );
  }

  // --- selection / navigation --------------------------------------------

  void _goToPage(int pageIndex) {
    if (pageIndex == _pageIndex) return;
    setState(() {
      _pageIndex = pageIndex;
      _fittedViewport = null;
    });
  }

  void _selectFinding(AtsFinding finding) {
    setState(() {
      _selectedFinding = finding;
      _stepIndex = 0;
      if (finding.evidence.isNotEmpty) {
        _pageIndex = finding.evidence.first.pageIndex;
      }
      _pendingFrame = _FrameUnion(finding);
      _fittedViewport = null;
    });
  }

  void _step(int newStepIndex) {
    final finding = _selectedFinding;
    if (finding == null || finding.evidence.isEmpty) return;
    final clamped = newStepIndex.clamp(0, finding.evidence.length - 1);
    final target = finding.evidence[clamped];
    setState(() {
      _stepIndex = clamped;
      _pageIndex = target.pageIndex;
      _pendingFrame = _FrameSingle(target.nodeIndex);
      _fittedViewport = null;
    });
  }

  /// The smallest-area matching box under [position] — resume text runs
  /// rarely overlap, but preferring the smallest match keeps a click
  /// resolving to the more specific run on the rare case they do.
  int? _hitTestNode(Offset position, _XrayPageData data) {
    int? best;
    double? bestArea;
    for (final idx in data.orderedNodeIndices) {
      final r = data.rectByNodeIndex[idx]!;
      if (position.dx < r.left ||
          position.dx > r.right ||
          position.dy < r.top ||
          position.dy > r.bottom) {
        continue;
      }
      final area = (r.right - r.left) * (r.bottom - r.top);
      if (bestArea == null || area < bestArea) {
        best = idx;
        bestArea = area;
      }
    }
    return best;
  }

  List<AtsFinding> _findingsForNode(int nodeIndex, AtsAnalysisResult result) =>
      [
        for (final finding in result.findings)
          if (finding.evidence.any(
            (e) => e.pageIndex == _pageIndex && e.nodeIndex == nodeIndex,
          ))
            finding,
      ];

  void _handleTap(
    Offset position,
    _XrayPageData data,
    AtsAnalysisResult result,
  ) {
    final nodeIndex = _hitTestNode(position, data);
    if (nodeIndex == null) return;
    final matches = _findingsForNode(nodeIndex, result);
    if (matches.isEmpty) return;

    final current = _selectedFinding;
    if (current != null && matches.contains(current)) {
      // Same box clicked again with more than one finding covering it —
      // cycle rather than re-select the same (already highest-severity)
      // match every time.
      final next = matches[(matches.indexOf(current) + 1) % matches.length];
      _selectFinding(next);
    } else {
      _selectFinding(matches.first); // result.findings is severity-sorted
    }
  }

  void _updateHover(Offset? position, _XrayPageData? data) {
    // ValueNotifier already no-ops when the new value equals the current
    // one, so this doesn't need its own equality guard.
    _hoveredNodeIndex.value = position != null && data != null
        ? _hitTestNode(position, data)
        : null;
  }

  AtsFinding? _hoveredFindingFor(int? nodeIndex, AtsAnalysisResult result) {
    if (nodeIndex == null) return null;
    final matches = _findingsForNode(nodeIndex, result);
    return matches.isEmpty ? null : matches.first;
  }

  // --- boxes / painter input ----------------------------------------------

  List<AtsXrayBox> _buildBoxes(_XrayPageData data, AtsAnalysisResult result) {
    // result.findings is already severity-sorted (critical first), so the
    // first finding claiming a node wins — "highest severity wins" falls
    // out of iteration order rather than needing its own comparison.
    final severityByNode = <int, AtsFindingSeverity>{};
    for (final finding in result.findings) {
      for (final ev in finding.evidence) {
        if (ev.pageIndex != _pageIndex) continue;
        severityByNode.putIfAbsent(ev.nodeIndex, () => finding.severity);
      }
    }

    final selected = _selectedFinding;
    final selectedNodes = selected == null
        ? const <int>{}
        : {
            for (final ev in selected.evidence)
              if (ev.pageIndex == _pageIndex) ev.nodeIndex,
          };

    final boxes = <AtsXrayBox>[];
    for (final idx in data.orderedNodeIndices) {
      final rect = data.rectByNodeIndex[idx]!;
      boxes.add((rect: rect, style: AtsXrayBoxStyle.ambient, severity: null));
      final severity = severityByNode[idx];
      if (severity != null) {
        boxes.add((
          rect: rect,
          style: selectedNodes.contains(idx)
              ? AtsXrayBoxStyle.selected
              : AtsXrayBoxStyle.evidence,
          severity: severity,
        ));
      }
    }
    return boxes;
  }

  AtsXraySelection? _buildSelection(_XrayPageData data) {
    final finding = _selectedFinding;
    if (finding == null) return null;
    final rects = [
      for (final ev in finding.evidence)
        if (ev.pageIndex == _pageIndex) data.rectByNodeIndex[ev.nodeIndex],
    ].whereType<AtsPixelRect>().toList();
    if (rects.isEmpty) return null;
    return (rects: rects, shape: finding.evidenceShape);
  }

  /// Cached so a hover-only rebuild (every mouse-move over the raster)
  /// doesn't allocate a fresh `boxes`/`selection` on every frame. Neither
  /// depends on hover — only on the page, the data it was loaded for, and
  /// which finding is selected — so recomputing them on every hover event
  /// was pure waste, and worse: a fresh `boxes` list instance every frame
  /// defeats `AtsXrayPainter.shouldRepaint`'s identity check, forcing a
  /// full repaint of every box on every mouse-move.
  (int, AtsFinding?, _XrayPageData)? _paintDataKey;
  ({List<AtsXrayBox> boxes, AtsXraySelection? selection})? _paintData;

  ({List<AtsXrayBox> boxes, AtsXraySelection? selection}) _paintDataFor(
    _XrayPageData data,
    AtsAnalysisResult result,
  ) {
    final key = (_pageIndex, _selectedFinding, data);
    final cached = _paintData;
    if (cached != null && _paintDataKey == key) return cached;
    final fresh = (
      boxes: _buildBoxes(data, result),
      selection: _buildSelection(data),
    );
    _paintDataKey = key;
    _paintData = fresh;
    return fresh;
  }

  // --- camera --------------------------------------------------------------

  /// The whole page, scaled down to fit and centred — the sane opening
  /// view, and what double-tap returns to.
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

  /// Frames [rect] centred in [viewport] with [padding] pixels of margin,
  /// clamped to the same zoom range as [InteractiveViewer.minScale]/
  /// `maxScale` below.
  Matrix4 _frameTransform(
    AtsPixelRect rect,
    Size viewport, {
    double padding = 48,
  }) {
    final width = (rect.right - rect.left) + padding * 2;
    final height = (rect.bottom - rect.top) + padding * 2;
    if (viewport.isEmpty || width <= 0 || height <= 0) {
      return _transformationController.value;
    }
    final scale = math
        .min(viewport.width / width, viewport.height / height)
        .clamp(0.1, 8.0);
    final cx = (rect.left + rect.right) / 2;
    final cy = (rect.top + rect.bottom) / 2;
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, viewport.width / 2 - cx * scale)
      ..setEntry(1, 3, viewport.height / 2 - cy * scale);
  }

  void _animateCameraTo(Matrix4 target) {
    // Interrupting an in-flight move: drop its listener before starting
    // the next one, or the stale animation keeps writing over the new
    // one's frames.
    final previousListener = _cameraAnimationListener;
    if (previousListener != null) {
      _cameraAnimationController.removeListener(previousListener);
    }
    final animation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: target,
        ).animate(
          CurvedAnimation(
            parent: _cameraAnimationController,
            curve: Curves.easeInOut,
          ),
        );
    void listener() => _transformationController.value = animation.value;
    _cameraAnimationListener = listener;
    _cameraAnimationController.addListener(listener);
    _cameraAnimationController
      ..reset()
      ..forward();
  }

  /// Selecting a finding frames the union of its evidence on the page it
  /// lands on ("what am I looking at?"); stepping through evidence frames
  /// one location tightly at a time ("show me each one") — two different
  /// questions, so two different framings rather than one compromise.
  void _resolvePendingFrame(_XrayPageData data, Size viewport) {
    final request = _pendingFrame;
    _pendingFrame = null;
    if (request == null || viewport.isEmpty) return;

    Matrix4? target;
    switch (request) {
      case _FrameUnion(:final finding):
        final rects = [
          for (final ev in finding.evidence)
            if (ev.pageIndex == _pageIndex) data.rectByNodeIndex[ev.nodeIndex],
        ].whereType<AtsPixelRect>().toList();
        if (rects.isNotEmpty) {
          target = _frameTransform(atsUnionRect(rects), viewport);
        }
      case _FrameSingle(:final nodeIndex):
        final rect = data.rectByNodeIndex[nodeIndex];
        if (rect != null) {
          target = _frameTransform(rect, viewport, padding: 90);
        }
    }

    if (target == null) return;
    final resolved = target;
    // Deferred: mutating the transformation controller during build
    // notifies InteractiveViewer's listener, which calls setState —
    // illegal during a build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animateCameraTo(resolved);
    });
  }

  // --- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final result = widget.viewModel.result;
    if (result == null || widget.viewModel.pdfBytes == null) {
      return const AppEmptyState(
        icon: RemixIcons.image_line,
        title: 'Nothing to show yet',
        message: 'Analyze a PDF to see its X-Ray.',
      );
    }

    return FutureBuilder<_XrayPageData>(
      future: _pageData(_pageIndex),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return ScreenTypeLayout.builder(
          mobile: (_) => _buildCompact(context, result, data),
          tablet: (_) => _buildCompact(context, result, data),
          desktop: (_) => _buildDesktop(context, result, data),
        );
      },
    );
  }

  Widget _buildDesktop(
    BuildContext context,
    AtsAnalysisResult result,
    _XrayPageData data,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: _railWidth,
          child: AnalyzerXrayRail(
            findings: result.findings,
            selected: _selectedFinding,
            stepIndex: _stepIndex,
            onSelect: _selectFinding,
            onStep: _step,
          ),
        ),
        const VerticalDivider(width: 1, color: kcMediumGrey),
        Expanded(child: _buildPageView(context, result, data)),
      ],
    );
  }

  Widget _buildCompact(
    BuildContext context,
    AtsAnalysisResult result,
    _XrayPageData data,
  ) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: kcPrimaryColor,
            unselectedLabelColor: kcLightGrey,
            indicatorColor: kcPrimaryColor,
            tabs: [
              Tab(text: 'Findings'),
              Tab(text: 'Page'),
            ],
          ),
          const VGap.small(),
          Expanded(
            child: TabBarView(
              children: [
                AnalyzerXrayRail(
                  findings: result.findings,
                  selected: _selectedFinding,
                  stepIndex: _stepIndex,
                  onSelect: _selectFinding,
                  onStep: _step,
                ),
                _buildPageView(context, result, data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(
    BuildContext context,
    AtsAnalysisResult result,
    _XrayPageData data,
  ) {
    final pageCount = result.info.pageCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(RemixIcons.arrow_left_s_line),
              onPressed: _pageIndex > 0
                  ? () => _goToPage(_pageIndex - 1)
                  : null,
            ),
            Text(
              'Page ${_pageIndex + 1} of $pageCount',
              style: context.appTypography.bodySmall,
            ),
            IconButton(
              icon: const Icon(RemixIcons.arrow_right_s_line),
              onPressed: _pageIndex < pageCount - 1
                  ? () => _goToPage(_pageIndex + 1)
                  : null,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => setState(() => _showFlowLines = !_showFlowLines),
              icon: Icon(
                RemixIcons.route_line,
                size: 18,
                color: _showFlowLines ? kcPrimaryColor : kcLightGrey,
              ),
              label: Text(
                'Reading order',
                style: context.appTypography.bodySmall.copyWith(
                  color: _showFlowLines ? kcPrimaryColor : kcLightGrey,
                ),
              ),
            ),
          ],
        ),
        // A fixed-height slot, always present — never conditionally
        // inserted/removed. Hover changes this text on every mouse-move
        // over the raster; if the row's presence toggled the `Expanded`
        // page area's height along with it, the `LayoutBuilder` below
        // would see a new viewport on every hover event, re-fit or
        // re-frame the camera, shift the content under the cursor, and
        // re-trigger hover on a *different* box — a feedback loop that
        // reads as constant flickering. Reserving the height unconditionally
        // means hovering never changes layout, only text content.
        //
        // Scoped to its own `ValueListenableBuilder` rather than reading
        // `_hoveredNodeIndex` in this method directly — hover fires on
        // every mouse-move across dense text, and this used to be a
        // `setState` on the whole panel (rail, camera, the entire
        // `InteractiveViewer` subtree) for every single one of those
        // events, which was real, visible churn even once the layout
        // feedback loop above was fixed.
        Padding(
          padding: EdgeInsets.only(
            left: context.appSpacing.paddingCompact,
            bottom: context.appSpacing.gapSmall,
          ),
          child: SizedBox(
            // A little taller than the bare font size — an exact-fontSize
            // box clips descenders on some platforms' default line
            // height; this only needs to be *stable*, not exact.
            height: (context.appTypography.bodySmall.fontSize ?? 13) * 1.4,
            child: ValueListenableBuilder<int?>(
              valueListenable: _hoveredNodeIndex,
              builder: (context, hoveredNodeIndex, _) {
                final peek =
                    _hoveredFindingFor(hoveredNodeIndex, result) ??
                    _selectedFinding;
                return Text(
                  peek?.title ?? '',
                  style: context.appTypography.bodySmall.copyWith(
                    color: kcLightGrey,
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: data.orderedNodeIndices.isEmpty
              ? const AppEmptyState(
                  icon: RemixIcons.image_line,
                  title: 'Nothing to show on this page',
                  message: 'No extractable text runs to draw boxes on.',
                )
              : LayoutBuilder(
                  builder: (context, constraints) => _buildInteractiveViewer(
                    constraints.biggest,
                    data,
                    result,
                  ),
                ),
        ),
      ],
    );
  }

  void _updateCursor(MouseCursor cursor) {
    if (cursor != _cursor) setState(() => _cursor = cursor);
  }

  Widget _buildInteractiveViewer(
    Size viewport,
    _XrayPageData data,
    AtsAnalysisResult result,
  ) {
    final content = Size(
      data.raster.width.toDouble(),
      data.raster.height.toDouble(),
    );
    // Computed once per relevant change (page/selection/data), not once
    // per rebuild — see `_paintDataFor`'s doc comment for why a hover-
    // only rebuild must not allocate a fresh instance here.
    final paintData = _paintDataFor(data, result);

    if (viewport != _fittedViewport) {
      _fittedViewport = viewport;
      if (_pendingFrame != null) {
        _resolvePendingFrame(data, viewport);
      } else {
        final target = _fitTransform(viewport, content);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _transformationController.value = target;
        });
      }
    }

    return MouseRegion(
      cursor: _cursor,
      child: GestureDetector(
        onDoubleTap: () => _animateCameraTo(_fitTransform(viewport, content)),
        onLongPressDown: kIsWeb
            ? (_) => _updateCursor(SystemMouseCursors.grabbing)
            : null,
        onLongPressCancel: kIsWeb
            ? () => _updateCursor(SystemMouseCursors.grab)
            : null,
        child: InteractiveViewer(
          transformationController: _transformationController,
          // The whole reason the boxes and the page can share one
          // coordinate space: left at its `true` default, InteractiveViewer
          // hands its child *tight viewport* constraints, so the SizedBox
          // below silently collapses to the viewport — `Positioned.fill`
          // then sizes the painter's canvas to that, while `Image`
          // letterboxes itself to its own aspect ratio, leaving the
          // raster, the canvas, and the box coordinates in three different
          // spaces. `false` wraps the child in an unbounded OverflowBox
          // instead, so the SizedBox really is raster-sized and everything
          // agrees.
          constrained: false,
          // Unbounded, because with `constrained: false` the default zero
          // margin pins a fit-scaled (smaller than viewport) page against
          // the boundary logic and fights the centring in [_fitTransform]/
          // [_frameTransform].
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.05,
          maxScale: 8,
          onInteractionEnd: kIsWeb
              ? (_) => _updateCursor(SystemMouseCursors.grab)
              : null,
          child: SizedBox.fromSize(
            size: content,
            // Content-space hover/tap detection: nested inside the
            // transformed subtree, so `localPosition` arrives already in
            // raster-pixel space — directly comparable to `AtsPixelRect`
            // with no matrix inversion needed. Separate from the outer
            // MouseRegion/GestureDetector above (viewport space), which
            // exists purely for the pan cursor and double-tap-to-reset
            // over the whole pannable area, including any margin outside
            // the raster.
            child: MouseRegion(
              onHover: (event) => _updateHover(event.localPosition, data),
              onExit: (_) => _updateHover(null, null),
              child: GestureDetector(
                onTapUp: (details) =>
                    _handleTap(details.localPosition, data, result),
                child: Stack(
                  children: [
                    Image(image: PdfRasterImage(data.raster)),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: AtsXrayPainter(
                          paintData.boxes,
                          showFlowLines: _showFlowLines,
                          selection: paintData.selection,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
