import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [VaultItemSelectorList] wiring shared by every bullet-owning
/// section — experience, projects, education and publications. Each is "a
/// titled list of entities with their own selectable, tailorable
/// bullets", differing only in which collection feeds it, its
/// title/empty-title copy, which field is the subtitle, and which
/// `StudioViewModel` methods back selection. Every entity-specific call
/// is a closure here rather than this widget depending on
/// `StudioViewModel` directly, so it stays reusable if Studio ever grows
/// a fifth bullet-owning collection.
///
/// Education used to be excluded, because it had no per-bullet draft
/// selection and did have tailorable `grade`/`details` fields of its own.
/// `CvDraft.educationBulletIds` closed the first half and [fieldsOf] the
/// second, so what was two shapes is one.
///
/// [titleFieldOf] and [fieldsOf] are how a caller says what each of its
/// entries' printed fields *are* — editable here, or printed from the
/// Vault and fixed, with the reason. One ordered list rather than a
/// parameter block per field, so adding a field to a section is adding a
/// list entry at the call site and nothing here.
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
    this.titleFieldOf,
    this.fieldsOf,
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

  /// The entity's own printed title (a role, a project name), as the
  /// field the entry's own row edits — see [SelectorItem.titleField].
  /// A [VaultOnlyField] for a title that prints from the Vault and stays
  /// there; null for a section with no title field at all.
  final StudioEntryField Function(T item)? titleFieldOf;

  /// The entity's other printed fields, in the order they should appear
  /// beneath it. Same union: an editable field, or one that prints from
  /// the Vault with the reason it's fixed.
  final List<StudioEntryField> Function(T item)? fieldsOf;

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
            titleField: titleFieldOf?.call(item),
            // A field with nothing in it has nothing to say, editable or
            // not, so an empty one renders no row rather than an empty
            // one — only a field the Vault can legitimately leave blank
            // carries an `emptyMessage` prompting for it.
            fields: [
              for (final field in fieldsOf?.call(item) ?? const [])
                if (field.displayText.trim().isNotEmpty ||
                    field.emptyMessage != null)
                  field,
            ],
            bullets: [
              for (final bullet in bulletsOf(item))
                SelectorItem(
                  id: bullet.id,
                  title: bulletText(bullet),
                  selected: isBulletIncluded(item, bullet),
                  onToggle: () => onToggleBullet(item, bullet),
                  titleField: TailorableField(
                    hasOverride: hasBulletOverride(bullet.id),
                    effectiveText: bulletText(bullet),
                    vaultText: bullet.text,
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
