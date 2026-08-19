import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:cv_forge/ui/widgets/common/storage_unavailable_card.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'vault_view.desktop.dart';
import 'vault_view.tablet.dart';
import 'vault_view.mobile.dart';
import 'vault_viewmodel.dart';

class VaultView extends StackedView<VaultViewModel> {
  const VaultView({super.key});

  @override
  Widget builder(
    BuildContext context,
    VaultViewModel viewModel,
    Widget? child,
  ) {
    // A refresh or deep-link straight to /vault skips StartupView, so this
    // View loads VaultService on its own account (see
    // VaultViewModel.initialise) — these two branches are what that load
    // looks like in progress or failed, before there's a real vault to
    // show.
    if (viewModel.isLoading) {
      return const AppChrome(
        currentSection: AppSection.vault,
        child: Center(child: CircularProgressIndicator(color: kcPrimaryColor)),
      );
    }
    if (viewModel.hasLoadError) {
      return AppChrome(
        currentSection: AppSection.vault,
        child: Center(
          child: StorageUnavailableCard(onRetry: viewModel.initialise),
        ),
      );
    }

    return ScreenTypeLayout.builder(
      mobile: (_) => const VaultViewMobile(),
      tablet: (_) => const VaultViewTablet(),
      desktop: (_) => const VaultViewDesktop(),
    );
  }

  @override
  VaultViewModel viewModelBuilder(BuildContext context) => VaultViewModel();
}
