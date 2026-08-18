import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'vault_summary_card.dart';
import 'vault_text_field.dart';

class HobbiesEditorCard extends StatelessWidget {
  const HobbiesEditorCard({
    super.key,
    required this.hobbies,
    required this.selected,
    required this.onTap,
  });

  final List<HobbyItem> hobbies;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return VaultSummaryCard(
      title: 'Hobbies and interests',
      subtitle: hobbies.isEmpty
          ? 'None yet'
          : hobbies.map((h) => h.text).join(', '),
      selected: selected,
      onTap: onTap,
      leading: const Icon(Icons.hiking_outlined, color: kcLightGrey),
    );
  }
}

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
            padding: EdgeInsets.only(bottom: 8),
            child: Text('Nothing yet.', style: TextStyle(color: kcLightGrey)),
          ),
        for (final hobby in hobbies)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
