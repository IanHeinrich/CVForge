import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'vault_summary_card.dart';
import 'vault_text_field.dart';

class SkillsEditorCard extends StatelessWidget {
  const SkillsEditorCard({
    super.key,
    required this.categories,
    required this.selected,
    required this.onTap,
  });

  final List<SkillCategory> categories;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final skillCount = categories.fold<int>(
      0,
      (sum, c) => sum + c.skills.length,
    );

    return VaultSummaryCard(
      title: 'Skills',
      subtitle: categories.isEmpty
          ? 'No skills yet'
          : '${categories.length} categories, $skillCount skills',
      selected: selected,
      onTap: onTap,
      leading: const Icon(Icons.star_outline, color: kcLightGrey),
    );
  }
}

class SkillsEditorPanel extends StatelessWidget {
  const SkillsEditorPanel({
    super.key,
    required this.categories,
    required this.onClose,
    required this.onAddCategory,
    required this.onUpdateCategory,
    required this.onDeleteCategory,
    required this.onAddSkill,
    required this.onUpdateSkill,
    required this.onDeleteSkill,
  });

  final List<SkillCategory> categories;
  final VoidCallback onClose;
  final VoidCallback onAddCategory;
  final ValueChanged<SkillCategory> onUpdateCategory;
  final ValueChanged<String> onDeleteCategory;
  final void Function(String categoryId) onAddSkill;
  final void Function(String categoryId, Skill skill) onUpdateSkill;
  final void Function(String categoryId, String skillId) onDeleteSkill;

  @override
  Widget build(BuildContext context) {
    return VaultEditorPanelScaffold(
      title: 'Skills',
      onClose: onClose,
      children: [
        VaultSectionHeading(
          title: 'Categories',
          onAdd: onAddCategory,
          addLabel: 'Add category',
        ),
        if (categories.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'No skill categories yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        for (final category in categories)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kcBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kcMediumGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: VaultTextField(
                        label: 'Category name',
                        initialValue: category.name,
                        onChanged: (v) =>
                            onUpdateCategory(category.copyWith(name: v)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: kcLightGrey,
                      ),
                      onPressed: () => onDeleteCategory(category.id),
                      tooltip: 'Delete category',
                    ),
                  ],
                ),
                for (final skill in category.skills)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: VaultTextField(
                            hint: 'Skill',
                            initialValue: skill.label,
                            onChanged: (v) => onUpdateSkill(
                              category.id,
                              skill.copyWith(label: v),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: kcLightGrey,
                            size: 18,
                          ),
                          onPressed: () => onDeleteSkill(category.id, skill.id),
                          tooltip: 'Delete skill',
                        ),
                      ],
                    ),
                  ),
                verticalSpaceTiny,
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => onAddSkill(category.id),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add skill'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
