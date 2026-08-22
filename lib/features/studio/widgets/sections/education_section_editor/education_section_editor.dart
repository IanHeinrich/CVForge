import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/tailorable_field.dart';
import 'package:cv_forge/features/studio/widgets/vault_item_selector_list.dart';

/// The [CvSectionType.education] editor.
class EducationSectionEditor extends StatelessWidget {
  const EducationSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return VaultItemSelectorList(
      title: 'Education',
      unselectedCount: viewModel.unselectedEducation.length,
      selectedCount: viewModel.selectedEducation.length,
      onAddAll: viewModel.addAllEducation,
      onRemoveAll: viewModel.removeAllEducation,
      items: [
        for (final entry in viewModel.education)
          SelectorItem(
            id: entry.id,
            title: entry.qualification.isEmpty
                ? 'Untitled qualification'
                : entry.qualification,
            subtitle: entry.institution,
            selected: viewModel.isEducationIncluded(entry.id),
            onToggle: () => viewModel.toggleEducation(entry),
            tailorable: TailorableField(
              hasOverride: viewModel.hasEducationDetailsOverride(entry.id),
              effectiveText: viewModel.educationDetailsText(entry),
              emptyMessage: 'No details in your Vault yet.',
              onChanged: (value) =>
                  viewModel.setEducationDetailsOverride(entry, value),
              onRevert: () =>
                  viewModel.revertEducationDetailsOverride(entry.id),
            ),
          ),
      ],
    );
  }
}
