import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/studio/widgets/studio_document_bar/studio_document_bar.dart';
import 'package:cv_forge/features/studio/widgets/studio_preview_pane.dart';
import 'package:cv_forge/features/studio/widgets/studio_section_editor_router/studio_section_editor_router.dart';
import 'package:cv_forge/features/studio/widgets/studio_section_nav/studio_section_nav.dart';
import 'studio_viewmodel.dart';

/// `AppChrome` is applied once, by `StudioView.builder` via
/// `AppChrome.gated`, not here — this is pure content.
class StudioViewDesktop extends ViewModelWidget<StudioViewModel> {
  const StudioViewDesktop({super.key});

  /// Fixed — the nav only ever holds eight section labels plus the
  /// Copilot card and defaults controls beneath them, none of which
  /// benefit from more width. Extra window width goes to the editor
  /// column instead (see `docs/ux/7.4-studio-restructure.md`) — this
  /// replaces the old `_panelWidthFraction`/`_minPanelWidth`/
  /// `_maxPanelWidth` scaling, whose own reasoning ("extra width is
  /// better spent on the panel than the preview") is now expressed
  /// structurally: the editor column takes the surplus, and the preview
  /// caps itself at printed width regardless of how much space it's
  /// handed (7.3). 300, not the original 220 — at 220 (and still at 260,
  /// even after shrinking the checkbox/drag-handle tap targets) the
  /// longest labels ("Professional summary", "Hobbies and interests")
  /// truncated to an ellipsis; measured empirically against the running
  /// app rather than estimated from character counts.
  static const _navWidth = 300.0;

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return Column(
      children: [
        StudioDocumentBar(viewModel: viewModel),
        Expanded(
          child: Row(
            // Row's own default is center — without stretch, a column
            // whose content is shorter than the available height (e.g.
            // the editor pane showing a single short field-override
            // card) shrink-wraps to that content and then gets centered
            // in the remaining space instead of sitting at the top,
            // which read as the whole pane being vertically centered.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _navWidth,
                child: StudioSectionNav(viewModel: viewModel),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                flex: 3,
                child: StudioSectionEditorRouter(viewModel: viewModel),
              ),
              const VerticalDivider(width: 1),
              Expanded(flex: 2, child: StudioPreviewPane(viewModel: viewModel)),
            ],
          ),
        ),
      ],
    );
  }
}
