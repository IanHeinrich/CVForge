import 'package:cv_forge/ui/common/cv_markup_flutter.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'studio_entry_field_row.dart';
import 'studio_panel_heading.dart';
import 'tailorable_field.dart';
import 'tailoring_controls.dart';

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
    this.titleField,
    this.fields = const [],
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

  /// The field whose text [title] is already showing — an experience's
  /// role, an education entry's qualification, a hobby, a bullet's own
  /// text. Edited from the row itself: the affordance goes in the tile's
  /// trailing slot and the editor opens directly beneath it.
  ///
  /// Deliberately not one more [fields] entry, because a
  /// [StudioEntryFieldRow] renders its own preview of the text — which
  /// for this field is the title verbatim, printed a second time one line
  /// below itself.
  ///
  /// A [VaultOnlyField] here is an entry whose title prints from the
  /// Vault and can't be reworded. Null is an entry with no title field at
  /// all — which is every section that has one, for now.
  final StudioEntryField? titleField;

  /// The entry's other printed fields, rendered one
  /// [StudioEntryFieldRow] each beneath it, in order. Never includes
  /// [titleField], which has a row of its own.
  ///
  /// An entity row can have several: an education entry carries its
  /// institution, location, year, grade and details. A bullet has none —
  /// its text is its [titleField], and there is nothing else to it.
  final List<StudioEntryField> fields;
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
/// [SelectorItem.fields] entry currently has its inline editor open
/// — keyed `'<itemId>_<index>'`, since one row can own several fields.
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
            _EntityRow(
              key: ValueKey('item_${item.id}'),
              item: item,
              editing: _editingTextIds.contains('${item.id}_title'),
              onToggleEdit: () =>
                  _toggleId(_editingTextIds, '${item.id}_title'),
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
            // An entity's own printed fields — an employer, an education
            // entry's grade/details — have no checkbox row of their own to
            // hang off, so they get dedicated rows here. The entry's title
            // and a bullet's text use their own checkbox row instead, since
            // that row is already showing exactly this text. Keyed per
            // field rather than per item, or opening one would open all of
            // them.
            if (item.selected)
              for (final (index, field) in item.fields.indexed)
                Padding(
                  key: ValueKey('tailor_${item.id}_$index'),
                  padding: EdgeInsets.only(
                    left: context.appSpacing.paddingDefault,
                    bottom: context.appSpacing.paddingTight,
                  ),
                  child: StudioEntryFieldRow(
                    field: field,
                    editing: _editingTextIds.contains('${item.id}_$index'),
                    onToggleEdit: () =>
                        _toggleId(_editingTextIds, '${item.id}_$index'),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

/// One entry's own checkbox row — its title, its optional subtitle, and,
/// when the entry's title is itself tailorable, the edit affordance for
/// it plus the editor that opens beneath.
///
/// A row whose [SelectorItem.titleField] is null, or that isn't in the
/// draft yet, is the bare tile and nothing else, so an entry that can't
/// be tailored here doesn't carry the chrome of one that can. A
/// [VaultOnlyField] title gets the lock and its reason, but no editor —
/// which is the whole point of that case existing.
class _EntityRow extends StatelessWidget {
  const _EntityRow({
    super.key,
    required this.item,
    required this.editing,
    required this.onToggleEdit,
  });

  final SelectorItem item;
  final bool editing;
  final VoidCallback onToggleEdit;

  @override
  Widget build(BuildContext context) {
    // Only an entry that's actually in the draft shows what can be done
    // to its title — there is nothing to tailor about a row that doesn't
    // print.
    final field = item.selected ? item.titleField : null;

    final tile = CheckboxListTile(
      value: item.selected,
      onChanged: (_) => item.onToggle(),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Theme.of(context).colorScheme.primary,
      title: cvMarkupText(
        item.title,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      ),
      subtitle: item.subtitle == null || item.subtitle!.isEmpty
          ? null
          : cvMarkupText(
              item.subtitle!,
              style: context.appTypography.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
      secondary: switch (field) {
        null => null,
        TailorableField(:final hasOverride, :final onRevert) =>
          TailorIconButtons(
            hasOverride: hasOverride,
            editing: editing,
            onToggleEdit: onToggleEdit,
            onRevert: onRevert,
          ),
        VaultOnlyField(:final reason) => VaultLockIcon(reason: reason),
      },
    );

    // A locked title has a lock and nothing else to open, so it stays a
    // bare tile rather than a tinted block that never tints.
    if (field is! TailorableField) return tile;

    return TailoringHighlight(
      active: editing,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tile,
          if (editing)
            Padding(
              padding: EdgeInsets.only(
                left: kdCheckboxTitleInset,
                right: context.appSpacing.paddingTight,
                bottom: context.appSpacing.paddingTight,
              ),
              child: InlineTextOverrideEditor(
                field: field,
                onDone: onToggleEdit,
              ),
            ),
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
        .where((b) => b.titleField?.hasOverride ?? false)
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
/// so unlike [StudioEntryFieldRow] there's no separate preview line; the
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
    final tailorable = switch (bullet.titleField) {
      final TailorableField f => f,
      _ => null,
    };
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
            activeColor: Theme.of(context).colorScheme.primary,
            title: cvMarkupText(
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
