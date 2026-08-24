import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'studio_panel_heading.dart';
import 'tailorable_field.dart';
import 'tailoring_controls.dart';

/// A bullet's row title: its label prefixed on, or just its text if it has
/// none. Shared by every section editor that builds a bullet
/// [SelectorItem] (experience, projects, publications) rather than each
/// restating the same one-liner.
String bulletTitle(AppLocalizations l10n, String? label, String text) =>
    label == null || label.isEmpty
    ? text
    : l10n.studioItemLabelledText(label, text);

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
    this.onAddAllBullets,
    this.onRemoveAllBullets,
    this.tailorable,
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

  /// Selects every currently-unselected bullet in [bullets], sequentially
  /// — non-null only when [bullets] is non-empty. Must await each toggle
  /// before starting the next (see `StudioViewModel.addAllExperienceBullets`);
  /// firing every toggle synchronously in one loop makes them all read the
  /// same stale draft, and only the last one lands.
  final VoidCallback? onAddAllBullets;

  /// Inverse of [onAddAllBullets], same sequential-await requirement.
  /// Bullets used to offer only "Add all", while the skills chip groups
  /// offered both — the same bulk action at two levels of the same screen
  /// behaving differently, which is what this pairs up.
  final VoidCallback? onRemoveAllBullets;

  /// Non-null only for entries with a manually-rewritable prose field —
  /// a bullet's own text, or an education entry's `details`. Null for
  /// everything else (skills, hobbies, the top-level experience/project/
  /// education rows themselves) — see the `sections/` editors' call
  /// sites for which is which.
  final TailorableField? tailorable;
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
/// `_editingTextIds` is the same idea one field over, for which
/// [SelectorItem.tailorable] row currently has its inline editor open.
class VaultItemSelectorList extends StatefulWidget {
  const VaultItemSelectorList({
    super.key,
    required this.title,
    required this.items,
    required this.unselectedCount,
    required this.selectedCount,
    this.onAddAll,
    this.onRemoveAll,
  });

  final String title;
  final List<SelectorItem> items;
  final int unselectedCount;
  final int selectedCount;
  final VoidCallback? onAddAll;

  /// Inverse of [onAddAll], same sequential-await requirement — see
  /// [SelectorItem.onRemoveAllBullets] for why both directions exist.
  final VoidCallback? onRemoveAll;

  @override
  State<VaultItemSelectorList> createState() => _VaultItemSelectorListState();
}

class _VaultItemSelectorListState extends State<VaultItemSelectorList> {
  final _expandedIds = <String>{};
  final _editingTextIds = <String>{};

  void _toggleId(Set<String> ids, String id) =>
      setState(() => ids.contains(id) ? ids.remove(id) : ids.add(id));

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: StudioPanelHeading(widget.title)),
              if (widget.unselectedCount > 0 && widget.onAddAll != null)
                TextButton(
                  onPressed: widget.onAddAll,
                  child: Text(
                    context.l10n.commonAddAll(widget.unselectedCount),
                  ),
                ),
              if (widget.selectedCount > 0 && widget.onRemoveAll != null)
                TextButton(
                  onPressed: widget.onRemoveAll,
                  child: Text(
                    context.l10n.commonRemoveAll(widget.selectedCount),
                  ),
                ),
            ],
          ),
          const VGap.tiny(),
          for (final item in widget.items) ...[
            CheckboxListTile(
              key: ValueKey('item_${item.id}'),
              value: item.selected,
              onChanged: (_) => item.onToggle(),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: kcPrimaryColor,
              title: Text(
                item.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: item.subtitle == null || item.subtitle!.isEmpty
                  ? null
                  : Text(
                      item.subtitle!,
                      style: context.appTypography.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            if (item.selected && item.bullets.isNotEmpty)
              _BulletSublist(
                key: ValueKey('bullets_${item.id}'),
                item: item,
                expanded: _expandedIds.contains(item.id),
                onToggleExpanded: () => _toggleId(_expandedIds, item.id),
                editingTextIds: _editingTextIds,
                onToggleEditingText: (id) => _toggleId(_editingTextIds, id),
              ),
            // Education's `details` has no row of its own to hang off, so
            // it gets a dedicated row here. A bullet's text uses its own
            // checkbox row's title instead — see `_BulletSublist`.
            if (item.selected && item.tailorable != null)
              Padding(
                key: ValueKey('tailor_${item.id}'),
                padding: EdgeInsets.only(
                  left: context.appSpacing.paddingDefault,
                  bottom: context.appSpacing.paddingTight,
                ),
                child: _TailorableFieldRow(
                  field: item.tailorable!,
                  editing: _editingTextIds.contains(item.id),
                  onToggleEdit: () => _toggleId(_editingTextIds, item.id),
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
    super.key,
    required this.item,
    required this.expanded,
    required this.onToggleExpanded,
    required this.editingTextIds,
    required this.onToggleEditingText,
  });

  final SelectorItem item;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final Set<String> editingTextIds;
  final ValueChanged<String> onToggleEditingText;

  @override
  Widget build(BuildContext context) {
    final selectedCount = item.bullets.where((b) => b.selected).length;
    final unselectedCount = item.bullets.length - selectedCount;
    final tailoredCount = item.bullets
        .where((b) => b.tailorable?.hasOverride ?? false)
        .length;
    final countLabel = tailoredCount > 0
        ? context.l10n.studioBulletsSelectedTailored(
            selectedCount,
            item.bullets.length,
            tailoredCount,
          )
        : context.l10n.studioBulletsSelected(
            selectedCount,
            item.bullets.length,
          );

    return Padding(
      padding: EdgeInsets.only(left: context.appSpacing.paddingDefault),
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
                    size: context.appIconSize.small,
                  ),
                  label: Text(countLabel, style: context.appTypography.caption),
                ),
              ),
              if (expanded &&
                  unselectedCount > 0 &&
                  item.onAddAllBullets != null)
                TextButton(
                  onPressed: item.onAddAllBullets,
                  // Same "Add all (N)"/"Remove all (N)" wording and same
                  // pairing as every category-level list above this one
                  // and as the skills chip groups — this is the identical
                  // action one level down (bullets within one entry
                  // instead of entries within a category), so it should
                  // read the same, not "Select all".
                  child: Text(
                    context.l10n.commonAddAll(unselectedCount),
                    style: context.appTypography.caption,
                  ),
                ),
              if (expanded &&
                  selectedCount > 0 &&
                  item.onRemoveAllBullets != null)
                TextButton(
                  onPressed: item.onRemoveAllBullets,
                  child: Text(
                    context.l10n.commonRemoveAll(selectedCount),
                    style: context.appTypography.caption,
                  ),
                ),
            ],
          ),
          if (expanded)
            for (final bullet in item.bullets)
              _BulletRow(
                key: ValueKey('bullet_${bullet.id}'),
                bullet: bullet,
                editing: editingTextIds.contains(bullet.id),
                onToggleEdit: () => onToggleEditingText(bullet.id),
              ),
        ],
      ),
    );
  }
}

