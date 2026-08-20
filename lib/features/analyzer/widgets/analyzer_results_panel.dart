import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'ats_finding_card.dart';

/// The finished-analysis state: a short summary line plus every finding,
/// most-severe first (already sorted by `AtsAnalyzerService`).
class AnalyzerResultsPanel extends StatelessWidget {
  const AnalyzerResultsPanel({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final result = viewModel.result!;

    return Padding(
      padding: EdgeInsets.all(context.appSpacing.paddingPage),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Results', style: context.appTypography.titleMedium),
              OutlinedButton(
                onPressed: viewModel.reset,
                child: const Text('Analyze another file'),
              ),
            ],
          ),
          const VGap.small(),
          Text(
            '${result.info.pageCount} page(s), ${result.totalNodeCount} '
            'text run(s) extracted.',
            style: context.appTypography.bodySmall,
          ),
          const VGap.medium(),
          Expanded(
            child: result.findings.isEmpty
                ? const AppEmptyState(
                    icon: RemixIcons.checkbox_circle_line,
                    title: 'No issues found',
                    message:
                        'Nothing in this PDF matched a known ATS parsing '
                        'problem.',
                  )
                : ListView.separated(
                    itemCount: result.findings.length,
                    separatorBuilder: (_, _) => const VGap.small(),
                    itemBuilder: (_, index) =>
                        AtsFindingCard(finding: result.findings[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
