import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:cv_forge/ui/widgets/common/storage_unavailable_card.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/drafts_card_list.dart';
import 'drafts_list_viewmodel.dart';

class DraftsListView extends StackedView<DraftsListViewModel> {
  const DraftsListView({super.key});

  @override
  Widget builder(
    BuildContext context,
    DraftsListViewModel viewModel,
    Widget? child,
  ) {
    // Same deep-link/refresh hazard as VaultView/StudioView — this View
    // loads DraftService on its own account rather than relying on
    // StartupView having already run.
    if (viewModel.isLoading) {
      return const AppChrome(
        currentSection: AppSection.drafts,
        child: Center(child: CircularProgressIndicator(color: kcPrimaryColor)),
      );
    }
    if (viewModel.hasLoadError) {
      return AppChrome(
        currentSection: AppSection.drafts,
        child: Center(
          child: StorageUnavailableCard(onRetry: viewModel.initialise),
        ),
      );
    }

    return AppChrome(
      currentSection: AppSection.drafts,
      child: DraftsCardList(viewModel: viewModel),
    );
  }

  @override
  DraftsListViewModel viewModelBuilder(BuildContext context) =>
      DraftsListViewModel();
}