/// One bullet's checkbox row plus, while editing, its inline text editor
/// — held together by [TailoringHighlight] so the open editor reads as
/// attached to this bullet rather than to the sub-list.
///
/// A bullet's effective (already-overridden) text is its own row title,
/// so unlike [_TailorableFieldRow] there's no separate preview line; the
/// title just tightens to one line while editing, since the editor
/// directly below is showing the same text in full.
class _BulletRow extends StatelessWidget {
  const _BulletRow({
    super.key,
    required this.bullet,
    required this.editing,
    required this.onToggleEdit,
  });

  final SelectorItem bullet;
  final bool editing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final tailorable = bullet.tailorable;
    return TailoringHighlight(
      active: editing,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckboxListTile(
            value: bullet.selected,
            onChanged: (_) => bullet.onToggle(),
            dense: true,
            contentPadding: EdgeInsets.only(
              right: context.appSpacing.paddingTight,
            ),
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: kcPrimaryColor,
            title: Text(
              bullet.title,
              style: context.appTypography.bodySmall,
              maxLines: editing ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            secondary: tailorable == null
                ? null
                : TailorIconButtons(
                    hasOverride: tailorable.hasOverride,
                    editing: editing,
                    onToggleEdit: onToggleEdit,
                    onRevert: tailorable.onRevert,
                  ),
          ),
          if (tailorable != null && editing)
            Padding(
              padding: EdgeInsets.only(
                left: kdCheckboxTitleInset,
                right: context.appSpacing.paddingTight,
                bottom: context.appSpacing.paddingTight,
              ),
              child: InlineTextOverrideEditor(
                field: tailorable,
                onDone: onToggleEdit,
              ),
            ),
        ],
      ),
    );
  }
}

/// Education's collapsed `details` row: preview text (or an empty-state
/// prompt when there's nothing yet) plus the edit affordance, expanding to
/// [InlineTextOverrideEditor] beneath it while editing.
class _TailorableFieldRow extends StatelessWidget {
  const _TailorableFieldRow({
    required this.field,
    required this.editing,
    required this.onToggleEdit,
  });

  final TailorableField field;
  final bool editing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    final hasText = field.effectiveText.trim().isNotEmpty;
    return TailoringHighlight(
      active: editing,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.paddingTight,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasText ? field.effectiveText : (field.emptyMessage ?? ''),
                    // One line while editing: the box directly below
                    // is already showing this text in full.
                    maxLines: editing ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTypography.caption.copyWith(
                      color: hasText
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : context.appPalette.placeholder,
                      fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
                    ),
                  ),
                ),
                TailorIconButtons(
                  hasOverride: field.hasOverride,
                  editing: editing,
                  onToggleEdit: onToggleEdit,
                  onRevert: field.onRevert,
                ),
              ],
            ),
            if (editing)
              InlineTextOverrideEditor(field: field, onDone: onToggleEdit),
          ],
        ),
      ),
    );
  }
}
