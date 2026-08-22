import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/vault/widgets/vault_card_list.dart';
import 'package:cv_forge/features/vault/widgets/vault_editor_panel_router.dart';
import 'package:cv_forge/features/vault/widgets/vault_empty_state.dart';
import 'vault_viewmodel.dart';

/// Tablet reuses this directly with a narrower [editorPanelFlex] relative
/// to [cardListFlex] — same layout, just less width handed to the editor
/// panel, since there's less width to go around in the first place.
/// `AppChrome` is applied once, by `VaultView.builder` via
/// `AppChrome.gated`, not here — this is pure content.
class VaultViewDesktop extends ViewModelWidget<VaultViewModel> {
  const VaultViewDesktop({
    super.key,
    this.cardListFlex = 3,
    this.editorPanelFlex = 4,
  });

  final int cardListFlex;
  final int editorPanelFlex;

  /// Caps a card row (icon, two short lines, a delete icon) at a
  /// comfortable width — uncapped it was a ~1,500px bar with the delete
  /// icon a screen-width away from the label it deletes (7.8).
  static const _cardListMaxWidth = 720.0;

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    return viewModel.showEmptyState
        ? VaultEmptyState(
            onStartFromScratch: viewModel.dismissEmptyState,
            onLoadExample: viewModel.loadExampleVault,
          )
        : Row(
            children: [
              Expanded(
                flex: cardListFlex,
                // Align relaxes the Row's tight cross-axis width before
                // ConstrainedBox caps it — see SettingsView's identical
                // pattern for why the cap alone (against a tight incoming
                // constraint) would otherwise have no effect.
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: _cardListMaxWidth,
                    ),
                    child: VaultCardList(viewModel: viewModel),
                  ),
                ),
              ),
              if (viewModel.isEditorOpen) ...[
                const VerticalDivider(width: 1),
                Expanded(
                  flex: editorPanelFlex,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: VaultEditorPanelRouter(viewModel: viewModel),
                  ),
                ),
              ],
            ],
          );
  }
}
