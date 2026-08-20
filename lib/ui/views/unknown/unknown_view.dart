import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'unknown_view_content.dart';
import 'unknown_viewmodel.dart';

class UnknownView extends StackedView<UnknownViewModel> {
  const UnknownView({super.key});

  @override
  Widget builder(
    BuildContext context,
    UnknownViewModel viewModel,
    Widget? child,
  ) {
    return const UnknownViewContent();
  }

  @override
  UnknownViewModel viewModelBuilder(BuildContext context) => UnknownViewModel();
}
