import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/experience_bullet.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'vault_text_field.dart';

class ExperienceEditorPanel extends StatelessWidget {
  const ExperienceEditorPanel({
    super.key,
    required this.experience,
    required this.onClose,
    required this.onChanged,
    required this.onAddBullet,
    required this.onBulletChanged,
    required this.onBulletDeleted,
    required this.onBulletsReordered,
  });

  final Experience experience;
  final VoidCallback onClose;
  final ValueChanged<Experience> onChanged;
  final VoidCallback onAddBullet;
  final ValueChanged<ExperienceBullet> onBulletChanged;
  final ValueChanged<String> onBulletDeleted;
  final ValueChanged<List<String>> onBulletsReordered;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: experience.role.isEmpty ? 'New experience' : experience.role,
      onClose: onClose,
      children: [
        VaultTextField(
          label: 'Role',
          initialValue: experience.role,
          onChanged: (v) => onChanged(experience.copyWith(role: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Company',
          initialValue: experience.company,
          onChanged: (v) => onChanged(experience.copyWith(company: v)),
        ),
        verticalSpaceSmall,
        VaultTextField(
          label: 'Location',
          initialValue: experience.location,
          onChanged: (v) => onChanged(experience.copyWith(location: v)),
        ),
        verticalSpaceMedium,
        Row(
          children: [
            Expanded(
              child: VaultTextField(
                label: 'Start month',
                initialValue: experience.start.month.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final month = int.tryParse(v);
                  if (month != null && month >= 1 && month <= 12) {
                    onChanged(
                      experience.copyWith(
                        start: experience.start.copyWith(month: month),
                      ),
                    );
                  }
                },
              ),
            ),
            horizontalSpaceSmall,
            Expanded(
              child: VaultTextField(
                label: 'Start year',
                initialValue: experience.start.year.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final year = int.tryParse(v);
                  if (year != null) {
                    onChanged(
                      experience.copyWith(
                        start: experience.start.copyWith(year: year),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        verticalSpaceSmall,
        CheckboxListTile(
          value: experience.isCurrent,
          onChanged: (checked) => onChanged(
            experience.copyWith(
              isCurrent: checked ?? false,
              end: (checked ?? false) ? null : experience.end,
            ),
          ),
          title: const Text(
            'I currently work here',
            style: TextStyle(color: kcWhite),
          ),
          activeColor: kcPrimaryColor,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        if (!experience.isCurrent) ...[
          verticalSpaceSmall,
          Row(
            children: [
              Expanded(
                child: VaultTextField(
                  label: 'End month',
                  initialValue: experience.end?.month.toString() ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final month = int.tryParse(v);
                    if (month == null || month < 1 || month > 12) return;
                    final end = experience.end ?? experience.start;
                    onChanged(
                      experience.copyWith(end: end.copyWith(month: month)),
                    );
                  },
                ),
              ),
              horizontalSpaceSmall,
              Expanded(
                child: VaultTextField(
                  label: 'End year',
                  initialValue: experience.end?.year.toString() ?? '',
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final year = int.tryParse(v);
                    if (year == null) return;
                    final end = experience.end ?? experience.start;
                    onChanged(
                      experience.copyWith(end: end.copyWith(year: year)),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
        verticalSpaceMedium,
        BulletListEditor(
          bullets: experience.bullets,
          onAdd: onAddBullet,
          onChanged: onBulletChanged,
          onDelete: onBulletDeleted,
          onReorder: onBulletsReordered,
        ),
      ],
    );
  }
}
