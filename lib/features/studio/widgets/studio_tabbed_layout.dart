import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'studio_config_panel.dart';
import 'studio_preview_pane.dart';

/// Tablet and mobile share this: too narrow for the config panel and
/// preview side by side, so they're tabs instead.
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
            labelColor: kcPrimaryColor,
            unselectedLabelColor: kcLightGrey,
            indicatorColor: kcPrimaryColor,
            tabs: [
              Tab(text: 'Configure'),
              Tab(text: 'Preview'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                StudioConfigPanel(viewModel: viewModel),
                StudioPreviewPane(viewModel: viewModel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
