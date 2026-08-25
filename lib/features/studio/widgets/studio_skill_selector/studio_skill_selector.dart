import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chip_group_selector/app_chip_group_selector.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/l10n/model_labels.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_entry_field_row.dart';
import 'package:cv_forge/features/studio/widgets/studio_panel_heading.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';

/// Caps the filter field's width so it doesn't stretch to fill the panel
/// on wide monitors — matches `DraftsCardList`'s own search field.
const _filterFieldMaxWidth = 320.0;

/// Studio's skill picker — a filterable [AppChipGroupSelector] over
/// [StudioViewModel.skillCategories], preserving the category grouping
/// the document itself reinstates when it prints grouped skill lines.
class StudioSkillSelector extends StatefulWidget {
  const StudioSkillSelector({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  State<StudioSkillSelector> createState() => _StudioSkillSelectorState();
}

class _StudioSkillSelectorState extends State<StudioSkillSelector> {
  /// Presentation state, not draft data — same call as `_expandedIds`/
  /// `_editingTextIds` in `vault_item_selector_list.dart`. Filtering is a
  /// view over the selection, never a mutation of it, so a selected skill
  /// that scrolls out of view under a filter stays selected.
  final _filterController = TextEditingController();
  String _query = '';

  /// Whether the selector is showing each included skill as an editable
  /// row beneath its group. Off by default: picking skills is what this
  /// panel is for, and rewording one is the rare case — so it's a mode you
  /// ask for, not chrome hung off every chip.
  bool _renaming = false;

  /// Which skill, or which category name, currently has its rename editor
  /// open — one at a time, and presentation state like [_query]. A chip is
  /// a selection control, so renaming happens in a row below the group
  /// rather than inside the chip itself.
  String? _editingSkillId;
  String? _editingCategoryId;

  void _toggleRenaming() => setState(() {
    _renaming = !_renaming;
    _editingSkillId = null;
    _editingCategoryId = null;
  });

  void _editSkill(String? id) => setState(() {
    _editingSkillId = _editingSkillId == id ? null : id;
    _editingCategoryId = null;
  });

  void _editCategory(String? id) => setState(() {
    _editingCategoryId = _editingCategoryId == id ? null : id;
    _editingSkillId = null;
  });

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  /// What sits under [category]'s chips: its own open rename editor, or —
  /// while [_renaming] — one row per included skill in the group. Null
  /// when there's nothing to show, so an untouched group renders exactly
  /// the chips and nothing else.
  ///
  /// Rendered through `AppChipGroup.footer` so it stays attached to the
  /// group it belongs to while that widget stays stateless.
  Widget? _buildFooter(
    BuildContext context,
    StudioViewModel viewModel,
    SkillCategory category,
    List<Skill> skills,
  ) {
    if (_editingCategoryId == category.id) {
      return StudioEntryFieldRow(
        field: TailorableField(
          hasOverride: viewModel.hasSkillCategoryNameOverride(category.id),
          effectiveText: viewModel.skillCategoryNameText(category),
          vaultText: category.name,
          fieldLabel: context.l10n.studioFieldSkillCategory,
          onChanged: (value) =>
              viewModel.setSkillCategoryNameOverride(category, value),
          onRevert: () =>
              viewModel.revertSkillCategoryNameOverride(category.id),
        ),
        editing: true,
        onToggleEdit: () => _editCategory(null),
        editorMinLines: 1,
        editorMaxLines: 1,
      );
    }

    if (!_renaming) return null;

    // Only a skill that actually prints is worth rewording for this CV.
    final included = skills
        .where((s) => viewModel.isSkillIncluded(s.id))
        .toList();
    if (included.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final skill in included)
          StudioEntryFieldRow(
            key: ValueKey('skill_rename_${skill.id}'),
            field: TailorableField(
              hasOverride: viewModel.hasSkillLabelOverride(skill.id),
              effectiveText: viewModel.skillLabelText(skill),
              vaultText: skill.label,
              fieldLabel: context.l10n.studioFieldSkill,
              onChanged: (value) =>
                  viewModel.setSkillLabelOverride(skill, value),
              onRevert: () => viewModel.revertSkillLabelOverride(skill.id),
            ),
            editing: _editingSkillId == skill.id,
            onToggleEdit: () => _editSkill(skill.id),
            previewMaxLines: 1,
            editorMinLines: 1,
            editorMaxLines: 2,
          ),
      ],
    );
  }

