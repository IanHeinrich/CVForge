import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_strings.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/storage_unavailable_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({super.key});

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Center(
        child: viewModel.hasError
            ? StorageUnavailableCard(onRetry: viewModel.retry)
            : const _StartupLoading(),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}

class _StartupLoading extends StatelessWidget {
  const _StartupLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          ksAppTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: kcWhite,
          ),
        ),
        const VGap.medium(),
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: kcPrimaryColor,
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }
}
