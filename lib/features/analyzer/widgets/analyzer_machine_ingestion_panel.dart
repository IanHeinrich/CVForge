import 'package:cv_forge/ui/common/app_colors.dart';
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
/// No coordinate math and no painter: this is the warm-up piece from
/// `docs/ats-xray-overlay-handover.md` §6, cheap to ship ahead of the X-Ray
/// overlay because it needs none of that overlay's geometry work.
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

    final byPage = <int, List<AtsTextNode>>{};
    for (final node in nodes) {
      byPage.putIfAbsent(node.pageIndex, () => []).add(node);
    }
    final pageIndices = byPage.keys.toList()..sort();

    // One flat item list (page header or node row) rather than a nested
    // ListView-per-page — the spike measured up to ~400 nodes on a single
    // dense page, so this stays a single lazily-built list rather than
    // eagerly building every row up front.
    final items = <_IngestionItem>[
      for (final pageIndex in pageIndices) ...[
        _IngestionItem.pageHeader(pageIndex),
        for (final node in byPage[pageIndex]!) _IngestionItem.node(node),
      ],
    ];

    return ListView.builder(
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return switch (item) {
          _PageHeaderItem(:final pageIndex) => Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : context.appSpacing.gapMedium,
              bottom: context.appSpacing.gapSmall,
            ),
            child: Text(
              'Page ${pageIndex + 1}',
              style: context.appTypography.titleSmall,
            ),
          ),
          _NodeItem(:final node) => Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
            padding: EdgeInsets.symmetric(
              horizontal: context.appSpacing.paddingCompact,
              vertical: context.appSpacing.paddingHairline,
            ),
            decoration: BoxDecoration(
              color: kcDarkGreyColor,
              borderRadius: BorderRadius.circular(context.appRadius.medium),
            ),
            child: Text(
              node.str.isEmpty ? '·' : node.str,
              style: context.appTypography.bodySmall,
            ),
          ),
        };
      },
    );
  }
}

sealed class _IngestionItem {
  const _IngestionItem();

  const factory _IngestionItem.pageHeader(int pageIndex) = _PageHeaderItem;
  const factory _IngestionItem.node(AtsTextNode node) = _NodeItem;
}

final class _PageHeaderItem extends _IngestionItem {
  const _PageHeaderItem(this.pageIndex);
  final int pageIndex;
}

final class _NodeItem extends _IngestionItem {
  const _NodeItem(this.node);
  final AtsTextNode node;
}
