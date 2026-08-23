import 'package:cv_forge/models/vault/skill.dart';
import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chip_group_selector/app_chip_group_selector.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_panel_heading.dart';

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

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
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
  String? _evidenceTooltip(StudioViewModel viewModel, Skill skill) {
    final count = viewModel.evidenceCountFor(skill);
    if (count == 0) return null;
    // Same "Linked to N bullets" phrasing the Vault's own pickers use,
    // narrowed to the bullets this CV actually includes — which is the
    // only sense in which a link is evidence *here*.
    return 'Linked to $count bullet${count == 1 ? '' : 's'} in this CV';
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
              const Expanded(child: StudioPanelHeading('Skills')),
              Text(
                '$selectedCount of $totalCount selected',
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
                hintText: 'Filter skills…',
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
          Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: evidencedCount > 0
                  ? 'Selects every skill linked to a bullet already '
                        'included in this CV'
                  : viewModel.hasAnyLinkedSkills
                  ? 'No new evidenced skills to add — every skill linked '
                        'to an included bullet is already selected'
                  : 'Link skills to bullets in the Vault to use this',
              child: TextButton.icon(
                // Adds only — see `StudioViewModel.selectEvidencedSkills`'s
                // doc comment. Disabled rather than hidden at zero so the
                // control doesn't jump around as bullets are (de)selected.
                onPressed: evidencedCount == 0
                    ? null
                    : viewModel.selectEvidencedSkills,
                icon: const Icon(RemixIcons.shield_check_line, size: 16),
                label: Text('Select $evidencedCount evidenced skills'),
              ),
            ),
          ),
          const VGap.tiny(),
          AppChipGroupSelector(
            groups: [
              for (final category in categories)
                if (_matchingSkills(category) case final skills
                    when skills.isNotEmpty)
                  AppChipGroup(
                    label: category.displayName,
                    items: [
                      for (final skill in skills)
                        AppChipGroupItem(
                          id: skill.id,
                          label: skill.label,
                          selected: viewModel.isSkillIncluded(skill.id),
                          onToggle: (_) => viewModel.toggleSkill(skill),
                          tooltip: _evidenceTooltip(viewModel, skill),
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
