import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
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
    required this.startYearError,
    required this.endYearError,
    required this.onStartYearChanged,
    required this.onEndYearChanged,
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

  /// Null means the field's current value is valid. A rejected edit shows
  /// this rather than silently discarding the keystroke — see
  /// `docs/ux/7.8-vault.md`'s date-bug writeup for exactly what that
  /// silent-discard bug looked like.
  final String? startYearError;
  final String? endYearError;

  /// Raw text, not a parsed `int` — validating and deciding whether to
  /// commit is `VaultViewModel`'s job (CLAUDE.md's "logic in the
  /// ViewModel" rule), not this stateless panel's.
  final ValueChanged<String> onStartYearChanged;
  final ValueChanged<String> onEndYearChanged;

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
        ..._buildGroupPicker(context),
        const VGap.medium(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MonthField(
                label: 'Start month',
                value: experience.start.month,
                onChanged: (month) => onChanged(
                  experience.copyWith(
                    start: experience.start.copyWith(month: month),
                  ),
                ),
              ),
            ),
            const HGap.small(),
            Expanded(
              child: AppTextField(
                label: 'Start year',
                initialValue: experience.start.year.toString(),
                keyboardType: TextInputType.number,
                errorText: startYearError,
                onChanged: onStartYearChanged,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MonthField(
                  label: 'End month',
                  value: experience.end?.month,
                  onChanged: (month) {
                    // Seeds the year from *now*, not from start — see
                    // `VaultViewModel.updateExperienceEndYear`'s doc
                    // comment for why (7.8's "Failure 3").
                    final end =
                        experience.end ??
                        YearMonth(
                          year: DateTime.now().year,
                          month: experience.start.month,
                        );
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
                  errorText: endYearError,
                  onChanged: onEndYearChanged,
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
  List<Widget> _buildGroupPicker(BuildContext context) {
    final company = experience.company.trim().toLowerCase();
    if (company.isEmpty) return const [];

    final candidates = allExperiences
        .where((e) => e.id != experience.id)
        .where((e) => e.company.trim().toLowerCase() == company)
        .toList();
    if (candidates.isEmpty) return const [];

    return [
      const VGap.medium(),
      Text('Promotion — group with', style: context.appTypography.bodySmall),
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

/// A month picker over the closed 1-12 set — replaces free-text month
/// entry (7.8's decision 2). A closed set has no invalid state to reject
/// and no partial keystroke to silently write, so unlike the year fields
/// this never needs an [AppTextField.errorText].
class _MonthField extends StatelessWidget {
  const _MonthField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      hint: const Text('Select'),
      items: [
        for (var month = 1; month <= 12; month++)
          DropdownMenuItem(value: month, child: Text(monthName(month))),
      ],
      onChanged: (month) {
        if (month != null) onChanged(month);
      },
    );
  }
}
