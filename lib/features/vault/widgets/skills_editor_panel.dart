import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/experience_bullet.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/app_constants.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'vault_text_field.dart';

class SkillsEditorPanel extends StatelessWidget {
  const SkillsEditorPanel({
    super.key,
    required this.categories,
    required this.experiences,
    required this.onClose,
    required this.onAddCategory,
    required this.onUpdateCategory,
    required this.onDeleteCategory,
    required this.onAddSkill,
    required this.onUpdateSkill,
    required this.onDeleteSkill,
  });

  final List<SkillCategory> categories;

  /// Offered as bullet-linking toggles per skill — see
  /// [_SkillBulletLinkPicker].
  final List<Experience> experiences;
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
            padding: EdgeInsets.only(bottom: kdPaddingTight),
            child: Text(
              'No skill categories yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        for (final category in categories)
          Container(
            margin: const EdgeInsets.only(bottom: kdPaddingDefault),
            padding: const EdgeInsets.all(kdPaddingCompact),
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
                    padding: const EdgeInsets.only(top: kdPaddingTight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
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
                              onPressed: () =>
                                  onDeleteSkill(category.id, skill.id),
                              tooltip: 'Delete skill',
                            ),
                          ],
                        ),
                        _SkillBulletLinkPicker(
                          categoryId: category.id,
                          skill: skill,
                          experiences: experiences,
                          onUpdateSkill: onUpdateSkill,
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

/// Collapsed by default — a skill can have a bullet linked in every
/// experience, and showing every bullet as a chip for every skill up
/// front would make a Vault with a handful of skills and experiences
/// scroll for miles. Local `_expanded` is pure presentation state, not
/// Vault data, so it doesn't go through the ViewModel.
class _SkillBulletLinkPicker extends StatefulWidget {
  const _SkillBulletLinkPicker({
    required this.categoryId,
    required this.skill,
    required this.experiences,
    required this.onUpdateSkill,
  });

  final String categoryId;
  final Skill skill;
  final List<Experience> experiences;
  final void Function(String categoryId, Skill skill) onUpdateSkill;

  @override
  State<_SkillBulletLinkPicker> createState() => _SkillBulletLinkPickerState();
}

class _SkillBulletLinkPickerState extends State<_SkillBulletLinkPicker> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final experiencesWithBullets = widget.experiences
        .where((e) => e.bullets.isNotEmpty)
        .toList();
    if (experiencesWithBullets.isEmpty) return const SizedBox.shrink();

    final linkedCount = widget.skill.linkedBulletIds.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded ? Icons.expand_less : Icons.expand_more,
              size: 16,
            ),
            label: Text(
              linkedCount == 0
                  ? 'Link to bullets'
                  : 'Linked to $linkedCount '
                        'bullet${linkedCount == 1 ? '' : 's'}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        if (_expanded)
          for (final experience in experiencesWithBullets)
            Padding(
              padding: const EdgeInsets.only(
                top: kdPaddingTight,
                left: kdPaddingTight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.role.isEmpty ? 'Untitled role' : experience.role,
                    style: const TextStyle(
                      color: kcLightGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  verticalSpaceTiny,
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final bullet in experience.bullets)
                        FilterChip(
                          label: Text(
                            _chipLabel(bullet),
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                          selected: widget.skill.linkedBulletIds.contains(
                            bullet.id,
                          ),
                          onSelected: (selected) {
                            final ids = [...widget.skill.linkedBulletIds];
                            if (selected) {
                              ids.add(bullet.id);
                            } else {
                              ids.remove(bullet.id);
                            }
                            widget.onUpdateSkill(
                              widget.categoryId,
                              widget.skill.copyWith(linkedBulletIds: ids),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _chipLabel(ExperienceBullet bullet) {
    final text = bullet.label ?? bullet.text;
    return text.length > 28 ? '${text.substring(0, 28)}…' : text;
  }
}
