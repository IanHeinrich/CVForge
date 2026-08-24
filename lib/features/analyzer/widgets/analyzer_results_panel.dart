import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'analyzer_machine_ingestion_panel.dart';
import 'analyzer_xray_panel.dart';

/// The finished-analysis state: a short summary line, then a tabbed split
/// between the X-Ray overlay (findings + page, merged into one primary
/// view) and the Machine Ingestion panel (raw extracted text, a
/// genuinely different lens on the same document).
class AnalyzerResultsPanel extends StatelessWidget {
  const AnalyzerResultsPanel({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final result = viewModel.result!;

    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.paddingPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.analyzerResultsTitle,
                  style: context.appTypography.titleMedium,
                ),
                OutlinedButton(
                  onPressed: viewModel.reset,
                  child: Text(context.l10n.analyzerResultsAnalyzeAnother),
                ),
              ],
            ),
            const VGap.small(),
            Text(
              context.l10n.analyzerResultsExtractionSummary(
                result.info.pageCount,
                result.totalNodeCount,
              ),
              style: context.appTypography.bodySmall,
            ),
            const VGap.medium(),
            TabBar(
              tabs: [
                Tab(text: context.l10n.analyzerTabXray),
                Tab(text: context.l10n.analyzerTabMachineIngestion),
              ],
            ),
            const VGap.small(),
            Expanded(
              child: TabBarView(
                children: [
                  AnalyzerXrayPanel(viewModel: viewModel),
                  AnalyzerMachineIngestionPanel(viewModel: viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
