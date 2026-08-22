import 'package:cv_forge/models/vault/skill_category.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_chip_group_selector/app_chip_group_selector.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_panel_heading.dart';

/// Studio's skill picker — a filterable [AppChipGroupSelector] over
/// [StudioViewModel.skillCategories], replacing the flattened checkbox
/// list `VaultItemSelectorList` used to render (which discarded the
/// category grouping the document itself reinstates when it prints
/// grouped skill lines). See `docs/ux/7.2-skills-chips.md`.
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

  /// A category is visible whenever its own name matches, or any one of
  /// its skills' labels does — and once visible, every skill in it renders
  /// (never a partial category), so typing "cloud" surfaces the whole
  /// Cloud category rather than just the skills that happen to contain
  /// the word. That also keeps this group's "Add all (N)" count always
  /// equal to what tapping it actually adds — `addAllSkillsInCategory`
  /// operates on the whole category, never a filtered subset of it.
  bool _categoryVisible(SkillCategory category) {
    if (_query.isEmpty) return true;
    if (category.name.toLowerCase().contains(_query)) return true;
    return category.skills.any((s) => s.label.toLowerCase().contains(_query));
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
          TextField(
            controller: _filterController,
            decoration: const InputDecoration(
              isDense: true,
              hintText: 'Filter skills…',
              prefixIcon: Icon(RemixIcons.search_line, size: 18),
            ),
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
          ),
          const VGap.tiny(),
          Align(
            alignment: Alignment.centerLeft,
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
          const VGap.tiny(),
          AppChipGroupSelector(
            groups: [
              for (final category in categories)
                if (_categoryVisible(category))
                  AppChipGroup(
                    label: category.name,
                    items: [
                      for (final skill in category.skills)
                        AppChipGroupItem(
                          id: skill.id,
                          label: skill.label,
                          selected: viewModel.isSkillIncluded(skill.id),
                          onToggle: (_) => viewModel.toggleSkill(skill),
                        ),
                    ],
                    onSelectAll: () =>
                        viewModel.addAllSkillsInCategory(category),
                    onSelectNone: () =>
                        viewModel.removeAllSkillsInCategory(category),
                  ),
            ],
          ),
        ],
      ),
    );
  }
}
