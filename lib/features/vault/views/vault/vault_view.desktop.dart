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
  /// icon a screen-width away from the label it deletes (7.8). Used while
  /// the editor panel is open and sits directly to the list's right.
  static const _cardListMaxWidth = 720.0;

  /// The cap used instead when no editor is open, so the list is the
  /// Row's only content. [_cardListMaxWidth] pinned top-left with nothing
  /// beside it left the same-width list stranded against a wall of empty
  /// black on a wide screen. Wide enough to clear `VaultCardList`'s own
  /// two-column threshold with room to spare, so the freed space becomes
  /// a second column of cards rather than a wider single one — the cap
  /// exists to stop a card row stretching, and two columns respect that
  /// while actually using the width.
  static const _cardListMaxWidthAlone = 1200.0;

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    if (viewModel.showEmptyState) {
      return VaultEmptyState(
        onStartFromScratch: viewModel.dismissEmptyState,
        onLoadExample: viewModel.loadExampleVault,
      );
    }

    final hasEditor = viewModel.isEditorOpen;
    return Row(
      children: [
        Expanded(
          flex: cardListFlex,
          // Align relaxes the Row's tight cross-axis width before
          // ConstrainedBox caps it — see SettingsView's identical
          // pattern for why the cap alone (against a tight incoming
          // constraint) would otherwise have no effect.
          child: Align(
            alignment: hasEditor ? Alignment.topLeft : Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: hasEditor
                    ? _cardListMaxWidth
                    : _cardListMaxWidthAlone,
              ),
              child: VaultCardList(viewModel: viewModel),
            ),
          ),
        ),
        if (hasEditor) ...[
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
