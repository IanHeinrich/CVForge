import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'studio_preview_pane.dart';
import 'studio_section_editor_router/studio_section_editor_router.dart';
import 'studio_section_nav/studio_section_nav.dart';

/// Tablet and mobile share this: too narrow for the nav/editor/preview
/// three-column desktop layout, so it's two tabs instead. "Configure" is
/// itself a drill-down — the section nav until something's selected, then
/// that section's editor with a way back — rather than a third tab, which
/// would put the preview two taps from whatever's changing it.
class StudioTabbedLayout extends StatelessWidget {
  const StudioTabbedLayout({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Configure'),
              Tab(text: 'Preview'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ConfigureDrillDown(viewModel: viewModel),
                StudioPreviewPane(viewModel: viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigureDrillDown extends StatelessWidget {
  const _ConfigureDrillDown({required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final openSection = viewModel.openSection;
    if (openSection == null) return StudioSectionNav(viewModel: viewModel);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Back to sections',
              icon: const Icon(RemixIcons.arrow_left_line, color: kcLightGrey),
              onPressed: () => viewModel.selectSection(null),
            ),
            Text(
              openSection.displayLabel,
              style: context.appTypography.titleSmall,
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(child: StudioSectionEditorRouter(viewModel: viewModel)),
      ],
    );
  }
}
