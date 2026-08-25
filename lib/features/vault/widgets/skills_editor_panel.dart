import 'package:cv_forge/models/render/cv_markup.dart';
import 'package:cv_forge/models/vault/education.dart';
import 'package:cv_forge/models/vault/experience.dart';
import 'package:cv_forge/models/vault/cv_bullet.dart';
import 'package:cv_forge/models/vault/project.dart';
import 'package:cv_forge/models/vault/publication.dart';
import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'link_picker_shell/link_picker_shell.dart';
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
    required this.projects,
    required this.education,
    required this.publications,
    required this.onClose,
    required this.onAddCategory,
    required this.onUpdateCategory,
    required this.onDeleteCategory,
    required this.onAddSkill,
    required this.onUpdateSkill,
    required this.onDeleteSkill,
  });

  final List<SkillCategory> categories;

  /// Every bullet-owning entity in the Vault, offered as bulk
  /// bullet-linking toggles per skill — see [_SkillBulletLinkPicker]. This
  /// is the coarse, bulk-linking direction (link one skill across many
  /// bullets at once, e.g. right after adding a new skill); linking one
  /// bullet to several skills is primarily done from the bullet's own
  /// editor instead — see `BulletListEditor`'s `_BulletSkillLinkPicker`.
  final List<Experience> experiences;
  final List<Project> projects;
  final List<Education> education;
  final List<Publication> publications;
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

  /// At most one skill's bullet-link picker open at a time, across every
  /// category — without this, opening one after another (which is exactly
  /// the workflow the "Add skill" affordance invites) grows the panel
  /// without bound, each `AppChipGroupSelector` stacking on top of the
  /// last rather than replacing it.
  String? _expandedSkillId;

  void _toggleSkillExpanded(String skillId) {
    setState(
      () => _expandedSkillId = _expandedSkillId == skillId ? null : skillId,
    );
  }

  List<Skill> _matchingSkills(SkillCategory category) {
    if (_query.isEmpty) return category.skills;
    return category.skills
        .where((s) => stripCvMarkup(s.label).toLowerCase().contains(_query))
        .toList();
  }

  bool _categoryVisible(SkillCategory category) {
    if (_query.isEmpty) return true;
    if (stripCvMarkup(category.name).toLowerCase().contains(_query)) {
      return true;
    }
    return _matchingSkills(category).isNotEmpty;
  }

  /// Every bullet-owning entity in the Vault, reduced to a heading plus
  /// its bullets — the common shape [_SkillBulletLinkPicker] needs
  /// regardless of which of the four entity types a bullet actually
  /// belongs to.
  List<_BulletGroup> get _bulletGroups => [
    for (final e in widget.experiences)
      if (e.bullets.isNotEmpty) _BulletGroup(_experienceHeading(e), e.bullets),
    for (final p in widget.projects)
      if (p.bullets.isNotEmpty)
        _BulletGroup(
          p.title.isEmpty ? context.l10n.vaultUntitledProject : p.title,
          p.bullets,
        ),
    for (final e in widget.education)
      if (e.bullets.isNotEmpty) _BulletGroup(_educationHeading(e), e.bullets),
    for (final p in widget.publications)
      if (p.bullets.isNotEmpty)
        _BulletGroup(
          p.title.isEmpty ? context.l10n.vaultUntitledPublication : p.title,
          p.bullets,
        ),
  ];

  /// "Role · Company" — falls back to just the role when there's no
  /// company to disambiguate against (or vice versa), rather than a
  /// dangling " · " with nothing on one side. Several roles can easily
  /// share a title ("Software Engineer" at three different companies),
  /// so the heading needs the company to actually tell them apart.
  String _experienceHeading(Experience experience) {
    final role = experience.role.isEmpty
        ? context.l10n.vaultUntitledRole
        : experience.role;
    final company = experience.company;
    return company.isEmpty
        ? role
        : context.l10n.vaultRoleAtCompany(role, company);
  }

  /// Same reasoning as [_experienceHeading] — several qualifications can
  /// share a name across institutions (or vice versa).
  String _educationHeading(Education education) {
    final qualification = education.qualification.isEmpty
        ? context.l10n.vaultUntitledQualification
        : education.qualification;
    final institution = education.institution;
    return institution.isEmpty
        ? qualification
        : context.l10n.vaultQualificationAtInstitution(
            qualification,
            institution,
          );
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories;
    final visibleCategories = categories
        .where(_categoryVisible)
        .toList(growable: false);
    return VaultEditorPanelScaffold(
      title: context.l10n.vaultSkillsTitle,
      onClose: widget.onClose,
      children: [
        VaultSectionHeading(
          title: context.l10n.vaultSkillsCategories,
          onAdd: widget.onAddCategory,
          addLabel: context.l10n.vaultSkillsAddCategory,
        ),
        if (categories.isEmpty)
          AppInlineEmptyMessage(context.l10n.vaultSkillsNoCategories)
        else ...[
          TextField(
            decoration: InputDecoration(
              isDense: true,
              hintText: context.l10n.vaultSkillsSearch,
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
            AppInlineEmptyMessage(context.l10n.vaultSkillsNoMatches),
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
                        label: context.l10n.vaultSkillsCategoryName,
                        hint: context.l10n.vaultSkillsCategoryNameHint,
                        initialValue: category.name,
                        onChanged: (v) =>
                            widget.onUpdateCategory(category.copyWith(name: v)),
                      ),
                    ),
                    AppDeleteIconButton(
                      tooltip: context.l10n.vaultSkillsDeleteCategory,
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
                                hint: context.l10n.vaultSkillsSkillLabel,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: context.appIconSize.medium,
                              ),
                              onPressed: () =>
                                  widget.onDeleteSkill(category.id, skill.id),
                              tooltip: context.l10n.vaultSkillsDeleteSkill,
                            ),
                          ],
                        ),
                        _SkillBulletLinkPicker(
                          categoryId: category.id,
                          skill: skill,
                          bulletGroups: _bulletGroups,
                          onUpdateSkill: widget.onUpdateSkill,
                          expanded: _expandedSkillId == skill.id,
                          onToggleExpanded: () =>
                              _toggleSkillExpanded(skill.id),
                        ),
                      ],
                    ),
                  ),
                const VGap.tiny(),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () => widget.onAddSkill(category.id),
                    icon: Icon(
                      RemixIcons.add_line,
                      size: context.appIconSize.small,
                    ),
                    label: Text(context.l10n.vaultSkillsAddSkill),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One bullet-owning entity's heading plus its bullets — the common shape
