import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';
import 'analyzer_machine_ingestion_panel.dart';
import 'analyzer_xray_panel.dart';

/// The finished-analysis state: a short summary line, then a tabbed split
/// between the X-Ray overlay (findings + page, merged into one primary
/// view — see `docs/ats-xray-overlay-handover.md`'s "Next step" section)
/// and the Machine Ingestion panel (raw extracted text, a genuinely
/// different lens on the same document). The standalone findings-only tab
/// this used to have is gone: it's now `AnalyzerXrayPanel`'s rail.
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
            const TabBar(
              labelColor: kcPrimaryColor,
              unselectedLabelColor: kcLightGrey,
              indicatorColor: kcPrimaryColor,
              tabs: [
                Tab(text: 'X-Ray'),
                Tab(text: 'Machine Ingestion'),
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
