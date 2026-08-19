import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

/// The bullet list inside an experience's editor panel — labelled/
/// unlabelled text, add, delete, and drag-to-reorder.
class BulletListEditor extends StatelessWidget {
  const BulletListEditor({
    super.key,
    required this.bullets,
    required this.skillCategories,
    required this.onAdd,
    required this.onChanged,
    required this.onDelete,
    required this.onReorder,
  });

  final List<CvBullet> bullets;

  /// Read-only here — which skills link to a bullet is set from the
  /// Skills panel (`_SkillBulletLinkPicker`), not from this one. Shown
  /// underneath each bullet so it's visible without switching panels.
  final List<SkillCategory> skillCategories;
  final VoidCallback onAdd;
  final ValueChanged<CvBullet> onChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<List<String>> onReorder;

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
        VaultSectionHeading(title: 'Bullets', onAdd: onAdd),
        if (bullets.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: kdPaddingTight),
            child: Text(
              'No bullets yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: bullets.length,
          onReorderItem: (oldIndex, newIndex) {
            final ids = bullets.map((b) => b.id).toList();
            final id = ids.removeAt(oldIndex);
            ids.insert(newIndex, id);
            onReorder(ids);
          },
          itemBuilder: (context, index) {
            final bullet = bullets[index];
            return Padding(
              key: ValueKey(bullet.id),
              padding: const EdgeInsets.only(bottom: kdPaddingTight),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 14, right: 4),
                      child: Icon(RemixIcons.draggable, color: kcMediumGrey),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Label (optional)',
                          hint: 'e.g. Performance',
                          initialValue: bullet.label ?? '',
                          onChanged: (v) => onChanged(
                            bullet.copyWith(label: v.isEmpty ? null : v),
                          ),
                        ),
                        verticalSpaceTiny,
                        AppTextField(
                          label: 'Text',
                          initialValue: bullet.text,
                          maxLines: 3,
                          onChanged: (v) => onChanged(bullet.copyWith(text: v)),
                        ),
                        if (skillLabelsByBulletId[bullet.id] case final labels?
                            when labels.isNotEmpty) ...[
                          verticalSpaceTiny,
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Skills: ${labels.join(', ')}',
                              style: const TextStyle(
                                color: kcLightGrey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      RemixIcons.delete_bin_line,
                      color: kcLightGrey,
                    ),
                    onPressed: () => onDelete(bullet.id),
                    tooltip: 'Delete bullet',
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