/// [_SkillBulletLinkPicker] groups chips by, regardless of whether the
/// entity underneath is an experience, project, education entry, or
/// publication.
class _BulletGroup {
  const _BulletGroup(this.heading, this.bullets);

  final String heading;
  final List<CvBullet> bullets;
}

/// Collapsed by default — a skill can have a bullet linked under every
/// entity in the Vault, and showing every bullet as a chip for every skill
/// up front would make a well-stocked Vault scroll for miles. [expanded]/
/// [onToggleExpanded] are controlled by `_SkillsEditorPanelState`, which
/// keeps at most one of these open across the whole panel — see
/// `_SkillsEditorPanelState._expandedSkillId`'s doc comment for why this
/// can't just be this widget's own local state. This is the bulk-linking
/// direction (one skill, many bullets); linking one bullet to several
/// skills is primarily done from the bullet's own editor — see
/// `BulletListEditor`'s `_BulletSkillLinkPicker`.
class _SkillBulletLinkPicker extends StatefulWidget {
  const _SkillBulletLinkPicker({
    required this.categoryId,
    required this.skill,
    required this.bulletGroups,
    required this.onUpdateSkill,
    required this.expanded,
    required this.onToggleExpanded,
  });

  final String categoryId;
  final Skill skill;
  final List<_BulletGroup> bulletGroups;
  final void Function(String categoryId, Skill skill) onUpdateSkill;
  final bool expanded;
  final VoidCallback onToggleExpanded;

