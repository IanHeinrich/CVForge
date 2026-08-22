import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'bullet_list_editor.dart';
import 'vault_editor_panel_scaffold.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class ProjectEditorPanel extends StatelessWidget {
  const ProjectEditorPanel({
    super.key,
    required this.project,
    required this.skillCategories,
    required this.onClose,
    required this.onChanged,
    required this.bulletCallbacks,
  });

  final Project project;
  final List<SkillCategory> skillCategories;
  final VoidCallback onClose;
  final ValueChanged<Project> onChanged;
  final BulletEditorCallbacks bulletCallbacks;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: project.title.isEmpty ? 'New project' : project.title,
      onClose: onClose,
      children: [
        AppTextField(
          label: 'Title',
          initialValue: project.title,
          onChanged: (v) => onChanged(project.copyWith(title: v)),
        ),
        const VGap.small(),
        AppTextField(
          label: 'Link (optional)',
          hint: 'e.g. github.com/you/project',
          initialValue: project.link ?? '',
          onChanged: (v) => onChanged(project.copyWith(link: v.orNullIfEmpty)),
        ),
        const VGap.medium(),
        BulletListEditor(
          bullets: project.bullets,
          skillCategories: skillCategories,
          callbacks: bulletCallbacks,
        ),
      ],
    );
  }
}
