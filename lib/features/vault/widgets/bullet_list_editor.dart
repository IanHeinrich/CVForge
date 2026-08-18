import 'package:cv_forge/models/vault/experience_bullet.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'vault_section_heading.dart';
import 'vault_text_field.dart';

/// The bullet list inside an experience's editor panel — labelled/
/// unlabelled text, add, delete, and drag-to-reorder.
class BulletListEditor extends StatelessWidget {
  const BulletListEditor({
    super.key,
    required this.bullets,
    required this.onAdd,
    required this.onChanged,
    required this.onDelete,
    required this.onReorder,
  });

  final List<ExperienceBullet> bullets;
  final VoidCallback onAdd;
  final ValueChanged<ExperienceBullet> onChanged;
  final ValueChanged<String> onDelete;
  final ValueChanged<List<String>> onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaultSectionHeading(title: 'Bullets', onAdd: onAdd),
        if (bullets.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
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
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 14, right: 4),
                      child: Icon(Icons.drag_handle, color: kcMediumGrey),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        VaultTextField(
                          label: 'Label (optional)',
                          hint: 'e.g. Performance',
                          initialValue: bullet.label ?? '',
                          onChanged: (v) => onChanged(
                            bullet.copyWith(label: v.isEmpty ? null : v),
                          ),
                        ),
                        verticalSpaceTiny,
                        VaultTextField(
                          label: 'Text',
                          initialValue: bullet.text,
                          maxLines: 3,
                          onChanged: (v) => onChanged(bullet.copyWith(text: v)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: kcLightGrey),
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
