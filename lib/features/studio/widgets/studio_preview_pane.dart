import 'dart:async';
import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'studio_empty_preview.dart';

/// The live CV preview — shared by every breakpoint so desktop/tablet/
/// mobile can't drift on how the preview itself renders.
///
/// This rasterizes the *actual* exported PDF (via `printing.PdfPreview`,
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
  /// `DraftService._scheduleWrite`'s persistence debounce.
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

  /// A bound method, not an inline closure — [PdfPreview] only regenerates
  /// when this callback's *identity* changes or [shouldRepaint] is true,
  /// so a fresh closure on every rebuild causes runaway repeated
  /// regeneration (each regenerate's own `setState` would rebuild this
  /// widget, which would hand `PdfPreview` a "new" callback, which would
  /// trigger another regenerate...).
  /// [format] is always [StudioViewModel.pageFormat] — `PdfPreview` is
  /// constructed below with `canChangePageFormat: false`, so the format it
  /// hands back here can never actually differ. Read from the ViewModel
  /// instead of this parameter so the two can't silently drift if that
  /// ever changes.
  Future<Uint8List> _buildPdf(PdfPageFormat format) {
    final viewModel = widget.viewModel;
    _renderedCv = viewModel.resolvedCv;
    _renderedTemplateId = viewModel.template.id;
    _renderedPageFormat = viewModel.pageFormat;
    return locator<PdfExportService>().render(
      cv: viewModel.resolvedCv,
      templateId: viewModel.template.id,
      format: viewModel.pageFormat,
    );
  }

  /// Replaces `printing`'s default [ErrorWidget] (a raw framework error
  /// box) when rasterizing the preview fails — most likely the deployed
  /// build's font assets not resolving under `--base-href`. Export uses
  /// the same [PdfExportService.render] call this preview does, so if the
  /// export button still works despite this, that's worth telling the user
  /// rather than implying the whole feature is broken.
  Widget _buildPreviewError(BuildContext context, Object error) {
    return const AppEmptyState(
      icon: RemixIcons.error_warning_line,
      title: "Couldn't render the preview",
      message:
          'The export button below uses the same PDF generation and may '
          'still work — try it, or reload the page.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    switch (viewModel.previewState) {
      case StudioPreviewState.vaultEmpty:
        return StudioEmptyPreview(
          title: 'Nothing to preview yet',
          message: 'Add something to your Vault, then come back to build a CV.',
          actionLabel: 'Go to Vault',
          onAction: viewModel.goToVault,
        );
      case StudioPreviewState.nothingSelected:
        return StudioEmptyPreview(
          title: 'Nothing selected yet',
          message:
              'Your Vault has ${viewModel.vaultItemCount} items, but none '
              'are included in this CV.',
          // Same "Add all" wording as every other bulk-include action in
          // Studio (per-category and per-bullet) — this is that same
          // action at the widest scope, not a different one.
          actionLabel: 'Add all',
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

    return Stack(
      children: [
        ColoredBox(
          color: kcMediumGrey,
          child: PdfPreview(
            build: _buildPdf,
            shouldRepaint: shouldRepaint,
            useActions: false,
            canChangePageFormat: false,
            canChangeOrientation: false,
            onError: _buildPreviewError,
          ),
        ),
        Positioned(
          right: context.appSpacing.paddingPage,
          bottom: context.appSpacing.paddingPage,
          child: _ExportFab(viewModel: viewModel),
        ),
      ],
    );
  }
}

class _ExportFab extends StatelessWidget {
  const _ExportFab({required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (viewModel.hasExportError) ...[
          Container(
            // The per-stage messages below run noticeably longer than the
            // one generic message this replaced — capped so a long one
            // wraps instead of overflowing past the preview pane's edge.
            constraints: const BoxConstraints(maxWidth: 240),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kcDarkGreyColor,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
            ),
            child: Text(
              viewModel.exportErrorMessage,
              style: context.appTypography.caption.copyWith(
                color: kcErrorColor,
              ),
            ),
          ),
          const VGap.small(),
        ],
        FloatingActionButton.extended(
          onPressed: viewModel.isExporting ? null : viewModel.exportPdf,
          icon: viewModel.isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: kcWhite,
                  ),
                )
              : const Icon(RemixIcons.download_line),
          label: Text(viewModel.isExporting ? 'Exporting…' : 'Export PDF'),
        ),
      ],
    );
  }
}
