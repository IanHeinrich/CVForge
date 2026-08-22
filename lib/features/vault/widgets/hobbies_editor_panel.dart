import 'package:cv_forge/models/vault/hobby_item.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_delete_icon_button/app_delete_icon_button.dart';
import 'package:cv_forge/ui/widgets/common/app_inline_empty_message/app_inline_empty_message.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

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
        if (hobbies.isEmpty) const AppInlineEmptyMessage('Nothing yet.'),
        for (final hobby in hobbies)
          Padding(
            padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    initialValue: hobby.text,
                    onChanged: (v) => onChanged(hobby.copyWith(text: v)),
                  ),
                ),
                AppDeleteIconButton(onPressed: () => onDelete(hobby.id)),
              ],
            ),
          ),
      ],
    );
  }
}
