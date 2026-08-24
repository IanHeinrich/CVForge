import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'year_month_picker/year_month_picker.dart';
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

  /// Raw text, not a parsed `int` — validating and deciding whether to
  /// commit is `VaultViewModel`'s job (CLAUDE.md's "logic in the
  /// ViewModel" rule), not this stateless panel's.

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
              child: YearMonthPicker(
                label: context.l10n.vaultExperienceStart,
                value: experience.start,
                // No onCleared: a role without a start date is not a
                // thing, and the picker hides the affordance when it is
                // null.
                onChanged: (start) =>
                    onChanged(experience.copyWith(start: start)),
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
          YearMonthPicker(
            label: context.l10n.vaultExperienceEnd,
            value: experience.end,
            // Opens on the current year rather than the start year.
            // Adopting start's year produces a plausible-looking but
            // silently wrong end date the moment only the month is
            // changed afterwards.
            initialYearWhenEmpty: DateTime.now().year,
            onChanged: (end) => onChanged(experience.copyWith(end: end)),
            onCleared: () => onChanged(experience.copyWith(end: null)),
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
