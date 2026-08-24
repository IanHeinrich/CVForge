import 'dart:async';
import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'studio_empty_preview.dart';

/// A CV is a printed artefact, so the preview should never render the page
/// larger than its printed size — scaling past 100% shows a zoomed
/// fragment and answers none of the questions ("does it fit on two
/// pages", "how does the whole page look") the preview exists for. 96 is
/// the CSS reference pixel per inch, not the display's real DPI, which the
/// web cannot know.
double _printedWidth(PdfPageFormat format) =>
    format.width / PdfPageFormat.inch * 96;

/// Horizontal gap between the two pages of a [_PreviewPages] two-up row.
const _twoUpGutter = 24.0;

/// The live CV preview — shared by every breakpoint so desktop/tablet/
/// mobile can't drift on how the preview itself renders.
///
/// This rasterizes the *actual* exported PDF (via `printing.PdfPreviewCustom`,
/// fed the same [PdfExportService.render] bytes the export button
/// downloads) rather than maintaining a second, hand-built Flutter render
/// tree alongside the `pw.Widget` one. Preview and export can't drift on
/// pixels because they're the same bytes — see `CvTemplate`'s doc comment.
class StudioPreviewPane extends StatefulWidget {
  const StudioPreviewPane({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  State<StudioPreviewPane> createState() => _StudioPreviewPaneState();
}

class _StudioPreviewPaneState extends State<StudioPreviewPane> {
  /// Real PDF generation is fast (tens of ms, measured against real CV
  /// data), but debouncing still matters once fields become editable by
  /// typing directly (a planned addition) — regenerating and re-rasterizing
  /// on every keystroke would be wasteful. Same duration class as
  /// `PersistedStoreMixin.scheduleWrite`'s persistence debounce.
  static const _debounce = Duration(milliseconds: 250);

  /// The CV content [PdfPreview] was last actually told to render.
  ResolvedCv? _renderedCv;

  /// The template id [PdfPreview] was last actually told to render with —
  /// tracked alongside [_renderedCv] because switching templates alone can
  /// leave [ResolvedCv] byte-identical (content and section order both live
  /// on the draft, not the template) while still needing a repaint, since
  /// the template governs the PDF's visual design, not just its content.
  String? _renderedTemplateId;

  /// The page format [PdfPreview] was last actually told to render with —
  /// same rationale as [_renderedTemplateId]: switching region changes
  /// [StudioViewModel.pageFormat] (A4 vs Letter) without touching
  /// [ResolvedCv] at all, since region only affects page size and (not yet
  /// implemented) date formatting, neither of which [ResolvedCv] encodes.
  /// [PdfPageFormat.a4]/[PdfPageFormat.letter] are the same canonical
  /// `const` instance every time, so reference equality here is exact, not
  /// approximate.
  PdfPageFormat? _renderedPageFormat;

  /// The debounce-settled value ready to render — only updated once
  /// [_debounceTimer] fires, not on every intermediate change.
  ResolvedCv? _settledCv;
  String? _settledTemplateId;
  PdfPageFormat? _settledPageFormat;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// A bound method, not an inline closure — [PdfPreviewCustom] only
  /// regenerates when this callback's *identity* changes or [shouldRepaint]
  /// is true, so a fresh closure on every rebuild causes runaway repeated
  /// regeneration (each regenerate's own `setState` would rebuild this
  /// widget, which would hand `PdfPreviewCustom` a "new" callback, which
  /// would trigger another regenerate...).
  /// [format] is always [StudioViewModel.pageFormat] — there is no page
  /// format switcher UI anywhere in this pane, so the format handed back
  /// here can never actually differ. Read from the ViewModel instead of
  /// this parameter so the two can't silently drift if that ever changes.
  Future<Uint8List> _buildPdf(PdfPageFormat format) {
    final viewModel = widget.viewModel;
    final cv = viewModel.resolvedCv;
    final templateId = viewModel.template.id;
    final pageFormat = viewModel.pageFormat;
    _renderedCv = cv;
    _renderedTemplateId = templateId;
    _renderedPageFormat = pageFormat;
    return locator<PdfExportService>().render(
      cv: cv,
      templateId: templateId,
      format: pageFormat,
    );
  }

  /// Replaces `printing`'s default [ErrorWidget] (a raw framework error
  /// box) when rasterizing the preview fails — most likely the deployed
  /// build's font assets not resolving under `--base-href`. Export uses
  /// the same [PdfExportService.render] call this preview does, so if the
  /// export button still works despite this, that's worth telling the user
  /// rather than implying the whole feature is broken.
  Widget _buildPreviewError(BuildContext context, Object error) {
    // Reported rather than swallowed: the copy below tells the user what to
    // try, but without this the underlying failure reaches nothing that
    // could explain *why* the raster failed.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        library: 'cv_forge',
        context: ErrorDescription(context.l10n.studioPreviewErrorContext),
      ),
    );
    return AppEmptyState(
      icon: RemixIcons.error_warning_line,
      title: "Couldn't render the preview",
      message: context.l10n.studioPreviewErrorBody,
    );
  }

