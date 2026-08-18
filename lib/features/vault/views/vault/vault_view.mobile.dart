import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/vault_card_list.dart';
import '../../widgets/vault_editor_panel_router.dart';
import '../../widgets/vault_empty_state.dart';
import 'vault_viewmodel.dart';

/// Too narrow for the card list and editor panel side by side — shows
/// one full-width surface at a time instead.
class VaultViewMobile extends ViewModelWidget<VaultViewModel> {
  const VaultViewMobile({super.key});

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    return AppChrome(
      currentSection: AppSection.vault,
      child: viewModel.showEmptyState
          ? VaultEmptyState(
              onStartFromScratch: viewModel.dismissEmptyState,
              onLoadExample: viewModel.loadExampleVault,
            )
          : viewModel.isEditorOpen
          ? VaultEditorPanelRouter(viewModel: viewModel)
          : VaultCardList(viewModel: viewModel),
    );
  }
}
