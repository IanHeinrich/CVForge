import 'dart:async';
import 'dart:typed_data';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/models/render/resolved_cv.dart';
import 'package:cv_forge/services/pdf_export_service.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/studio_config_panel.dart';
import '../../widgets/studio_empty_preview.dart';
import 'studio_viewmodel.dart';

class StudioViewDesktop extends ViewModelWidget<StudioViewModel> {
  const StudioViewDesktop({super.key});

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return AppChrome(
      currentSection: AppSection.studio,
      child: Row(
        children: [
          SizedBox(width: 380, child: StudioConfigPanel(viewModel: viewModel)),
          const VerticalDivider(width: 1, color: kcMediumGrey),
          Expanded(child: StudioPreviewPane(viewModel: viewModel)),
        ],
      ),
    );
  }
}

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

  /// The debounce-settled value ready to render — only updated once
  /// [_debounceTimer] fires, not on every intermediate change.
  ResolvedCv? _settledCv;

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
  Future<Uint8List> _buildPdf(PdfPageFormat format) {
    final viewModel = widget.viewModel;
    _renderedCv = viewModel.resolvedCv;
    return locator<PdfExportService>().render(
      cv: viewModel.resolvedCv,
      templateId: viewModel.template.id,
      format: viewModel.pageFormat,
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    if (!viewModel.hasContent) return const StudioEmptyPreview();

    final currentCv = viewModel.resolvedCv;
    if (currentCv != _settledCv) {
      if (_settledCv == null) {
        // First content this pane has ever seen — render immediately,
        // nothing to debounce against yet.
        _settledCv = currentCv;
      } else {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(_debounce, () {
          if (mounted) setState(() => _settledCv = currentCv);
        });
      }
    }
    final shouldRepaint = _settledCv != null && _settledCv != _renderedCv;

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
          ),
        ),
        Positioned(
          right: kdPaddingPage,
          bottom: kdPaddingPage,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: kcDarkGreyColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Couldn't export the PDF — try again.",
              style: TextStyle(color: kcErrorColor, fontSize: 12),
            ),
          ),
          verticalSpaceSmall,
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
              : const Icon(Icons.download),
          label: Text(viewModel.isExporting ? 'Exporting…' : 'Export PDF'),
        ),
      ],
    );
  }
}
