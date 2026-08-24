import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_field_override_card.dart';

/// The [CvSectionType.summary] editor.
///
/// The headline used to live here too. It has its own row and its own
/// editor now — see [HeadlineEditor] — because the two are independent
/// and pairing them meant a CV with a headline and no summary could not
/// reach the headline at all.
class SummarySectionEditor extends StatelessWidget {
  const SummarySectionEditor({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioFieldOverrideCard(
          key: const ValueKey('studio_summary_editor'),
          label: context.l10n.vaultBasicsSummary,
          vaultValue: viewModel.vaultSummary,
          hasOverride: viewModel.hasTailoredSummary,
          effectiveValue: viewModel.summaryText,
          onChanged: viewModel.setTailoredSummary,
          onRevert: viewModel.revertSummaryToVault,
          emptyVaultMessage: context.l10n.studioNoSummary,
        ),
      ],
    );
  }
}
