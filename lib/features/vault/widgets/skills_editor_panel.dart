import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

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
          Padding(
            padding: EdgeInsets.only(bottom: context.appSpacing.paddingTight),
            child: const Text(
              'No skill categories yet.',
              style: TextStyle(color: kcLightGrey),
            ),
          ),
        for (final category in categories)
          Container(
            margin: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
            padding: EdgeInsets.all(context.appSpacing.paddingCompact),
            decoration: BoxDecoration(
              color: kcBackgroundColor,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
              border: Border.all(color: kcMediumGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Category name',
                        initialValue: category.name,
                        onChanged: (v) =>
                            onUpdateCategory(category.copyWith(name: v)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        RemixIcons.delete_bin_line,
                        color: kcLightGrey,
                      ),
                      onPressed: () => onDeleteCategory(category.id),
                      tooltip: 'Delete category',
                    ),
                  ],
                ),
                for (final skill in category.skills)
                  Padding(
                    padding: EdgeInsets.only(
                      top: context.appSpacing.paddingTight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
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
                                RemixIcons.close_line,
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
                const VGap.tiny(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => onAddSkill(category.id),
                    icon: const Icon(RemixIcons.add_line, size: 16),
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
              _expanded
                  ? RemixIcons.arrow_up_s_line
                  : RemixIcons.arrow_down_s_line,
              size: 16,
            ),
            label: Text(
              linkedCount == 0
                  ? 'Link to bullets'
                  : 'Linked to $linkedCount '
                        'bullet${linkedCount == 1 ? '' : 's'}',
              style: context.appTypography.caption,
            ),
          ),
        ),
        if (_expanded)
          for (final experience in experiencesWithBullets)
            Padding(
              padding: EdgeInsets.only(
                top: context.appSpacing.paddingDefault,
                left: context.appSpacing.paddingTight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _experienceHeading(experience),
                    style: context.appTypography.caption.copyWith(
                      color: kcLightGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const VGap.tiny(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final bullet in experience.bullets)
                        Tooltip(
                          message: bullet.label ?? bullet.text,
                          child: FilterChip(
                            label: Text(
                              _chipLabel(bullet),
                              style: context.appTypography.caption,
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
                        ),
                    ],
                  ),
                ],
              ),
            ),
      ],
    );
  }

  /// "Role · Company" — falls back to just the role when there's no
  /// company to disambiguate against (or vice versa), rather than a
  /// dangling " · " with nothing on one side. Several roles can easily
  /// share a title ("Software Engineer" at three different companies),
  /// so the heading needs the company to actually tell them apart.
  String _experienceHeading(Experience experience) {
    final role = experience.role.isEmpty ? 'Untitled role' : experience.role;
    final company = experience.company;
    return company.isEmpty ? role : '$role · $company';
  }

  String _chipLabel(CvBullet bullet) {
    final text = bullet.label ?? bullet.text;
    return text.length > 28 ? '${text.substring(0, 28)}…' : text;
  }
}
