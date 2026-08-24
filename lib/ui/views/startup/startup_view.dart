import 'package:cv_forge/ui/common/app_strings.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/brand_mark/brand_mark.dart';
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
        // Picks up where web/index.html's splash leaves off: that shows the
        // same mark on the same ground, so the handover from the loading
        // page to the first Flutter frame doesn't swap one brand for
        // another mid-load.
        BrandMark(color: Theme.of(context).colorScheme.onSurface),
        const VGap.medium(),
        Text(
          ksAppTitle,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const VGap.medium(),
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }
}
