import 'package:cv_forge/ui/common/tokens/app_motion.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/foundation.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'analyzer_xray_camera_controller.dart';
import 'analyzer_xray_page_loader.dart';
import 'analyzer_xray_rail.dart';
import 'ats_xray_painter.dart';

/// The X-Ray overlay: a rasterized page backdrop with severity-styled
/// evidence boxes, paired with [AnalyzerXrayRail]. Findings and the page
/// render together rather than in two cross-referenced tabs, since a
/// findings list with no way to see *where* each problem is defeats the
/// point of a visual overlay.
///
/// Desktop splits rail | page; mobile and tablet share a tabbed layout.
/// Both are builder methods on this one `State` rather than two widget
/// classes — they share camera, selection and page state deeply enough
/// that a widget boundary would be pure boilerplate. [XrayPageLoader] and
/// [XrayCameraController] are separate; this `State` owns selection,
/// page navigation, and hover/hit-testing.
class AnalyzerXrayPanel extends StatefulWidget {
  const AnalyzerXrayPanel({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  State<AnalyzerXrayPanel> createState() => _AnalyzerXrayPanelState();
}

/// What the next resolved [XrayPageData] should frame the camera on —
/// set by [_AnalyzerXrayPanelState._selectFinding]/`_step`, consumed once
/// the target page's raster/rects have loaded (camera framing needs real
/// rect data, which is only available after that async load resolves).
sealed class _FrameRequest {
  const _FrameRequest();
}

class _FrameUnion extends _FrameRequest {
  _FrameUnion(this.finding);
  final AtsFinding finding;
}

class _FrameSingle extends _FrameRequest {
  _FrameSingle(this.nodeIndex);
  final int nodeIndex;
}

/// Back to the whole-page fit, on deselecting a finding.
class _FrameFit extends _FrameRequest {
  const _FrameFit();
}

class _AnalyzerXrayPanelState extends State<AnalyzerXrayPanel>
    with SingleTickerProviderStateMixin {
  static const _railWidth = 340.0;

  late final _pageLoader = XrayPageLoader(
    pdfBytes: widget.viewModel.pdfBytes!,
    nodes: widget.viewModel.extractedNodes,
    fonts: widget.viewModel.extractedFonts,
  );
  late final _camera = XrayCameraController(
    vsync: this,
    duration: context.appMotion.camera,
  );

  int _pageIndex = 0;
  AtsFinding? _selectedFinding;
  int _stepIndex = 0;
  bool _showFlowLines = false;
  _FrameRequest? _pendingFrame;

  /// The viewport size the camera was last positioned for — a resize (or
  /// a page/selection change, which resets this to `null`) re-derives the
  /// transform; an ordinary rebuild doesn't yank the user's own pan/zoom
  /// back.
  Size? _fittedViewport;

  /// A [ValueNotifier], not a plain field behind `setState` — hover fires
  /// on every mouse-move across dense text, and rebuilding this whole
  /// panel (rail, camera, the entire `InteractiveViewer` subtree) on each
  /// one reads as constant flickering. This confines a hover update to
  /// just the peek text's own small `ValueListenableBuilder`.
  final _hoveredNodeIndex = ValueNotifier<int?>(null);

  /// Web-only grab/grabbing affordance, the same idea `printing`'s zoom
  /// preview uses (its `lib/src/preview/custom.dart`, `_zoomPreview()`/
  /// `_updateCursor()`) — the idea copied, not the dependency itself.
  ///
  /// A [ValueNotifier] for the same reason as [_hoveredNodeIndex]: a drag
  /// gesture repeatedly fires `onLongPressDown`/`onLongPressCancel` while
  /// `InteractiveViewer`'s pan recognizer and this one settle who owns
  /// the gesture, and a `setState`-driven rebuild on every one of those
  /// arena events is what read as flickering while panning.
  late final _cursor = ValueNotifier<MouseCursor>(
    kIsWeb ? SystemMouseCursors.grab : MouseCursor.defer,
  );

  @override
  void dispose() {
    _camera.dispose();
    _hoveredNodeIndex.dispose();
    _cursor.dispose();
    super.dispose();
  }

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
      // Reading order suppresses every other drawn layer while it's on
      // (see `AtsXrayPainter._paintFlowLines`) — a freshly-selected
      // finding's highlight would be invisible until the user thought to
      // turn it back off, so picking a finding exits reading-order mode.
      _showFlowLines = false;
      _pendingFrame = _FrameUnion(finding);
      _fittedViewport = null;
    });
  }

  void _toggleFlowLines() {
    setState(() {
      _showFlowLines = !_showFlowLines;
      if (_showFlowLines) {
        // Mutually exclusive with a selection, the same way selecting a
        // finding turns reading order back off in `_selectFinding` — a
        // selected finding's highlight would be invisible while reading
        // order is showing anyway (see `AtsXrayPainter._paintFlowLines`).
        _selectedFinding = null;
        _stepIndex = 0;
        // Reading order is meant to be read start to finish, which only
        // makes sense from the same zoomed-out view every time.
        _pendingFrame = const _FrameFit();
        _fittedViewport = null;
      }
    });
  }

  void _deselectFinding() {
    setState(() {
      _selectedFinding = null;
      _stepIndex = 0;
      _pendingFrame = const _FrameFit();
      _fittedViewport = null;
    });
  }

  /// The rail's own tap handler — selecting an already-selected finding
  /// again means "stop selecting", not "re-select the same thing". Box
  /// taps on the raster have their own toggle logic in [_handleTap]
  /// (cycling through multiple findings on one node first, only
  /// deselecting once there's nothing left to cycle to).
  void _toggleFinding(AtsFinding finding) {
    if (_selectedFinding == finding) {
      _deselectFinding();
    } else {
      _selectFinding(finding);
    }
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
  int? _hitTestNode(Offset position, XrayPageData data) {
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
    XrayPageData data,
    AtsAnalysisResult result,
  ) {
    final nodeIndex = _hitTestNode(position, data);
    if (nodeIndex == null) return;
    final matches = _findingsForNode(nodeIndex, result);
    if (matches.isEmpty) return;

    final current = _selectedFinding;
    if (current != null && matches.contains(current)) {
      if (matches.length == 1) {
        // The only finding on this node is already selected — clicking it
        // again means "stop selecting", not "cycle back to the same
        // thing".
        _deselectFinding();
      } else {
        // More than one finding covers this node — cycle to the next
        // rather than re-selecting the same (already highest-severity)
        // match every time.
        final next = matches[(matches.indexOf(current) + 1) % matches.length];
        _selectFinding(next);
      }
    } else {
      _selectFinding(matches.first); // result.findings is severity-sorted
    }
  }

  void _updateHover(Offset? position, XrayPageData? data) {
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

  List<AtsXrayBox> _buildBoxes(XrayPageData data, AtsAnalysisResult result) {
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

  /// [finding]'s evidence rects that fall on [_pageIndex] — a finding may
  /// have evidence spread across multiple pages, but only this page's
  /// rects are drawable/frameable right now.
  List<AtsPixelRect> _rectsOnPage(AtsFinding finding, XrayPageData data) => [
    for (final ev in finding.evidence)
      if (ev.pageIndex == _pageIndex) data.rectByNodeIndex[ev.nodeIndex],
  ].whereType<AtsPixelRect>().toList();

  AtsXraySelection? _buildSelection(XrayPageData data) {
    final finding = _selectedFinding;
    if (finding == null) return null;
    final rects = _rectsOnPage(finding, data);
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
  (int, AtsFinding?, XrayPageData)? _paintDataKey;
  ({List<AtsXrayBox> boxes, AtsXraySelection? selection})? _paintData;

  ({List<AtsXrayBox> boxes, AtsXraySelection? selection}) _paintDataFor(
    XrayPageData data,
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

  /// Selecting a finding frames the union of its evidence on the page it
  /// lands on ("what am I looking at?"); stepping through evidence frames
  /// one location tightly at a time ("show me each one") — two different
  /// questions, so two different framings rather than one compromise.
  /// Deselecting ([_FrameFit]) goes back to the whole-page fit. See
  /// [XrayCameraController.animateTo] for why this can call it directly,
  /// mid-build, without deferring to a post-frame callback.
  void _resolvePendingFrame(XrayPageData data, Size viewport) {
    final request = _pendingFrame;
    _pendingFrame = null;
    if (request == null || viewport.isEmpty) return;

    Matrix4? target;
    switch (request) {
      case _FrameUnion(:final finding):
        final rects = _rectsOnPage(finding, data);
        if (rects.isNotEmpty) {
          target = _camera.frameTransform(atsUnionRect(rects), viewport);
        }
      case _FrameSingle(:final nodeIndex):
        final rect = data.rectByNodeIndex[nodeIndex];
        if (rect != null) {
          target = _camera.frameTransform(rect, viewport, padding: 90);
        }
      case _FrameFit():
        target = _camera.fitTransform(
          viewport,
          Size(data.raster.width.toDouble(), data.raster.height.toDouble()),
        );
    }

    if (target == null) return;
    _camera.animateTo(target);
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.viewModel.result;
    if (result == null || widget.viewModel.pdfBytes == null) {
      return AppEmptyState(
        icon: RemixIcons.image_line,
        title: context.l10n.analyzerXrayEmptyTitle,
        message: context.l10n.analyzerXrayEmptyBody,
      );
    }

    return FutureBuilder<XrayPageData>(
      future: _pageLoader.load(_pageIndex),
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

  Widget _rail(AtsAnalysisResult result) => AnalyzerXrayRail(
    findings: result.findings,
    selected: _selectedFinding,
    stepIndex: _stepIndex,
    onSelect: _toggleFinding,
    onStep: _step,
  );

  Widget _buildDesktop(
    BuildContext context,
    AtsAnalysisResult result,
    XrayPageData data,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: _railWidth, child: _rail(result)),
        const VerticalDivider(width: 1),
        Expanded(child: _buildPageView(context, result, data)),
      ],
    );
  }

  Widget _buildCompact(
    BuildContext context,
    AtsAnalysisResult result,
    XrayPageData data,
  ) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: context.l10n.analyzerXrayFindings),
              Tab(text: context.l10n.analyzerXrayPageTab),
            ],
          ),
          const VGap.small(),
          Expanded(
            child: TabBarView(
              children: [_rail(result), _buildPageView(context, result, data)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(
    BuildContext context,
    AtsAnalysisResult result,
    XrayPageData data,
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
              context.l10n.analyzerXrayPageOf(_pageIndex + 1, pageCount),
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
              onPressed: _toggleFlowLines,
              icon: Icon(
                RemixIcons.route_line,
                size: context.appIconSize.medium,
                color: _showFlowLines
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              label: Text(
                context.l10n.analyzerXrayReadingOrder,
                style: context.appTypography.bodySmall.copyWith(
                  color: _showFlowLines
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
        // `_hoveredNodeIndex` in this method directly — see that field's
        // doc comment for why.
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: context.appSpacing.paddingCompact,
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: data.orderedNodeIndices.isEmpty
              ? AppEmptyState(
                  icon: RemixIcons.image_line,
                  title: context.l10n.analyzerXrayPageEmptyTitle,
                  message: context.l10n.analyzerXrayPageEmptyBody,
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
    _cursor.value = cursor;
  }

  Widget _buildInteractiveViewer(
    Size viewport,
    XrayPageData data,
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
        final target = _camera.fitTransform(viewport, content);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _camera.transformationController.value = target;
        });
      }
    }

    // The MouseRegion is the only thing that rebuilds when the cursor
    // changes — `child` is built once per real layout change (page,
    // selection, viewport resize) and reused as-is across every cursor
    // update, per `ValueListenableBuilder`'s `child` parameter contract.
    // Without this, a drag gesture's repeated onLongPressDown/
    // onLongPressCancel arena churn would rebuild the entire
    // InteractiveViewer subtree on every one of those events — the same
    // mistake `_hoveredNodeIndex` made before it, just harder to spot
    // because it only shows up while actively dragging.
    return ValueListenableBuilder<MouseCursor>(
      valueListenable: _cursor,
      builder: (context, cursor, child) =>
          MouseRegion(cursor: cursor, child: child),
      child: GestureDetector(
        // Resets both the camera *and* the selection — leaving a finding
        // selected while the camera jumps back to the whole page would
        // show its highlight sitting wherever it happens to land, with
        // nothing else on screen to explain why.
        onDoubleTap: () {
          if (_selectedFinding != null) {
            _deselectFinding();
          } else {
            _camera.animateTo(_camera.fitTransform(viewport, content));
          }
        },
        onLongPressDown: kIsWeb
            ? (_) => _updateCursor(SystemMouseCursors.grabbing)
            : null,
        onLongPressCancel: kIsWeb
            ? () => _updateCursor(SystemMouseCursors.grab)
            : null,
        child: InteractiveViewer(
          transformationController: _camera.transformationController,
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
          // the boundary logic and fights the centring in
          // `XrayCameraController.fitTransform`/`frameTransform`.
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
