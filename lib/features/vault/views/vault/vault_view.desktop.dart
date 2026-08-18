import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/widgets/common/app_chrome/app_chrome.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../widgets/vault_card_list.dart';
import '../../widgets/vault_editor_panel_router.dart';
import '../../widgets/vault_empty_state.dart';
import 'vault_viewmodel.dart';

/// The tablet variant ([VaultViewTablet]) is identical except for the
/// card-list/editor-panel flex split, so it subclasses this and overrides
/// just [cardListFlex]/[editorPanelFlex] rather than duplicating [build].
class VaultViewDesktop extends ViewModelWidget<VaultViewModel> {
  const VaultViewDesktop({super.key});

  int get cardListFlex => 3;
  int get editorPanelFlex => 4;

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    return AppChrome(
      currentSection: AppSection.vault,
      child: viewModel.showEmptyState
          ? VaultEmptyState(
              onStartFromScratch: viewModel.dismissEmptyState,
              onLoadExample: viewModel.loadExampleVault,
            )
          : Row(
              children: [
                Expanded(
                  flex: cardListFlex,
                  child: VaultCardList(viewModel: viewModel),
                ),
                if (viewModel.isEditorOpen) ...[
                  const VerticalDivider(width: 1, color: kcMediumGrey),
                  Expanded(
                    flex: editorPanelFlex,
                    child: ColoredBox(
                      color: kcDarkGreyColor,
                      child: VaultEditorPanelRouter(viewModel: viewModel),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
