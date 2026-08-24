import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/features/studio/widgets/studio_field_override_card.dart';

/// The [CvSectionType.summary] editor. Headline has no [CvSectionType] of
/// its own — it prints in the page header, not a section — so it lives
/// here alongside the summary rather than inventing a fake section for it.
class SummarySectionEditor extends StatelessWidget {
  const SummarySectionEditor({super.key, required this.viewModel});

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
