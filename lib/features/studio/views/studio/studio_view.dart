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
    return ScreenTypeLayout.builder(
      mobile: (_) => const StudioViewMobile(),
      tablet: (_) => const StudioViewTablet(),
      desktop: (_) => const StudioViewDesktop(),
    );
  }

  @override
  StudioViewModel viewModelBuilder(BuildContext context) => StudioViewModel();
}
