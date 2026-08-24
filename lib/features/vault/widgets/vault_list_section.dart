import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/widgets/common/app_inline_empty_message/app_inline_empty_message.dart';
import 'package:cv_forge/ui/widgets/common/app_summary_card.dart';
import 'package:flutter/material.dart';

import 'vault_section_heading.dart';

/// One titled list of entity summary cards — work history, projects, or
/// education — plus an "add" affordance and an empty-state message. One
/// widget shared by every entity type rather than three near-identical
/// widgets, since the only thing that differs between them is which
/// collection, icon, and copy feed it; [idOf]/[titleOf]/[subtitleOf] are
/// how a given [T] supplies those.
class VaultListSection<T> extends StatelessWidget {
  const VaultListSection({
    super.key,
    required this.title,
    required this.addLabel,
    required this.emptyMessage,
    required this.icon,
    required this.items,
    required this.idOf,
    required this.titleOf,
    required this.subtitleOf,
    required this.openId,
    this.selectedItemKey,
    required this.onOpen,
    required this.onAdd,
    required this.onDelete,
  });

  final String title;
  final String addLabel;
  final String emptyMessage;
  final IconData icon;
  final List<T> items;
  final String Function(T item) idOf;
  final String Function(T item) titleOf;
  final String? Function(T item) subtitleOf;

  /// The id of the item currently open in the editor panel, if any —
  /// drives which card renders selected.
  final String? openId;

  /// Handed to whichever single card matches [openId], if any — see
  /// `VaultCardList._selectedCardKey`'s doc comment for why: it's what
  /// lets that card be scrolled back into view after opening it
  /// reorganizes the grid around it.
  final Key? selectedItemKey;
  final ValueChanged<String> onOpen;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  /// Below this the section's cards stack in one column; at or above it
  /// they flow into two. A summary card is an icon, two short lines and a
  /// delete button — well under half this — so past roughly this width a
  /// single column is mostly empty card, and a section with a dozen
  /// entries is a needlessly long scroll. Cards themselves stay capped:
  /// two columns is what uses the width, not one wider column.
  ///
  /// Applied identically whether the Vault's editor panel is open or not —
  /// `VaultViewDesktop`'s fixed (not proportional) `editorPanelWidth`
  /// means the list keeps most of its width regardless, so this collapses
  /// to one column only when the window is genuinely too narrow for two
  /// comfortable columns, not merely because an entry was opened.
  static const _twoColumnMinWidth = 700.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(title: title, onAdd: onAdd, addLabel: addLabel),
        if (items.isEmpty)
          AppInlineEmptyMessage(emptyMessage)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final cards = [for (final item in items) _card(context, item)];
              if (constraints.maxWidth < _twoColumnMinWidth) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: cards,
                );
              }
              return _CardColumns(
                cards: cards,
                gap: context.appSpacing.gapSmall,
              );
            },
          ),
      ],
    );
  }

  Widget _card(BuildContext context, T item) => AppSummaryCard(
    key: idOf(item) == openId ? selectedItemKey : null,
    title: titleOf(item),
    subtitle: subtitleOf(item),
    selected: idOf(item) == openId,
    onTap: () => onOpen(idOf(item)),
    onDelete: () => onDelete(idOf(item)),
    leading: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
  );
}

/// Deals [cards] alternately into two columns, so reading order runs
/// left-to-right across each row — splitting the list in half instead
/// would put the oldest job beside the newest. The two columns can end at
/// slightly different heights when an odd number of cards or a wrapped
/// subtitle makes them uneven; that's accepted, and is why these are two
/// `Column`s rather than a `GridView` forcing a shared row height onto
/// cards whose natural heights are independent.
class _CardColumns extends StatelessWidget {
  const _CardColumns({required this.cards, required this.gap});

  final List<Widget> cards;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < cards.length; i++) {
      (i.isEven ? left : right).add(cards[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // stretch, not Column's default center — without it each card
        // shrink-wraps to its own content width rather than filling its
        // column, leaving the two ragged against each other.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: left,
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: right,
          ),
        ),
      ],
    );
  }
}
