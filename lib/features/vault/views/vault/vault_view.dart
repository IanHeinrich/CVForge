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
    return ScreenTypeLayout.builder(
      mobile: (_) => const VaultViewMobile(),
      tablet: (_) => const VaultViewTablet(),
      desktop: (_) => const VaultViewDesktop(),
    );
  }

  @override
  VaultViewModel viewModelBuilder(BuildContext context) => VaultViewModel();
}
