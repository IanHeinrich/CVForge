import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [VaultItemSelectorList] wiring shared by experience, projects, and
/// publications — each is "a titled list of entities with their own
/// selectable, tailorable bullets", differing only in which collection
/// feeds it, its title/empty-title copy, which field is the subtitle, and
/// which `StudioViewModel` methods back selection. Every entity-specific
/// call is a closure here rather than this widget depending on
/// `StudioViewModel` directly, so it stays reusable if Studio ever grows
/// a fifth bullet-owning collection.
///
/// Education is deliberately NOT genericized alongside these three — it
/// has no per-bullet draft selection (`CvDraft` has no
/// `educationBulletIds`; see `BulletOwner`'s doc comment) and instead
/// exposes a tailorable `details` field, so its section editor has a
/// different shape than a shared config would help with.
class EntityBulletSectionEditor<T> extends StatelessWidget {
  const EntityBulletSectionEditor({
    super.key,
    required this.title,
    required this.items,
    required this.untitledLabel,
    required this.idOf,
    required this.titleOf,
    required this.subtitleOf,
    required this.bulletsOf,
    required this.unselectedCount,
    required this.selectedCount,
    required this.onAddAll,
    required this.onRemoveAll,
    required this.isIncluded,
    required this.onToggle,
    required this.onAddAllBullets,
    required this.onRemoveAllBullets,
    required this.isBulletIncluded,
    required this.onToggleBullet,
    required this.bulletText,
    required this.hasBulletOverride,
    required this.onSetBulletOverride,
    required this.onRevertBulletOverride,
  });

  final String title;
  final List<T> items;

  /// Shown as an entity's title when [titleOf] returns an empty string —
  /// "Untitled role"/"Untitled project"/"Untitled publication".
  final String untitledLabel;
  final String Function(T item) idOf;
  final String Function(T item) titleOf;
  final String? Function(T item) subtitleOf;
  final List<CvBullet> Function(T item) bulletsOf;

  final int unselectedCount;
  final int selectedCount;
  final VoidCallback onAddAll;
  final VoidCallback onRemoveAll;

  final bool Function(T item) isIncluded;
  final ValueChanged<T> onToggle;
  final ValueChanged<T> onAddAllBullets;
  final ValueChanged<T> onRemoveAllBullets;

  final bool Function(T item, CvBullet bullet) isBulletIncluded;
  final void Function(T item, CvBullet bullet) onToggleBullet;

  final String Function(CvBullet bullet) bulletText;
  final bool Function(String bulletId) hasBulletOverride;
  final Future<void> Function(CvBullet bullet, String value)
  onSetBulletOverride;
  final Future<void> Function(String bulletId) onRevertBulletOverride;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: title,
      unselectedCount: unselectedCount,
      selectedCount: selectedCount,
      onAddAll: onAddAll,
      onRemoveAll: onRemoveAll,
      items: [
        for (final item in items)
          SelectorItem(
            id: idOf(item),
            title: titleOf(item).isEmpty ? untitledLabel : titleOf(item),
            subtitle: subtitleOf(item),
            selected: isIncluded(item),
            onToggle: () => onToggle(item),
            onAddAllBullets: () => onAddAllBullets(item),
            onRemoveAllBullets: () => onRemoveAllBullets(item),
            bullets: [
              for (final bullet in bulletsOf(item))
                SelectorItem(
                  id: bullet.id,
                  title: bulletTitle(
                    context.l10n,
                    bullet.label,
                    bulletText(bullet),
                  ),
                  selected: isBulletIncluded(item, bullet),
                  onToggle: () => onToggleBullet(item, bullet),
                  tailorable: TailorableField(
                    hasOverride: hasBulletOverride(bullet.id),
                    effectiveText: bulletText(bullet),
                    fieldLabel: bullet.label,
                    onChanged: (value) => onSetBulletOverride(bullet, value),
                    onRevert: () => onRevertBulletOverride(bullet.id),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
