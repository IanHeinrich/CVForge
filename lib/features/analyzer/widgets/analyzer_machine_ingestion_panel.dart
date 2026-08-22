import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/ats/ats_text_node.dart';
import 'package:cv_forge/features/analyzer/views/analyzer/analyzer_viewmodel.dart';

/// Exactly what `PdfExtractionService` handed the analyzer — every
/// [AtsTextNode.str], in `pdf.js`'s own extraction order, grouped by page.
/// No coordinate math and no painter: a genuinely different lens on the
/// same document from the X-Ray overlay.
class AnalyzerMachineIngestionPanel extends StatelessWidget {
  const AnalyzerMachineIngestionPanel({super.key, required this.viewModel});

  final AnalyzerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final nodes = viewModel.extractedNodes;

    if (nodes.isEmpty) {
      return const AppEmptyState(
        icon: RemixIcons.file_list_line,
        title: 'No text extracted',
        message: "This PDF didn't yield any extractable text runs.",
      );
    }

    // One flat item list (a page-index marker or a node) rather than a
    // nested ListView-per-page — a dense page can carry hundreds of
    // nodes, so this stays a single lazily-built list rather than
    // eagerly building every row up front. `nodes` already arrives
    // page-contiguous (the extraction loop is page-by-page), so a page
    // boundary is just "the previous node's page differs" — no grouping
    // map needed.
    final items = <Object>[
      for (var i = 0; i < nodes.length; i++) ...[
        if (i == 0 || nodes[i].pageIndex != nodes[i - 1].pageIndex)
          nodes[i].pageIndex,
        nodes[i],
      ],
    ];

    return ListView.builder(
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return switch (items[index]) {
          final int pageIndex => Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : context.appSpacing.gapMedium,
              bottom: context.appSpacing.gapSmall,
            ),
            child: Text(
              'Page ${pageIndex + 1}',
              style: context.appTypography.titleSmall,
            ),
          ),
          final AtsTextNode node => Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
            padding: EdgeInsets.symmetric(
              horizontal: context.appSpacing.paddingCompact,
              vertical: context.appSpacing.paddingHairline,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
            ),
            child: Text(node.str, style: context.appTypography.bodySmall),
          ),
          final item => throw StateError('Unexpected item type: $item'),
        };
      },
    );
  }
}
