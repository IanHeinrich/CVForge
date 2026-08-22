import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_field_override_card.dart';

/// The [CvSectionType.references] editor.
class ReferencesSectionEditor extends StatelessWidget {
  const ReferencesSectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return StudioFieldOverrideCard(
      key: const ValueKey('studio_references_editor'),
      label: 'References',
      vaultValue: viewModel.vaultReferencesNote,
      hasOverride: viewModel.hasReferencesOverride,
      effectiveValue: viewModel.referencesText,
      onChanged: viewModel.setReferencesOverride,
      onRevert: viewModel.revertReferencesToVault,
      emptyVaultMessage: 'No references note in your Vault yet.',
    );
  }
}
