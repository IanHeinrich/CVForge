import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_field_override_card.dart';

/// The headline editor — the line under the name, e.g. "Senior Software
/// Engineer".
///
/// Its own editor rather than a card inside the summary's, because the two
/// are independent: the headline prints in the name block and the summary
/// is a section, either can be shown without the other, and while they
/// shared an editor a CV with a headline and no summary could not reach
/// the headline at all. It is still not a [CvSectionType] — see
/// [StudioViewModel.isHeadlineOpen] for why.
class HeadlineEditor extends StatelessWidget {
  const HeadlineEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioFieldOverrideCard(
          key: const ValueKey('studio_headline_editor'),
          label: context.l10n.studioSectionHeadline,
          vaultValue: viewModel.vaultHeadline,
          hasOverride: viewModel.hasHeadlineOverride,
          effectiveValue: viewModel.headlineText,
          onChanged: viewModel.setHeadlineOverride,
          onRevert: viewModel.revertHeadlineToVault,
          emptyVaultMessage: context.l10n.studioNoHeadline,
        ),
      ],
    );
  }
}
