import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/studio/widgets/studio_config_panel.dart';
import 'package:cv_forge/features/studio/widgets/studio_draft_header.dart';
import 'package:cv_forge/features/studio/widgets/studio_preview_pane.dart';
import 'studio_viewmodel.dart';

/// `AppChrome` is applied once, by `StudioView.builder` via
/// `AppChrome.gated`, not here — this is pure content.
class StudioViewDesktop extends ViewModelWidget<StudioViewModel> {
  const StudioViewDesktop({super.key});

  /// The config panel scales with available width between these bounds
  /// instead of staying fixed at [_minPanelWidth]. Past a point, extra
  /// window width buys nothing for the preview — it's a fixed-aspect-
  /// ratio page, not content that benefits from stretching — so that
  /// width is better spent on the panel's checklists and tailoring
  /// editors, which always have a use for more room.
  static const _minPanelWidth = 380.0;
  static const _maxPanelWidth = 676.0; // 520 + 30%
  static const _panelWidthFraction = 0.32;

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return Column(
      children: [
        StudioDraftHeader(viewModel: viewModel),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final panelWidth = (constraints.maxWidth * _panelWidthFraction)
                  .clamp(_minPanelWidth, _maxPanelWidth);
              return Row(
                children: [
                  SizedBox(
                    width: panelWidth,
                    child: StudioConfigPanel(viewModel: viewModel),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: StudioPreviewPane(viewModel: viewModel)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
