import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'vault_view.desktop.dart';
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
    return AppChrome.gated(
      section: AppSection.vault,
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.initialise,
      content: () => ScreenTypeLayout.builder(
        mobile: (_) => const VaultViewMobile(),
        tablet: (_) =>
            const VaultViewDesktop(cardListFlex: 2, editorPanelFlex: 3),
        desktop: (_) => const VaultViewDesktop(),
      ),
    );
  }

  @override
  VaultViewModel viewModelBuilder(BuildContext context) => VaultViewModel();
}
