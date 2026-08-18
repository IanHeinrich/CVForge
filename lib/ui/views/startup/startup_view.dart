import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_strings.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
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
      backgroundColor: kcBackgroundColor,
      body: Center(
        child: viewModel.hasError
            ? _StartupError(onRetry: viewModel.retry)
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
        verticalSpaceMedium,
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

/// Shown when local storage genuinely couldn't be brought online — e.g.
/// Firefox strict-privacy mode or private browsing, where IndexedDB is
/// unavailable. Explains the problem in plain English rather than hanging
/// on a spinner forever, and offers a retry rather than a dead end.
class _StartupError extends StatelessWidget {
  const _StartupError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: kcLightGrey, size: 40),
          verticalSpaceMedium,
          const Text(
            "CVForge couldn't start",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kcWhite,
            ),
          ),
          verticalSpaceSmall,
          const Text(
            'Local storage is unavailable in this browser or browsing '
            'mode. CVForge keeps everything on your device, so it needs '
            'access to it to work. Try a normal (non-private) browsing '
            'window, or a different browser.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kcLightGrey),
          ),
          verticalSpaceMedium,
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    );
  }
}
