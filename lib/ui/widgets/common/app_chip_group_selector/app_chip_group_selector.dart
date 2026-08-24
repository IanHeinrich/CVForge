import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

/// One selectable chip in an [AppChipGroupSelector] group.
class AppChipGroupItem {
  const AppChipGroupItem({
    required this.id,
    required this.label,
    required this.selected,
    required this.onToggle,
    this.tooltip,
  });

  final String id;
  final String label;
  final bool selected;
  final ValueChanged<bool> onToggle;

  /// Shown on hover — the Vault's bullet-link picker needs the bullet's
  /// full text under a truncated chip label; skills don't need this.
  final String? tooltip;
}

/// One heading plus [Wrap] of chips in an [AppChipGroupSelector].
class AppChipGroup {
  const AppChipGroup({
    required this.label,
    required this.items,
    this.onSelectAll,
    this.onSelectNone,
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
        Expanded(
          child: Text(
            group.label,
            style: context.appTypography.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (unselectedCount > 0 && group.onSelectAll != null)
          TextButton(
            onPressed: group.onSelectAll,
            // Same "Add all (N)" wording as every other bulk-include
            // action in Studio — this is that same action scoped to one
            // chip group, not a different one, so it should read the same
            // rather than inventing "Select all".
            child: Text(
              'Add all ($unselectedCount)',
              style: context.appTypography.caption,
            ),
          ),
        if (selectedCount > 0 && group.onSelectNone != null)
          TextButton(
            onPressed: group.onSelectNone,
            child: Text(
              'Remove all ($selectedCount)',
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
      label: Text(item.label, style: context.appTypography.caption),
      visualDensity: VisualDensity.compact,
      selected: item.selected,
      onSelected: item.onToggle,
    );
    return item.tooltip == null
        ? chip
        : Tooltip(message: item.tooltip!, child: chip);
  }
}