  /// Runs from inside [PdfPreviewCustom]'s `pagesBuilder`, which fires
  /// during build — calling [StudioViewModel.setPageCount] straight from
  /// here would notify listeners mid-build. Guarding on the count actually
  /// changing before scheduling the post-frame callback keeps this from
  /// scheduling one on every rebuild that doesn't change anything.
  void _reportPageCount(int count) {
    final viewModel = widget.viewModel;
    if (viewModel.pageCount == count) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) viewModel.setPageCount(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    switch (viewModel.previewState) {
      case StudioPreviewState.vaultEmpty:
        return StudioEmptyPreview(
          title: context.l10n.studioPreviewEmptyTitle,
          message: context.l10n.studioPreviewEmptyBody,
          actionLabel: context.l10n.studioPreviewGoToVault,
          onAction: viewModel.goToVault,
        );
      case StudioPreviewState.nothingSelected:
        return StudioEmptyPreview(
          title: context.l10n.studioPreviewNothingSelectedTitle,
          message: context.l10n.studioPreviewNothingSelectedBody(
            viewModel.vaultItemCount,
          ),
          // Same "Add all" wording as every other bulk-include action in
          // Studio (per-category and per-bullet) — this is that same
          // action at the widest scope, not a different one.
          actionLabel: context.l10n.studioPreviewAddAll,
          onAction: viewModel.includeEverything,
        );
      case StudioPreviewState.ready:
        break;
    }

    // Writes _settledCv/_debounceTimer here rather than in
    // didUpdateWidget: this pane has no widget-level input to key off of
    // (viewModel is `const`-stable across rebuilds; it's the reactive
    // service underneath it that changes), so didUpdateWidget would never
    // fire on the selection/tailoring edits this debounce exists for.
    // Reading resolvedCv fresh on every build and comparing against the
    // last-settled value is what makes this correct here — it just means
    // build is doing comparison-and-schedule work a purer build wouldn't.
    final currentCv = viewModel.resolvedCv;
    final currentTemplateId = viewModel.template.id;
    final currentPageFormat = viewModel.pageFormat;
    if (currentCv != _settledCv ||
        currentTemplateId != _settledTemplateId ||
        currentPageFormat != _settledPageFormat) {
      if (_settledCv == null) {
        // First content this pane has ever seen — render immediately,
        // nothing to debounce against yet.
        _settledCv = currentCv;
        _settledTemplateId = currentTemplateId;
        _settledPageFormat = currentPageFormat;
      } else {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(_debounce, () {
          if (mounted) {
            setState(() {
              _settledCv = currentCv;
              _settledTemplateId = currentTemplateId;
              _settledPageFormat = currentPageFormat;
            });
          }
        });
      }
    }
    final shouldRepaint =
        _settledCv != null &&
        (_settledCv != _renderedCv ||
            _settledTemplateId != _renderedTemplateId ||
            _settledPageFormat != _renderedPageFormat);

    // Two-up is a consequence of available width, not a user toggle — the
    // same width-gated shape as the existing desktop/compact breakpoint
    // split. `maxPageWidth` is widened to match whenever two-up applies:
    // `PdfPreviewCustom` wraps its entire content (including a custom
    // `pagesBuilder`'s output) in a `BoxConstraints(maxWidth:
    // maxPageWidth)`, so a single-page-wide cap here would clip a two-up
    // row down to one page — confirmed against `printing`'s actual
    // source, not assumed.
    return LayoutBuilder(
      builder: (context, constraints) {
        final printedWidth = _printedWidth(viewModel.pageFormat);
        final twoUp = constraints.maxWidth >= printedWidth * 2 + _twoUpGutter;
        final maxPageWidth = twoUp
            ? printedWidth * 2 + _twoUpGutter
            : printedWidth;

        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: PdfPreviewCustom(
            build: _buildPdf,
            shouldRepaint: shouldRepaint,
            maxPageWidth: maxPageWidth,
            onError: _buildPreviewError,
            pagesBuilder: (context, pages) {
              _reportPageCount(pages.length);
              return _PreviewPages(
                pages: pages,
                twoUp: twoUp,
                pageWidth: printedWidth,
              );
            },
          ),
        );
      },
    );
  }
}

/// Lays out [PdfPreviewCustom]'s rasterised pages — one scrolling column
/// normally, or two side by side once [StudioPreviewPane]'s `LayoutBuilder`
/// decides there's room. [pageWidth] is each page's true printed width
/// ([_printedWidth]); in the two-up branch each page is boxed to exactly
/// that width rather than left to fill half the row, so a two-up page
/// reads at the same size as a single one, not stretched.
class _PreviewPages extends StatelessWidget {
  const _PreviewPages({
    required this.pages,
    required this.twoUp,
    required this.pageWidth,
  });

  final List<PdfPreviewPageData> pages;
  final bool twoUp;
  final double pageWidth;

  @override
  Widget build(BuildContext context) {
    if (!twoUp) {
      return ListView.builder(
        itemCount: pages.length,
        itemBuilder: (context, index) =>
            _PreviewPageImage(pageData: pages[index]),
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
            SizedBox(
              width: pageWidth,
              child: _PreviewPageImage(pageData: pages[first]),
            ),
            if (second < pages.length) ...[
              const SizedBox(width: _twoUpGutter),
              SizedBox(
                width: pageWidth,
                child: _PreviewPageImage(pageData: pages[second]),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// One rasterised page as a white sheet with a drop shadow — the same
/// visual `printing`'s own (non-exported) `PdfPreviewPage` renders, rebuilt
/// here because that widget isn't part of `package:printing`'s public API
/// (only `PdfPreviewPageData` is, via `export 'page.dart' show
/// PdfPreviewPageData`), and reaching into `src/` to import it directly
/// would tie this file to the vendored package's internal layout instead
/// of its actual contract.
class _PreviewPageImage extends StatelessWidget {
  const _PreviewPageImage({required this.pageData});

  final PdfPreviewPageData pageData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: context.appSpacing.paddingTight),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(offset: Offset(0, 3), blurRadius: 5)],
      ),
      child: AspectRatio(
        aspectRatio: pageData.aspectRatio,
        child: Image(image: pageData.image, fit: BoxFit.cover),
      ),
    );
  }
}
