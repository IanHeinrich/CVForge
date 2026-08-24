import 'package:cv_forge/ui/common/l10n_extensions.dart';
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
      title: context.l10n.vaultSectionEducation,
      unselectedCount: viewModel.unselectedEducation.length,
      selectedCount: viewModel.selectedEducation.length,
      onAddAll: viewModel.addAllEducation,
      onRemoveAll: viewModel.removeAllEducation,
      items: [
        for (final entry in viewModel.education)
          SelectorItem(
            id: entry.id,
            title: viewModel.educationQualificationText(entry).isEmpty
                ? context.l10n.vaultUntitledQualification
                : viewModel.educationQualificationText(entry),
            subtitle: entry.institution,
            selected: viewModel.isEducationIncluded(entry.id),
            onToggle: () => viewModel.toggleEducation(entry),
            tailorables: [
              TailorableField(
                hasOverride: viewModel.hasEducationQualificationOverride(
                  entry.id,
                ),
                effectiveText: viewModel.educationQualificationText(entry),
                fieldLabel: context.l10n.studioFieldQualification,
                onChanged: (value) =>
                    viewModel.setEducationQualificationOverride(entry, value),
                onRevert: () =>
                    viewModel.revertEducationQualificationOverride(entry.id),
              ),
              TailorableField(
                hasOverride: viewModel.hasEducationGradeOverride(entry.id),
                effectiveText: viewModel.educationGradeText(entry),
                fieldLabel: context.l10n.studioFieldGrade,
                emptyMessage: context.l10n.studioNoGrade,
                onChanged: (value) =>
                    viewModel.setEducationGradeOverride(entry, value),
                onRevert: () =>
                    viewModel.revertEducationGradeOverride(entry.id),
              ),
              TailorableField(
                hasOverride: viewModel.hasEducationDetailsOverride(entry.id),
                effectiveText: viewModel.educationDetailsText(entry),
                fieldLabel: context.l10n.studioFieldDetails,
                emptyMessage: context.l10n.studioNoEducationDetails,
                onChanged: (value) =>
                    viewModel.setEducationDetailsOverride(entry, value),
                onRevert: () =>
                    viewModel.revertEducationDetailsOverride(entry.id),
              ),
            ],
          ),
      ],
    );
  }
}
