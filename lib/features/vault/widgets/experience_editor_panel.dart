import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class ExperienceEditorPanel extends StatelessWidget {
  const ExperienceEditorPanel({
    super.key,
    required this.experience,
    required this.allExperiences,
    required this.skillCategories,
    required this.onClose,
    required this.onChanged,
    required this.onGroupChanged,
    required this.onAddBullet,
    required this.onBulletChanged,
    required this.onBulletDeleted,
    required this.onBulletsReordered,
  });

  final Experience experience;

  /// Every other experience in the Vault, used to offer "group with"
  /// candidates at the same company. Not filtered by the caller — this
  /// widget does its own same-company matching.
  final List<Experience> allExperiences;

  /// Passed straight through to [BulletListEditor] for its read-only
  /// "which skills link to this bullet" display.
  final List<SkillCategory> skillCategories;
  final VoidCallback onClose;
  final ValueChanged<Experience> onChanged;

  /// Called with the id of the experience to group this one with (a
  /// promotion at the same company), or `null` to ungroup it.
  final ValueChanged<String?> onGroupChanged;
  final VoidCallback onAddBullet;
  final ValueChanged<CvBullet> onBulletChanged;
  final ValueChanged<String> onBulletDeleted;
  final ValueChanged<List<String>> onBulletsReordered;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: experience.role.isEmpty ? 'New experience' : experience.role,
      onClose: onClose,
      children: [
        AppTextField(
          label: 'Role',
          initialValue: experience.role,
          onChanged: (v) => onChanged(experience.copyWith(role: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Company',
          initialValue: experience.company,
          onChanged: (v) => onChanged(experience.copyWith(company: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Location',
          initialValue: experience.location,
          onChanged: (v) => onChanged(experience.copyWith(location: v)),
        ),
        ..._buildGroupPicker(),
        const VGap.medium(),
        Row(
          children: [
            Expanded(
              child: AppTextField(
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
            const HGap.small(),
            Expanded(
              child: AppTextField(
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
        const VGap.small(),
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
          const VGap.small(),
          Row(
            children: [
              Expanded(
                child: AppTextField(
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
              const HGap.small(),
              Expanded(
                child: AppTextField(
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
        const VGap.medium(),
        BulletListEditor(
          bullets: experience.bullets,
          skillCategories: skillCategories,
          onAdd: onAddBullet,
          onChanged: onBulletChanged,
          onDelete: onBulletDeleted,
          onReorder: onBulletsReordered,
        ),
      ],
    );
  }

  /// Same-company candidates this entry can be grouped with as a
  /// promotion. Matched on trimmed, case-insensitive company name so
  /// "Acme" and "Acme " (or "acme") still match.
  List<Widget> _buildGroupPicker() {
    final company = experience.company.trim().toLowerCase();
    if (company.isEmpty) return const [];

    final candidates = allExperiences
        .where((e) => e.id != experience.id)
        .where((e) => e.company.trim().toLowerCase() == company)
        .toList();
    if (candidates.isEmpty) return const [];

    return [
      const VGap.medium(),
      const Text(
        'Promotion — group with',
        style: TextStyle(color: kcLightGrey, fontSize: 13),
      ),
      const VGap.tiny(),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final candidate in candidates)
            ChoiceChip(
              label: Text(
                candidate.role.isEmpty ? 'Untitled role' : candidate.role,
              ),
              selected:
                  experience.companyGroupId != null &&
                  experience.companyGroupId == candidate.companyGroupId,
              onSelected: (selected) =>
                  onGroupChanged(selected ? candidate.id : null),
            ),
        ],
      ),
    ];
  }
}
