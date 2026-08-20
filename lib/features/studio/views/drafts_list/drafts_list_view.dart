import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/studio/widgets/drafts_card_list.dart';
import 'drafts_list_viewmodel.dart';

class DraftsListView extends StackedView<DraftsListViewModel> {
  const DraftsListView({super.key});

  @override
  Widget builder(
    BuildContext context,
    DraftsListViewModel viewModel,
    Widget? child,
  ) {
    return AppChrome.gated(
      section: AppSection.drafts,
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasLoadError,
      onRetry: viewModel.initialise,
      content: () => DraftsCardList(viewModel: viewModel),
    );
  }

  @override
  DraftsListViewModel viewModelBuilder(BuildContext context) =>
      DraftsListViewModel();
}
