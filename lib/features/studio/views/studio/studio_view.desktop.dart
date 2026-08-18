import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/cv_page_surface/cv_page_surface.dart';
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

/// The scrollable, scaled CV preview — shared by every breakpoint so
/// desktop/tablet/mobile can't drift on how the preview itself renders.
class StudioPreviewPane extends StatelessWidget {
  const StudioPreviewPane({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (!viewModel.hasContent) return const StudioEmptyPreview();

    return ColoredBox(
      color: kcMediumGrey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(kdPaddingPage),
        child: CvPageSurface(
          format: viewModel.pageFormat,
          child: viewModel.template.buildPreview(
            viewModel.resolvedCv,
            viewModel.pageFormat,
          ),
        ),
      ),
    );
  }
}
