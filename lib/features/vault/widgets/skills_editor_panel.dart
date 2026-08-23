import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'vault_editor_panel_scaffold.dart';
import 'vault_section_heading.dart';
import 'package:cv_forge/ui/widgets/common/app_chip_group_selector/app_chip_group_selector.dart';
import 'package:cv_forge/ui/widgets/common/app_delete_icon_button/app_delete_icon_button.dart';
import 'package:cv_forge/ui/widgets/common/app_inline_empty_message/app_inline_empty_message.dart';
import 'package:cv_forge/ui/widgets/common/app_text_field.dart';

class SkillsEditorPanel extends StatefulWidget {
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
  State<SkillsEditorPanel> createState() => _SkillsEditorPanelState();
}

class _SkillsEditorPanelState extends State<SkillsEditorPanel> {
  /// Presentation state, not Vault data — same call as
  /// `StudioSkillSelector._query`. A category stays visible on a name
  /// match even with no matching skills yet (so it can still be found to
  /// add one under), but only ever renders the skills that themselves
  /// match.
  String _query = '';

  List<Skill> _matchingSkills(SkillCategory category) {
    if (_query.isEmpty) return category.skills;
    return category.skills
        .where((s) => s.label.toLowerCase().contains(_query))
        .toList();
  }

  bool _categoryVisible(SkillCategory category) {
    if (_query.isEmpty) return true;
    if (category.name.toLowerCase().contains(_query)) return true;
    return _matchingSkills(category).isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    final visibleCategories = categories
        .where(_categoryVisible)
        .toList(growable: false);
    return VaultEditorPanelScaffold(
      title: 'Skills',
      onClose: widget.onClose,
      children: [
        VaultSectionHeading(
          title: 'Categories',
          onAdd: widget.onAddCategory,
          addLabel: 'Add category',
        ),
        if (categories.isEmpty)
          const AppInlineEmptyMessage('No skill categories yet.')
        else ...[
          TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Search skills…',
              prefixIcon: Icon(
                RemixIcons.search_line,
                size: context.appIconSize.medium,
              ),
            ),
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
          ),
          const VGap.small(),
          if (visibleCategories.isEmpty)
            const AppInlineEmptyMessage('No skills match your search.'),
        ],
        for (final category in visibleCategories)
          Container(
            margin: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
            padding: EdgeInsets.all(context.appSpacing.paddingCompact),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
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
                        onChanged: (v) => widget.onUpdateCategory(
                          category.copyWith(name: v),
                        ),
                      ),
                    ),
                    AppDeleteIconButton(
                      tooltip: 'Delete category',
                      onPressed: () => widget.onDeleteCategory(category.id),
                    ),
                  ],
                ),
                for (final skill in _matchingSkills(category))
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
                                onChanged: (v) => widget.onUpdateSkill(
                                  category.id,
                                  skill.copyWith(label: v),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                RemixIcons.close_line,
                                color: kcLightGrey,
                                size: context.appIconSize.medium,
                              ),
                              onPressed: () =>
                                  widget.onDeleteSkill(category.id, skill.id),
                              tooltip: 'Delete skill',
                            ),
                          ],
                        ),
                        _SkillBulletLinkPicker(
                          categoryId: category.id,
                          skill: skill,
                          experiences: widget.experiences,
                          onUpdateSkill: widget.onUpdateSkill,
                        ),
                      ],
                    ),
                  ),
                const VGap.tiny(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => widget.onAddSkill(category.id),
                    icon: Icon(
                      RemixIcons.add_line,
                      size: context.appIconSize.small,
                    ),
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
              size: context.appIconSize.small,
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
          Padding(
            padding: EdgeInsets.only(
              top: context.appSpacing.paddingDefault,
              left: context.appSpacing.paddingTight,
            ),
            child: AppChipGroupSelector(
              groups: [
                for (final experience in experiencesWithBullets)
                  AppChipGroup(
                    label: _experienceHeading(experience),
                    items: [
                      for (final bullet in experience.bullets)
                        AppChipGroupItem(
                          id: bullet.id,
                          label: _chipLabel(bullet),
                          selected: widget.skill.linkedBulletIds.contains(
                            bullet.id,
                          ),
                          tooltip: bullet.label ?? bullet.text,
                          onToggle: (selected) {
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
