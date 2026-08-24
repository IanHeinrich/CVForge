import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/models/vault/year_month.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n/month_labels.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
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
    required this.onUpdateSkill,
    required this.onAddSkill,
    required this.onAddCategory,
    required this.onClose,
    required this.onChanged,
    required this.onGroupChanged,
    required this.bulletCallbacks,
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

  /// Passed straight through to [BulletListEditor]'s skill-link picker.
  final List<SkillCategory> skillCategories;
  final void Function(String categoryId, Skill skill) onUpdateSkill;
  final Future<Skill> Function(String categoryId, String label) onAddSkill;
  final Future<SkillCategory> Function(String name) onAddCategory;
  final VoidCallback onClose;
  final ValueChanged<Experience> onChanged;

  /// Called with the id of the experience to group this one with (a
  /// promotion at the same company), or `null` to ungroup it.
  final ValueChanged<String?> onGroupChanged;
  final BulletEditorCallbacks bulletCallbacks;

  /// Null means the field's current value is valid. A rejected edit shows
  /// this rather than silently discarding the keystroke.
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
      title: experience.role.isEmpty
          ? context.l10n.vaultExperienceNew
          : experience.role,
      onClose: onClose,
      children: [
        AppTextField(
          label: context.l10n.vaultExperienceRole,
          initialValue: experience.role,
          onChanged: (v) => onChanged(experience.copyWith(role: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultExperienceCompany,
          initialValue: experience.company,
          onChanged: (v) => onChanged(experience.copyWith(company: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultExperienceLocation,
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
                label: context.l10n.vaultExperienceStartMonth,
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
                label: context.l10n.vaultExperienceStartYear,
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
          title: Text(
            context.l10n.vaultExperienceCurrent,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          activeColor: Theme.of(context).colorScheme.primary,
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
                  label: context.l10n.vaultExperienceEndMonth,
                  value: experience.end?.month,
                  onChanged: (month) {
                    // Seeds the year from *now*, not from start — see
                    // `VaultViewModel.updateExperienceEndYear`'s doc
                    // comment for why.
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
                  label: context.l10n.vaultExperienceEndYear,
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
          onUpdateSkill: onUpdateSkill,
          onAddSkill: onAddSkill,
          onAddCategory: onAddCategory,
          callbacks: bulletCallbacks,
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
      Text(
        context.l10n.vaultExperiencePromotionGroup,
        style: context.appTypography.bodySmall,
      ),
      const VGap.tiny(),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final candidate in candidates)
            ChoiceChip(
              label: Text(
                candidate.role.isEmpty
                    ? context.l10n.vaultUntitledRole
                    : candidate.role,
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

/// A month picker over the closed 1-12 set. A closed set has no invalid
/// state to reject and no partial keystroke to silently write, so unlike
/// the year fields this never needs an [AppTextField.errorText].
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
      hint: Text(context.l10n.commonSelect),
      items: [
        for (var month = 1; month <= 12; month++)
          DropdownMenuItem(
            value: month,
            child: Text(monthLabel(context.l10n, month)),
          ),
      ],
      onChanged: (month) {
        if (month != null) onChanged(month);
      },
    );
  }
}
