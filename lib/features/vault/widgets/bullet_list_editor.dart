import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_delete_icon_button/app_delete_icon_button.dart';
import 'package:cv_forge/ui/widgets/common/app_inline_empty_message/app_inline_empty_message.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

/// A bullet's add/change/delete/reorder callbacks, bundled into one value
/// so every entity's editor panel (experience, project, education,
/// publication) passes a single prop through to [BulletListEditor] and
/// `VaultEditorPanelRouter` builds it once per case rather than repeating
/// the same four closures four times.
class BulletEditorCallbacks {
  const BulletEditorCallbacks({
    required this.onAdd,
    required this.onChanged,
    required this.onDelete,
    required this.onReorder,
  });

  final VoidCallback onAdd;
  final ValueChanged<CvBullet> onChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<List<String>> onReorder;
}

/// The bullet list inside an experience's editor panel — labelled/
/// unlabelled text, add, delete, and drag-to-reorder.
class BulletListEditor extends StatelessWidget {
  const BulletListEditor({
    super.key,
    required this.bullets,
    required this.skillCategories,
    required this.callbacks,
  });

  final List<CvBullet> bullets;

  /// Read-only here — which skills link to a bullet is set from the
  /// Skills panel (`_SkillBulletLinkPicker`), not from this one. Shown
  /// underneath each bullet so it's visible without switching panels.
  final List<SkillCategory> skillCategories;
  final BulletEditorCallbacks callbacks;

  @override
  Widget build(BuildContext context) {
    final skillLabelsByBulletId = <String, List<String>>{};
    for (final category in skillCategories) {
      for (final skill in category.skills) {
        for (final bulletId in skill.linkedBulletIds) {
          (skillLabelsByBulletId[bulletId] ??= []).add(skill.label);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(title: 'Bullets', onAdd: callbacks.onAdd),
        if (bullets.isEmpty) const AppInlineEmptyMessage('No bullets yet.'),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: bullets.length,
          onReorderItem: (oldIndex, newIndex) {
            final ids = bullets.map((b) => b.id).toList();
            final id = ids.removeAt(oldIndex);
            ids.insert(newIndex, id);
            callbacks.onReorder(ids);
          },
          itemBuilder: (context, index) {
            final bullet = bullets[index];
            return Padding(
              key: ValueKey(bullet.id),
              padding: EdgeInsets.only(
                bottom: context.appSpacing.paddingDefault,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 14,
                        right: context.appSpacing.paddingHairline,
                      ),
                      child: const Icon(
                        RemixIcons.draggable,
                        color: kcMediumGrey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Label (optional)',
                          hint: 'e.g. Performance',
                          initialValue: bullet.label ?? '',
                          onChanged: (v) => callbacks.onChanged(
                            bullet.copyWith(label: v.orNullIfEmpty),
                          ),
                        ),
                        const VGap.tiny(),
                        AppTextField(
                          label: 'Text',
                          initialValue: bullet.text,
                          maxLines: 3,
                          onChanged: (v) =>
                              callbacks.onChanged(bullet.copyWith(text: v)),
                        ),
                        if (skillLabelsByBulletId[bullet.id] case final labels?
                            when labels.isNotEmpty) ...[
                          const VGap.tiny(),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Skills: ${labels.join(', ')}',
                              style: context.appTypography.caption.copyWith(
                                color: kcLightGrey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AppDeleteIconButton(
                    tooltip: 'Delete bullet',
                    onPressed: () => callbacks.onDelete(bullet.id),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
