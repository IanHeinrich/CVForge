import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:cv_forge/ui/widgets/common/storage_unavailable_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'studio_view.desktop.dart';
import 'studio_view.tablet.dart';
import 'studio_view.mobile.dart';
import 'studio_viewmodel.dart';

class StudioView extends StackedView<StudioViewModel> {
  const StudioView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StudioViewModel viewModel,
    Widget? child,
  ) {
    // See VaultView's builder — same deep-link/refresh hazard, same fix.
    if (viewModel.isLoading) {
      return const AppChrome(
        currentSection: AppSection.studio,
        child: Center(child: CircularProgressIndicator(color: kcPrimaryColor)),
      );
    }
    if (viewModel.hasLoadError) {
      return AppChrome(
        currentSection: AppSection.studio,
        child: Center(
          child: StorageUnavailableCard(onRetry: viewModel.initialise),
        ),
      );
    }

    return ScreenTypeLayout.builder(
      mobile: (_) => const StudioViewMobile(),
      tablet: (_) => const StudioViewTablet(),
      desktop: (_) => const StudioViewDesktop(),
    );
  }

  @override
  StudioViewModel viewModelBuilder(BuildContext context) => StudioViewModel();
}
