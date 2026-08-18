import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'vault_text_field.dart';

class HobbiesEditorPanel extends StatelessWidget {
  const HobbiesEditorPanel({
    super.key,
    required this.hobbies,
    required this.onClose,
    required this.onAdd,
    required this.onChanged,
    required this.onDelete,
  });

  final List<HobbyItem> hobbies;
  final VoidCallback onClose;
  final VoidCallback onAdd;
  final ValueChanged<HobbyItem> onChanged;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: 'Hobbies and interests',
      onClose: onClose,
      children: [
        VaultSectionHeading(title: 'Items', onAdd: onAdd),
        if (hobbies.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: kdPaddingTight),
            child: Text('Nothing yet.', style: TextStyle(color: kcLightGrey)),
          ),
        for (final hobby in hobbies)
          Padding(
            padding: const EdgeInsets.only(bottom: kdPaddingTight),
            child: Row(
              children: [
                Expanded(
                  child: VaultTextField(
                    initialValue: hobby.text,
                    onChanged: (v) => onChanged(hobby.copyWith(text: v)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: kcLightGrey),
                  onPressed: () => onDelete(hobby.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
      ],
    );
  }
}
