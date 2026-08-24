import 'package:cv_forge/ui/common/tokens/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/features/vault/widgets/vault_card_list.dart';
import 'package:cv_forge/features/vault/widgets/vault_editor_panel_router.dart';
import 'package:cv_forge/features/vault/widgets/vault_empty_state.dart';
import 'vault_viewmodel.dart';

/// Tablet reuses this directly with a narrower [editorPanelWidth] — same
/// layout, just a smaller fixed panel, since there's less width to go
/// around in the first place. `AppChrome` is applied once, by
/// `VaultView.builder` via `AppChrome.gated`, not here — this is pure
/// content.
class VaultViewDesktop extends ViewModelWidget<VaultViewModel> {
  const VaultViewDesktop({super.key, this.editorPanelWidth = 640});

  /// The editor panel's target width while open. Fixed rather than a flex
  /// share of the row: a form panel (one field group at a time) doesn't
  /// need to keep growing just because the monitor is wider — the old
  /// flex-based split handed it a *proportion* of the window, which meant
  /// the list lost proportionally more width on an ordinary desktop
  /// window than a genuinely narrow one, and routinely forced
  /// `VaultCardList`'s two-column grid down to one column the instant an
  /// entry was opened, on nothing wider than a normal laptop screen.
  /// Pinning the editor to a comfortable, roughly-constant width instead
  /// means the list keeps whatever's left, and only genuinely gives up its
  /// second column on a window too narrow to fit both comfortably — a
  /// width-driven outcome rather than a guaranteed side effect of opening
  /// an editor at all.
  final double editorPanelWidth;

  /// Caps a card row (icon, two short lines, a delete icon) at a
  /// comfortable width — uncapped it was a ~1,500px bar with the delete
  /// icon a screen-width away from the label it deletes. Also large enough
  /// that two columns of cards (see `VaultListSection._twoColumnMinWidth`)
  /// comfortably fit inside it once the editor panel's fixed width (rather
  /// than the old proportional split) leaves the list this much room.
  static const _cardListMaxWidth = 960.0;

  /// The cap used instead when no editor is open, so the list is the
  /// Row's only content. [_cardListMaxWidth] pinned top-left with nothing
  /// beside it left the same-width list stranded against a wall of empty
  /// black on a wide screen. Wide enough to clear `VaultCardList`'s own
  /// two-column threshold with room to spare, so the freed space becomes
  /// a second column of cards rather than a wider single one — the cap
  /// exists to stop a card row stretching, and two columns respect that
  /// while actually using the width.
  static const _cardListMaxWidthAlone = 1200.0;

  /// Opening the editor used to snap the list from centered/wide to
  /// left-aligned/narrow — and `VaultListSection`'s own two-column
  /// threshold with it — in a single frame, which read as the whole grid
  /// reorganizing itself the instant a card was clicked rather than
  /// responding to the click. Animating the list's width/alignment and
  /// the editor panel's own reveal over `context.appMotion.layout` turns
  /// that into one continuous motion instead — `VaultCardList` also reads
  /// that same duration, to delay its scroll-into-view until this
  /// transition has actually settled. Trade-off: a live browser-window
  /// resize now animates too rather than tracking the cursor exactly —
  /// accepted, since dragging a window edge is rare next to clicking a
  /// card.
  static const _transitionCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context, VaultViewModel viewModel) {
    if (viewModel.showEmptyState) {
      return VaultEmptyState(
        onStartFromScratch: viewModel.dismissEmptyState,
        onLoadExample: viewModel.loadExampleVault,
      );
    }

    final hasEditor = viewModel.isEditorOpen;
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Never more than 60% of the row, however wide [editorPanelWidth]
        // is relative to a narrow window — the list keeps at least 40%
        // for itself even at the low end of the desktop breakpoint.
        final editorWidth = hasEditor
            ? editorPanelWidth.clamp(0.0, totalWidth * 0.6)
            : 0.0;
        final listWidth = totalWidth - editorWidth;

        return Row(
          children: [
            AnimatedContainer(
              duration: context.appMotion.layout,
              curve: _transitionCurve,
              width: listWidth,
              alignment: hasEditor
                  ? AlignmentDirectional.topStart
                  : AlignmentDirectional.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: hasEditor
                      ? _cardListMaxWidth
                      : _cardListMaxWidthAlone,
                ),
                child: VaultCardList(viewModel: viewModel),
              ),
            ),
            AnimatedContainer(
              duration: context.appMotion.layout,
              curve: _transitionCurve,
              width: editorWidth,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: hasEditor
                        ? Theme.of(context).dividerColor
                        : Colors.transparent,
                  ),
                ),
              ),
              child: ClipRect(
                child: AnimatedOpacity(
                  duration: context.appMotion.layout,
                  curve: _transitionCurve,
                  opacity: hasEditor ? 1 : 0,
                  child: ColoredBox(
                    color: Theme.of(context).colorScheme.surface,
                    child: VaultEditorPanelRouter(viewModel: viewModel),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
