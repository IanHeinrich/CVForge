import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/studio_draft_header.dart';
import '../../widgets/studio_tabbed_layout.dart';
import 'studio_viewmodel.dart';

/// Same tabbed layout as [StudioViewMobile] — too narrow here for the
/// desktop side-by-side split.
class StudioViewTablet extends ViewModelWidget<StudioViewModel> {
  const StudioViewTablet({super.key});

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return AppChrome(
      currentSection: AppSection.studio,
      child: Column(
        children: [
          StudioDraftHeader(viewModel: viewModel),
          Expanded(child: StudioTabbedLayout(viewModel: viewModel)),
        ],
      ),
    );
  }
}
