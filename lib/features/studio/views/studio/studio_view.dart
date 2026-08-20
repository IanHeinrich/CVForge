import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'studio_view.compact.dart';
import 'studio_view.desktop.dart';
import 'studio_viewmodel.dart';

class StudioView extends StackedView<StudioViewModel> {
  const StudioView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StudioViewModel viewModel,
    Widget? child,
  ) {
    return AppChrome.gated(
      section: AppSection.studio,
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.initialise,
      content: () => ScreenTypeLayout.builder(
        mobile: (_) => const StudioViewCompact(),
        tablet: (_) => const StudioViewCompact(),
        desktop: (_) => const StudioViewDesktop(),
      ),
    );
  }

  @override
  StudioViewModel viewModelBuilder(BuildContext context) => StudioViewModel();
}
