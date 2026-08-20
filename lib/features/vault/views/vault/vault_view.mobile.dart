import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/vault/widgets/vault_card_list.dart';
import 'package:cv_forge/features/vault/widgets/vault_editor_panel_router.dart';
import 'package:cv_forge/features/vault/widgets/vault_empty_state.dart';
import 'vault_viewmodel.dart';

/// Too narrow for the card list and editor panel side by side — shows
/// one full-width surface at a time instead. `AppChrome` is applied once,
/// by `VaultView.builder` via `AppChrome.gated`, not here — this is pure
/// content.
class VaultViewMobile extends ViewModelWidget<VaultViewModel> {
  const VaultViewMobile({super.key});

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    return viewModel.showEmptyState
        ? VaultEmptyState(
            onStartFromScratch: viewModel.dismissEmptyState,
            onLoadExample: viewModel.loadExampleVault,
          )
        : viewModel.isEditorOpen
        ? VaultEditorPanelRouter(viewModel: viewModel)
        : VaultCardList(viewModel: viewModel);
  }
}
