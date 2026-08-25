import 'dart:async';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/services/ats_analyzer_service.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_finding_severity_style.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_xray_boxes.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_xray_page_loader.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_xray_painter.dart';
import 'package:pdf/pdf.dart';

import 'studio_preview_geometry.dart';

/// Studio's inline ATS X-Ray: the CV as a text extractor sees it, drawn
/// over the page you are editing.
///
/// **The overlay owns its own backdrop.** It does not paint onto
/// `StudioPreviewPane`'s raster — it runs its own render → extract →
/// analyze pass and draws the boxes over the raster *that* pass produced.
/// The two spaces are therefore the same by construction, with no dpi to
/// reconcile between `Printing.raster` and `getPageViewportTransform`
/// (see [XrayPageLoader.dpi]), and no way for geometry to describe a page
/// other than the one on screen. The cost is that this mode re-runs a
/// heavier pipeline than the plain preview, which is why its debounce is
/// longer.
///
/// Page layout deliberately matches the plain preview's, via
/// `studio_preview_geometry.dart` — toggling X-Ray should overlay the
/// document, not re-flow it.
///
/// This is a glance, not an inspection tool: no finding selection, no
/// camera, no rail. Those live in `AnalyzerXrayPanel`, which is the
/// surface for actually working through findings one at a time.
class StudioXrayPane extends StatefulWidget {
  const StudioXrayPane({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  State<StudioXrayPane> createState() => _StudioXrayPaneState();
}

/// One completed X-Ray pass: the findings, plus every page's raster and
/// per-node geometry. Pages are resolved eagerly rather than lazily per
/// page — the pane shows them all in one scroll, so a per-page
/// `FutureBuilder` would only stagger the same total work into a visibly
/// piecewise reveal.
class _XrayDocument {
  const _XrayDocument({required this.result, required this.pages});

  final AtsAnalysisResult result;
  final List<XrayPageData> pages;
}

class _StudioXrayPaneState extends State<StudioXrayPane> {
  /// Longer than `StudioPreviewPane`'s 250ms: that pane re-renders a PDF,
  /// where this one additionally re-extracts it through `pdf.js` and
  /// re-rasterises every page. Waiting for a longer pause before spending
  /// that keeps typing responsive, at the cost of the overlay trailing an
  /// edit by about a second — which is the right trade for a mode you
  /// consult rather than watch.
  static const _debounce = Duration(milliseconds: 900);

  Timer? _debounceTimer;

  ResolvedCv? _settledCv;
  String? _settledTemplateId;
  PdfPageFormat? _settledPageFormat;

  Future<_XrayDocument>? _pass;

  /// The last pass that actually succeeded, kept so an edit shows the
  /// previous overlay dimmed while the new one computes rather than
  /// blanking the pane for a second on every change.
  _XrayDocument? _lastDocument;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<_XrayDocument> _run(
    ResolvedCv cv,
    String templateId,
    PdfPageFormat format,
  ) async {
    final bytes = await locator<PdfExportService>().render(
      cv: cv,
      templateId: templateId,
      format: format,
    );
    final extracted = await locator<PdfExtractionService>().extract(bytes);
    final result = locator<AtsAnalyzerService>().analyze(extracted);
    final loader = XrayPageLoader(
      pdfBytes: bytes,
      nodes: extracted.nodes,
      fonts: extracted.fonts,
    );
    final pages = <XrayPageData>[
      for (var i = 0; i < extracted.info.pageCount; i++) await loader.load(i),
    ];
    return _XrayDocument(result: result, pages: pages);
  }

  /// Mirrors `StudioPreviewPane`'s compare-and-schedule — see its doc
  /// comment for why this happens in `build` rather than
  /// `didUpdateWidget`: the pane has no widget-level input to key off,
  /// since it is the reactive service under a `const`-stable ViewModel
  /// that changes.
  void _scheduleIfChanged() {
    final viewModel = widget.viewModel;
    final cv = viewModel.resolvedCv;
    final templateId = viewModel.template.id;
    final format = viewModel.pageFormat;
    if (cv == _settledCv &&
        templateId == _settledTemplateId &&
        format == _settledPageFormat) {
      return;
    }

    void settle() {
      _settledCv = cv;
      _settledTemplateId = templateId;
      _settledPageFormat = format;
      _pass = _run(cv, templateId, format);
    }

    if (_settledCv == null) {
      // First content this pane has seen — nothing to debounce against.
      settle();
      return;
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () {
      if (mounted) setState(settle);
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleIfChanged();

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: FutureBuilder<_XrayDocument>(
        future: _pass,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _buildError(context, snapshot.error!);

          final document = snapshot.data ?? _lastDocument;
          if (document == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const VGap.small(),
                  Text(
                    context.l10n.studioXrayAnalyzing,
                    style: context.appTypography.bodySmall,
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasData) _lastDocument = document;
          final settling = snapshot.connectionState == ConnectionState.waiting;

          return Column(
            children: [
              _XraySummaryBar(result: document.result, settling: settling),
              Expanded(
                child: Opacity(
                  // Dimmed, not replaced: the boxes on screen still
                  // describe the last render, so they stay readable while
                  // saying "this is not the edit you just made".
                  opacity: settling ? 0.45 : 1,
                  child: _XrayPages(
                    document: document,
                    readingOrder: widget.viewModel.xrayReadingOrder,
                    pageFormat: widget.viewModel.pageFormat,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The X-Ray adds two failure modes the plain preview has not got — the
  /// extractor failing to read what the renderer just wrote — so it
  /// explains itself rather than reusing the preview's render-failure
  /// copy. Turning the overlay off is always a way back to a working
  /// preview, and the message says so.
  Widget _buildError(BuildContext context, Object error) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        library: 'cv_forge',
        context: ErrorDescription(context.l10n.studioXrayErrorContext),
      ),
    );
    return AppEmptyState(
      icon: RemixIcons.error_warning_line,
      title: context.l10n.studioXrayErrorTitle,
      message: context.l10n.studioXrayErrorBody,
      messageMaxWidth: 420,
      actions: [
        FilledButton(
          onPressed: widget.viewModel.toggleXray,
          child: Text(context.l10n.studioXrayErrorBackToPreview),
        ),
      ],
    );
  }
}

/// Severity counts for the whole document, so the coloured boxes below
/// have something naming what they mean.
///
/// Three independent chips rather than one assembled sentence: each is a
/// complete phrase with its own plural, which is what keeps this
/// translatable — see CLAUDE.md's rule against concatenating keys.
class _XraySummaryBar extends StatelessWidget {
  const _XraySummaryBar({required this.result, required this.settling});

  final AtsAnalysisResult result;
  final bool settling;

  int _count(AtsFindingSeverity severity) =>
      result.findings.where((f) => f.severity == severity).length;

  @override
  Widget build(BuildContext context) {
    final critical = _count(AtsFindingSeverity.critical);
    final warning = _count(AtsFindingSeverity.warning);
    final info = _count(AtsFindingSeverity.info);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingDefault,
        vertical: context.appSpacing.paddingTight,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          if (settling) ...[
            SizedBox(
              width: context.appIconSize.small,
              height: context.appIconSize.small,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            const HGap.tiny(),
          ],
          Expanded(
            child: Wrap(
              spacing: context.appSpacing.gapSmall,
              runSpacing: context.appSpacing.gapSmall,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (critical == 0 && warning == 0 && info == 0)
                  Text(
                    context.l10n.studioXrayNoIssues,
                    style: context.appTypography.bodySmall,
                  ),
                if (critical > 0)
                  _SeverityChip(
                    severity: AtsFindingSeverity.critical,
                    label: context.l10n.studioXrayCriticalCount(critical),
                  ),
                if (warning > 0)
                  _SeverityChip(
                    severity: AtsFindingSeverity.warning,
                    label: context.l10n.studioXrayWarningCount(warning),
                  ),
                if (info > 0)
                  _SeverityChip(
                    severity: AtsFindingSeverity.info,
                    label: context.l10n.studioXrayInfoCount(info),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity, required this.label});

  final AtsFindingSeverity severity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = severity.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingTight,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.appRadius.large),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: context.appIconSize.small, color: color),
          const HGap.tiny(),
          Text(label, style: context.appTypography.caption),
        ],
      ),
    );
  }
}

/// The page column, laid out to the same rules as the plain preview's.
class _XrayPages extends StatelessWidget {
  const _XrayPages({
    required this.document,
    required this.readingOrder,
    required this.pageFormat,
  });

  final _XrayDocument document;
  final bool readingOrder;
  final PdfPageFormat pageFormat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pageWidth = printedPageWidth(pageFormat);
        final twoUp = previewIsTwoUp(
          available: constraints.maxWidth,
          pageWidth: pageWidth,
        );
        final pages = document.pages;

        Widget pageAt(int index) => _XrayPage(
          data: pages[index],
          result: document.result,
          pageIndex: index,
          readingOrder: readingOrder,
          width: pageWidth,
        );

        if (!twoUp) {
          return ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) => Center(child: pageAt(index)),
          );
        }
        return ListView.builder(
          itemCount: (pages.length / 2).ceil(),
          itemBuilder: (context, rowIndex) {
            final first = rowIndex * 2;
            final second = first + 1;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pageAt(first),
                if (second < pages.length) ...[
                  const SizedBox(width: previewTwoUpGutter),
                  pageAt(second),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

/// One rasterised page with its overlay painted on top.
///
/// The raster is 150dpi ([XrayPageLoader.dpi]) and the page is displayed
/// at its printed width, so the whole stack — image and painter together —
/// is scaled by one [FittedBox] rather than by converting coordinates.
/// [AtsXrayPainter] therefore keeps drawing in the raster-pixel space its
/// rects are already expressed in, exactly as it does in the Analyzer.
class _XrayPage extends StatelessWidget {
  const _XrayPage({
    required this.data,
    required this.result,
    required this.pageIndex,
    required this.readingOrder,
    required this.width,
  });

  final XrayPageData data;
  final AtsAnalysisResult result;
  final int pageIndex;
  final bool readingOrder;
  final double width;

  @override
  Widget build(BuildContext context) {
    final rasterWidth = data.raster.width.toDouble();
    final rasterHeight = data.raster.height.toDouble();
    final boxes = atsXrayBoxesFor(
      data: data,
      result: result,
      pageIndex: pageIndex,
    );

    return Container(
      width: width,
      margin: EdgeInsets.symmetric(vertical: context.appSpacing.paddingTight),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(offset: Offset(0, 3), blurRadius: 5)],
      ),
      child: AspectRatio(
        aspectRatio: rasterWidth / rasterHeight,
        child: FittedBox(
          fit: BoxFit.fill,
          child: SizedBox(
            width: rasterWidth,
            height: rasterHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(image: PdfRasterImage(data.raster), fit: BoxFit.fill),
                CustomPaint(
                  painter: AtsXrayPainter(boxes, showFlowLines: readingOrder),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
