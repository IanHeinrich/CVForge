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
  /// AI Assistant card and defaults controls beneath them, none of which
  /// benefit from more width. Extra window width goes to the editor
  /// column instead: it takes the surplus, and the preview caps itself
  /// at printed width regardless of how much space it's handed. 300, not
  /// 220 — at 220 (and still at 260, even after shrinking the
  /// checkbox/drag-handle tap targets) the longest labels ("Professional
  /// summary", "Hobbies and interests") truncated to an ellipsis;
  /// measured empirically against the running app rather than estimated
  /// from character counts.
  static const _navWidth = 300.0;

  /// Editor:preview flex ratio at the normal desktop width — the editor
  /// column (form fields, one at a time) needs comfortable width more than
  /// the preview does, which caps itself at printed page width anyway (see
  /// this class's own doc comment) and just centers in whatever's left.
  static const _editorFlex = 3;
  static const _previewFlex = 2;

  /// Above this, there's more room than the editor column can actually
  /// use — it's still just a stack of form fields — so the surplus goes to
  /// the preview instead, letting it sit two-up (see
  /// `StudioPreviewPane`'s own width-gated two-up logic) sooner rather
  /// than staying single-page until the window is wider still. Measured
  /// as editor+preview content width (post-nav, matching
  /// `StudioView._desktopMinWidth`'s own convention), not raw window
  /// width.
  static const _widePreviewMinWidth = 1500.0;
  static const _widePreviewFlex = 3;

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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final previewFlex =
                        constraints.maxWidth >= _widePreviewMinWidth
                        ? _widePreviewFlex
                        : _previewFlex;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: _editorFlex,
                          child: StudioSectionEditorRouter(
                            viewModel: viewModel,
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          flex: previewFlex,
                          child: StudioPreviewPane(viewModel: viewModel),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
