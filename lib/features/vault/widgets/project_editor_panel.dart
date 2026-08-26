import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class ProjectEditorPanel extends StatelessWidget {
  const ProjectEditorPanel({
    super.key,
    required this.project,
    required this.skillCategories,
    required this.onUpdateSkill,
    required this.onAddSkill,
    required this.onAddCategory,
    required this.onClose,
    required this.onChanged,
    required this.bulletCallbacks,
  });

  final Project project;
  final List<SkillCategory> skillCategories;
  final void Function(String categoryId, Skill skill) onUpdateSkill;
  final Future<Skill> Function(String categoryId, String label) onAddSkill;
  final Future<SkillCategory> Function(String name) onAddCategory;
  final VoidCallback onClose;
  final ValueChanged<Project> onChanged;
  final BulletEditorCallbacks bulletCallbacks;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: project.title.isEmpty
          ? context.l10n.vaultProjectNew
          : project.title,
      onClose: onClose,
      children: [
        AppTextField(
          label: context.l10n.vaultProjectTitle,
          initialValue: project.title,
          markup: true,
          onChanged: (v) => onChanged(project.copyWith(title: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: context.l10n.vaultProjectLink,
          hint: context.l10n.vaultProjectLinkHint,
          initialValue: project.link ?? '',
          onChanged: (v) => onChanged(project.copyWith(link: v.orNullIfEmpty)),
        ),
        const VGap.medium(),
        BulletListEditor(
          bullets: project.bullets,
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
