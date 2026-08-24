import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class EducationEditorPanel extends StatelessWidget {
  const EducationEditorPanel({
    super.key,
    required this.education,
    required this.skillCategories,
    required this.onUpdateSkill,
    required this.onAddSkill,
    required this.onAddCategory,
    required this.onClose,
    required this.onChanged,
    required this.bulletCallbacks,
    required this.yearError,
    required this.onYearChanged,
  });

  final Education education;
  final List<SkillCategory> skillCategories;
  final void Function(String categoryId, Skill skill) onUpdateSkill;
  final Future<Skill> Function(String categoryId, String label) onAddSkill;
  final Future<SkillCategory> Function(String name) onAddCategory;
  final VoidCallback onClose;
  final ValueChanged<Education> onChanged;
  final BulletEditorCallbacks bulletCallbacks;

  /// Null means the field's current value is valid — see
  /// `ExperienceEditorPanel.startYearError`'s doc comment for the same
  /// rule one field over. Unlike a start/end year, Education's year is
  /// genuinely optional, so an empty field is valid here too.
  final String? yearError;
  final ValueChanged<String> onYearChanged;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: education.qualification.isEmpty
          ? context.l10n.vaultEducationNew
          : education.qualification,
      onClose: onClose,
      children: [
        AppTextField(
          label: context.l10n.vaultEducationQualification,
          hint: context.l10n.vaultEducationQualificationHint,
          initialValue: education.qualification,
          onChanged: (v) => onChanged(education.copyWith(qualification: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultEducationInstitution,
          initialValue: education.institution,
          onChanged: (v) => onChanged(education.copyWith(institution: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultEducationLocation,
          initialValue: education.location ?? '',
          onChanged: (v) =>
              onChanged(education.copyWith(location: v.orNullIfEmpty)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultEducationYear,
          initialValue: education.year?.toString() ?? '',
          keyboardType: TextInputType.number,
          errorText: yearError,
          onChanged: onYearChanged,
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultEducationGrade,
          hint: context.l10n.vaultEducationGradeHint,
          initialValue: education.grade ?? '',
          onChanged: (v) =>
              onChanged(education.copyWith(grade: v.orNullIfEmpty)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultEducationDetails,
          initialValue: education.details ?? '',
          maxLines: 3,
          onChanged: (v) =>
              onChanged(education.copyWith(details: v.orNullIfEmpty)),
        ),
        const VGap.medium(),
        BulletListEditor(
          bullets: education.bullets,
          skillCategories: skillCategories,
          onUpdateSkill: onUpdateSkill,
          onAddSkill: onAddSkill,
          onAddCategory: onAddCategory,
          callbacks: bulletCallbacks,
        ),
      ],
    );
  }
}
