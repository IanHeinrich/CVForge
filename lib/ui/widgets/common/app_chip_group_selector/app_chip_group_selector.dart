import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

/// One selectable chip in an [AppChipGroupSelector] group.
class AppChipGroupItem {
  const AppChipGroupItem({
    required this.id,
    required this.label,
    required this.selected,
    required this.onToggle,
    this.tooltip,
    this.onEdit,
  });

  final String id;
  final String label;
  final bool selected;
  final ValueChanged<bool> onToggle;

  /// Shown on hover — the Vault's bullet-link picker needs the bullet's
  /// full text under a truncated chip label; skills don't need this.
  final String? tooltip;

  /// Opens an editor for this item's [label]. Null — the default, and
  /// what both Vault call sites pass — renders no edit affordance at all.
  ///
  /// This widget stays stateless: it reports the intent and the caller
  /// decides what "being edited" looks like, rendering the editor itself
  /// through [AppChipGroup.footer].
  final VoidCallback? onEdit;
}

/// One heading plus [Wrap] of chips in an [AppChipGroupSelector].
class AppChipGroup {
  const AppChipGroup({
    required this.label,
    required this.items,
    this.onSelectAll,
    this.onSelectNone,
    this.onEditLabel,
    this.footer,
  });

  final String label;
  final List<AppChipGroupItem> items;

  /// Selects every currently-unselected item in this group. Must await
  /// each toggle sequentially if it fires more than one — see
  /// `StudioViewModel.addAllSkillsInCategory`'s doc comment for why a
  /// synchronous loop over several toggles is a real, already-documented
  /// hazard in this codebase. Null hides the affordance entirely, which
  /// the Vault's bullet picker relies on since it has no bulk action.
  final VoidCallback? onSelectAll;

  /// Inverse of [onSelectAll], same sequential-await requirement.
  final VoidCallback? onSelectNone;

  /// Opens an editor for this group's [label]. Same
  /// caller-owns-the-editing-state contract as [AppChipGroupItem.onEdit].
  final VoidCallback? onEditLabel;

  /// Rendered directly beneath this group's chips — where a caller that
  /// supplied [onEditLabel] or [AppChipGroupItem.onEdit] puts the editor
  /// once something is being edited. Keeps the editor attached to the
  /// group it belongs to without this widget owning any state.
  final Widget? footer;
}

/// A `Wrap` of compact [FilterChip]s per group, group name shown once as a
/// heading, rather than one flat checkbox list per item that discards the
/// grouping the document itself reinstates when it prints. Extracted from
/// the Vault's `_SkillBulletLinkPicker` (`skills_editor_panel.dart`) once
/// Studio's skill selector needed the same shape. Presentational and
/// stateless: it owns no state and reads nothing but [groups], so the two
/// consumers can't drift on how a chip group renders.
class AppChipGroupSelector extends StatelessWidget {
  const AppChipGroupSelector({super.key, required this.groups});

  final List<AppChipGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in groups) ...[
          _GroupHeading(group: group),
          const VGap.tiny(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final item in group.items) _Chip(item: item)],
          ),
          if (group.footer case final footer?) ...[const VGap.tiny(), footer],
          const VGap.small(),
        ],
      ],
    );
  }
}

class _GroupHeading extends StatelessWidget {
  const _GroupHeading({required this.group});

  final AppChipGroup group;

  @override
  Widget build(BuildContext context) {
    final unselectedCount = group.items.where((i) => !i.selected).length;
    final selectedCount = group.items.length - unselectedCount;
    return Row(
      children: [
        Flexible(
          child: Text(
            group.label,
            overflow: TextOverflow.ellipsis,
            style: context.appTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (group.onEditLabel case final onEdit?)
          IconButton(
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            iconSize: context.appIconSize.small,
            icon: const Icon(RemixIcons.pencil_line),
          ),
        const Spacer(),
        if (unselectedCount > 0 && group.onSelectAll != null)
          TextButton(
            onPressed: group.onSelectAll,
            // Same "Add all (N)" wording as every other bulk-include
            // action in Studio — this is that same action scoped to one
            // chip group, not a different one, so it should read the same
            // rather than inventing "Select all".
            child: Text(
              context.l10n.commonAddAll(unselectedCount),
              style: context.appTypography.caption,
            ),
          ),
        if (selectedCount > 0 && group.onSelectNone != null)
          TextButton(
            onPressed: group.onSelectNone,
            child: Text(
              context.l10n.commonRemoveAll(selectedCount),
              style: context.appTypography.caption,
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.item});

  final AppChipGroupItem item;

  @override
  Widget build(BuildContext context) {
    final chip = FilterChip(
      label: item.onEdit == null
          ? Text(item.label, style: context.appTypography.caption)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.label, style: context.appTypography.caption),
                const HGap.tiny(),
                InkWell(
                  onTap: item.onEdit,
                  child: Icon(
                    RemixIcons.pencil_line,
                    size: context.appIconSize.small,
                  ),
                ),
              ],
            ),
      visualDensity: VisualDensity.compact,
      selected: item.selected,
      onSelected: item.onToggle,
    );
    return item.tooltip == null
        ? chip
        : Tooltip(message: item.tooltip!, child: chip);
  }
}
