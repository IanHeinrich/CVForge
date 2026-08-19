import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// One selectable row in a [VaultItemSelectorList] — also reused for the
/// nested rows in [bullets], since a bullet is just a title plus a
/// selected/onToggle pair like any other entry.
class SelectorItem {
  const SelectorItem({
    required this.id,
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onToggle,
    this.bullets = const [],
  });

  final String id;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onToggle;

  /// Bullets belonging to this entry, shown indented underneath it once
  /// it's selected — picking which bullets appear in the draft only makes
  /// sense for an entry that's already in it.
  final List<SelectorItem> bullets;
}

/// A titled checkbox list for one Vault collection (experiences, projects,
/// skills, education, hobbies) plus an "N not in this draft — Add all"
/// affordance. One widget shared by every category rather than five
/// near-identical selector widgets, since the only thing that differs
/// between them is which Vault collection and toggle method feed it.
///
/// Bullet sub-lists are collapsed by default and expand per entry — local
/// `_expandedIds` is pure presentation state, not draft data, matching
/// `_SkillBulletLinkPicker`'s rationale for the same pattern in Vault.
class VaultItemSelectorList extends StatefulWidget {
  const VaultItemSelectorList({
    super.key,
    required this.title,
    required this.items,
    required this.unselectedCount,
    this.onAddAll,
  });

  final String title;
  final List<SelectorItem> items;
  final int unselectedCount;
  final VoidCallback? onAddAll;

  @override
  State<VaultItemSelectorList> createState() => _VaultItemSelectorListState();
}

class _VaultItemSelectorListState extends State<VaultItemSelectorList> {
  final _expandedIds = <String>{};

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: kdPaddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: kcWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.unselectedCount > 0 && widget.onAddAll != null)
                TextButton(
                  onPressed: widget.onAddAll,
                  child: Text('Add all (${widget.unselectedCount})'),
                ),
            ],
          ),
          verticalSpaceTiny,
          for (final item in widget.items) ...[
            CheckboxListTile(
              value: item.selected,
              onChanged: (_) => item.onToggle(),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: kcPrimaryColor,
              title: Text(item.title, style: const TextStyle(color: kcWhite)),
              subtitle: item.subtitle == null || item.subtitle!.isEmpty
                  ? null
                  : Text(
                      item.subtitle!,
                      style: const TextStyle(color: kcLightGrey, fontSize: 12),
                    ),
            ),
            if (item.selected && item.bullets.isNotEmpty)
              _BulletSublist(
                item: item,
                expanded: _expandedIds.contains(item.id),
                onToggleExpanded: () => setState(
                  () => _expandedIds.contains(item.id)
                      ? _expandedIds.remove(item.id)
                      : _expandedIds.add(item.id),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BulletSublist extends StatelessWidget {
  const _BulletSublist({
    required this.item,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final SelectorItem item;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    final selectedCount = item.bullets.where((b) => b.selected).length;
    final unselected = item.bullets.where((b) => !b.selected);

    return Padding(
      padding: const EdgeInsets.only(left: kdPaddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    expanded
                        ? RemixIcons.arrow_up_s_line
                        : RemixIcons.arrow_down_s_line,
                    size: 16,
                  ),
                  label: Text(
                    '$selectedCount/${item.bullets.length} bullets',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              if (expanded && unselected.isNotEmpty)
                TextButton(
                  onPressed: () {
                    for (final bullet in unselected) {
                      bullet.onToggle();
                    }
                  },
                  child: const Text(
                    'Select all',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          if (expanded)
            for (final bullet in item.bullets)
              CheckboxListTile(
                value: bullet.selected,
                onChanged: (_) => bullet.onToggle(),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: kcPrimaryColor,
                title: Text(
                  bullet.title,
                  style: const TextStyle(color: kcLightGrey, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        ],
      ),
    );
  }
}