  /// Skills within [category] matching the current filter — the category
  /// name itself is not matched against, so a query only ever surfaces the
  /// skills that actually contain it, never a whole category dragged along
  /// by an unrelated name match.
  List<Skill> _matchingSkills(SkillCategory category) {
    if (_query.isEmpty) return category.skills;
    return category.skills
        .where((s) => s.label.toLowerCase().contains(_query))
        .toList();
  }

  /// Null for a skill with no included evidence, so [AppChipGroupItem]
  /// skips rendering a tooltip at all for the common case rather than
  /// showing an empty or "proven by 0" one.
  String? _evidenceTooltip(
    BuildContext context,
    StudioViewModel viewModel,
    Skill skill,
  ) {
    final count = viewModel.evidenceCountFor(skill);
    if (count == 0) return null;
    // Same "Linked to N bullets" phrasing the Vault's own pickers use,
    // narrowed to the bullets this CV actually includes — which is the
    // only sense in which a link is evidence *here*.
    return context.l10n.studioSkillsEvidenceCount(count);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final categories = viewModel.skillCategories;
    final totalCount = categories.fold(0, (sum, c) => sum + c.skills.length);
    final selectedCount = totalCount - viewModel.unselectedSkills.length;
    final evidencedCount = viewModel.unselectedEvidencedSkills.length;

    return Padding(
      padding: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: StudioPanelHeading(context.l10n.studioSkillsTitle),
              ),
              Text(
                context.l10n.studioSkillsSelectedCount(
                  selectedCount,
                  totalCount,
                ),
                style: context.appTypography.caption,
              ),
            ],
          ),
          const VGap.tiny(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _filterFieldMaxWidth),
            child: TextField(
              controller: _filterController,
              decoration: InputDecoration(
                isDense: true,
                hintText: context.l10n.studioSkillsFilter,
                prefixIcon: Icon(
                  RemixIcons.search_line,
                  size: context.appIconSize.medium,
                ),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          const VGap.tiny(),
          Row(
            children: [
              Tooltip(
                message: evidencedCount > 0
                    ? context.l10n.studioSkillsSelectEvidencedTooltip
                    : viewModel.hasAnyLinkedSkills
                    ? context.l10n.studioSkillsNoNewEvidenced
                    : context.l10n.studioSkillsNoLinks,
                child: TextButton.icon(
                  // Adds only — see `StudioViewModel.selectEvidencedSkills`'s
                  // doc comment. Disabled rather than hidden at zero so the
                  // control doesn't jump around as bullets are (de)selected.
                  onPressed: evidencedCount == 0
                      ? null
                      : viewModel.selectEvidencedSkills,
                  icon: Icon(RemixIcons.shield_check_line, size: 16),
                  label: Text(
                    context.l10n.studioSkillsSelectEvidenced(evidencedCount),
                  ),
                ),
              ),
              const Spacer(),
              // One control for the whole panel rather than one per group
              // — the mode is about what a row *is*, not about which
              // category you're in.
              TextButton.icon(
                onPressed: selectedCount == 0 ? null : _toggleRenaming,
                icon: Icon(
                  _renaming ? RemixIcons.check_line : RemixIcons.edit_line,
                  size: 16,
                ),
                label: Text(
                  _renaming
                      ? context.l10n.studioSkillsRenameDone
                      : context.l10n.studioSkillsRename,
                ),
              ),
            ],
          ),
          const VGap.tiny(),
          AppChipGroupSelector(
            groups: [
              for (final category in categories)
                if (_matchingSkills(category) case final skills
                    when skills.isNotEmpty)
                  AppChipGroup(
                    label: viewModel.skillCategoryNameText(category).isEmpty
                        ? category.displayName(context.l10n)
                        : viewModel.skillCategoryNameText(category),
                    onEditLabel: () => _editCategory(category.id),
                    footer: _buildFooter(context, viewModel, category, skills),
                    items: [
                      for (final skill in skills)
                        AppChipGroupItem(
                          id: skill.id,
                          label: viewModel.skillLabelText(skill),
                          selected: viewModel.isSkillIncluded(skill.id),
                          onToggle: (_) => viewModel.toggleSkill(skill),
                          tooltip: _evidenceTooltip(context, viewModel, skill),
                        ),
                    ],
                    // Hidden while filtering — it'd otherwise add/remove
                    // the whole category, not just the chips shown.
                    onSelectAll: _query.isEmpty
                        ? () => viewModel.addAllSkillsInCategory(category)
                        : null,
                    onSelectNone: _query.isEmpty
                        ? () => viewModel.removeAllSkillsInCategory(category)
                        : null,
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
