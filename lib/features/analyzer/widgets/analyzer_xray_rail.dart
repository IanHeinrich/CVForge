import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_finding_card.dart';

/// The X-Ray overlay's primary findings list.
///
/// Two groups, not one flat list: [findings] with evidence are click-to-
/// frame; document-level findings ([AtsFindingCategory.noTextLayer]
/// (document-wide), [AtsFindingCategory.missingHeadings],
/// [AtsFindingCategory.contactInfo]) have no coordinates by definition, so
/// they're shown but not tappable — present, not hidden, but visibly a
/// different kind of entry than "click to see where".
class AnalyzerXrayRail extends StatelessWidget {
  const AnalyzerXrayRail({
    super.key,
    required this.findings,
    required this.selected,
    required this.stepIndex,
    required this.onSelect,
    required this.onStep,
  });

  final List<AtsFinding> findings;
  final AtsFinding? selected;
  final int stepIndex;
  final ValueChanged<AtsFinding> onSelect;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) {
      return AppEmptyState(
        icon: RemixIcons.checkbox_circle_line,
        title: context.l10n.analyzerXrayNoIssuesTitle,
        message: context.l10n.analyzerXrayNoIssuesBody,
      );
    }

    final located = findings.where((f) => f.evidence.isNotEmpty).toList();
    final documentLevel = findings.where((f) => f.evidence.isEmpty).toList();

    return ListView(
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      children: [
        for (final finding in located) ...[
          AtsFindingCard(
            finding: finding,
            selected: finding == selected,
            stepIndex: stepIndex,
            onTap: () => onSelect(finding),
            onStep: onStep,
          ),
          const VGap.small(),
        ],
        if (documentLevel.isNotEmpty) ...[
          if (located.isNotEmpty) const VGap.medium(),
          Text(
            context.l10n.analyzerXrayDocumentLevel,
            style: context.appTypography.caption,
          ),
          const VGap.small(),
          for (final finding in documentLevel) ...[
            AtsFindingCard(finding: finding),
            const VGap.small(),
          ],
        ],
      ],
    );
  }
}
