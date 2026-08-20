import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/analyzer/widgets/analyzer_results_panel.dart';
import 'package:cv_forge/features/analyzer/widgets/analyzer_upload_prompt.dart';
import 'analyzer_viewmodel.dart';

/// A single layout for every breakpoint — an upload prompt or a scrollable
/// findings list, neither of which needs a side-by-side split the way
/// Vault/Studio do — so unlike those, there's no `.desktop`/`.mobile`
/// variant pair here (see `CLAUDE.md`'s rule against responsive variants
/// that would differ only in constants nothing here actually varies by).
class AnalyzerView extends StackedView<AnalyzerViewModel> {
  const AnalyzerView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AnalyzerViewModel viewModel,
    Widget? child,
  ) {
    return AppChrome.gated(
      section: AppSection.analyzer,
      // No init load exists for this ViewModel to gate on — see its class
      // doc comment — so these are trivially satisfied rather than wired
      // to real state.
      isLoading: false,
      hasError: false,
      onRetry: () {},
      content: () => viewModel.hasResult
          ? AnalyzerResultsPanel(viewModel: viewModel)
          : AnalyzerUploadPrompt(viewModel: viewModel),
    );
  }

  @override
  AnalyzerViewModel viewModelBuilder(BuildContext context) =>
      AnalyzerViewModel();
}