  @override
  State<_SkillBulletLinkPicker> createState() => _SkillBulletLinkPickerState();
}

class _SkillBulletLinkPickerState extends State<_SkillBulletLinkPicker> {
  /// Presentation state, not Vault data — same call as
  /// `_SkillsEditorPanelState._query`. A well-stocked Vault can easily
  /// have dozens of bullets across every experience/project/education/
  /// publication; without this, expanding a single skill dumps all of
  /// them on screen at once with no way to narrow down to the handful
  /// actually relevant to it. Kept local (unlike [_SkillBulletLinkPicker.
  /// expanded]) since a stale filter left over from a previous expansion
  /// is harmless — it's invisible until expanded again, and clearing it
  /// on every collapse would be extra bookkeeping for no visible benefit.
  String _query = '';

  List<CvBullet> _matchingBullets(_BulletGroup group) {
    if (_query.isEmpty) return group.bullets;
    return group.bullets
        .where((b) => stripCvMarkup(b.text).toLowerCase().contains(_query))
        .toList();
  }

  /// The linked bullets that still exist, resolved through
  /// [_SkillBulletLinkPicker.bulletGroups] rather than trusting
  /// `Skill.linkedBulletIds` to name only live bullets — deleting a bullet
  /// doesn't currently strip its id from the skills that referenced it, so
  /// the raw id count can over-report. Counting what actually resolves
  /// keeps the label honest and gives the collapsed summary its text.
  List<CvBullet> get _linkedBullets => [
    for (final group in widget.bulletGroups)
      for (final bullet in group.bullets)
        if (widget.skill.linkedBulletIds.contains(bullet.id)) bullet,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.bulletGroups.isEmpty) return const SizedBox.shrink();

    final linked = _linkedBullets;
    final groups = [
      for (final group in widget.bulletGroups)
        if (_matchingBullets(group) case final bullets when bullets.isNotEmpty)
          AppChipGroup(
            label: group.heading,
            items: [
              for (final bullet in bullets)
                AppChipGroupItem(
                  id: bullet.id,
                  label: _chipLabel(bullet),
                  selected: widget.skill.linkedBulletIds.contains(bullet.id),
                  tooltip: bullet.text,
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
    ];

    return LinkPickerShell(
      icon: RemixIcons.list_check_2,
      // Mirrors the bullet side's label exactly — see the reasoning on
      // `BulletListEditor`'s `_BulletSkillLinkPicker`.
      label: linked.isEmpty
          ? context.l10n.vaultSkillLinkToBullets
          : context.l10n.vaultSkillLinkedBullets(linked.length),
      summary: linked.isEmpty ? null : linked.map((b) => b.text).join(' · '),
      searchHint: context.l10n.vaultSkillSearchBullets,
      onQueryChanged: (value) =>
          setState(() => _query = value.trim().toLowerCase()),
      expanded: widget.expanded,
      onToggleExpanded: widget.onToggleExpanded,
      children: [
        if (groups.isNotEmpty)
          AppChipGroupSelector(groups: groups)
        else
          AppInlineEmptyMessage(context.l10n.vaultSkillNoBulletMatches),
      ],
    );
  }

  /// Bullet text is a full sentence; a chip is not. The full text stays
  /// reachable as the chip's tooltip, and the bullet's own editor is where
  /// it's meant to be read in full.
  static const _chipLabelMaxLength = 28;

  String _chipLabel(CvBullet bullet) => bullet.text.length > _chipLabelMaxLength
      ? '${bullet.text.substring(0, _chipLabelMaxLength)}…'
      : bullet.text;
}
