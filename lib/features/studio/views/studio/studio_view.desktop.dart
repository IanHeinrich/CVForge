import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/studio_empty_preview.dart';
import 'studio_viewmodel.dart';

/// The tablet variant ([StudioViewTablet]) is identical, so it subclasses
/// this rather than duplicating [build].
class StudioViewDesktop extends ViewModelWidget<StudioViewModel> {
  const StudioViewDesktop({super.key});

  @override
  Widget build(BuildContext context, StudioViewModel viewModel) {
    return const AppChrome(
      currentSection: AppSection.studio,
      child: StudioEmptyPreview(),
    );
  }
}
