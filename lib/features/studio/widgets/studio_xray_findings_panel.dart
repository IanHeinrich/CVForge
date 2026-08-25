import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/features/studio/views/studio/studio_viewmodel.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_empty_state.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_finding_card.dart';
import 'package:cv_forge/ui/widgets/common/ats_xray/ats_finding_severity_style.dart';

/// What the ATS check found, taking over the editor column while the
/// X-Ray is on.
///
/// It replaces the section editor rather than sitting above the pages,
/// because a finding needs room its old home could not give it without
/// eating the very page it describes: the counts were legible squeezed
/// into a strip, but the counts alone never said what was wrong. This
/// column is already the widest thing on screen that is not the document.
///
/// Reads [StudioViewModel.xrayResult] rather than computing anything —
/// `StudioXrayPane` performs the render this is derived from and reports
/// it up, so the boxes on the page and the list here always describe one
/// pass.
class StudioXrayFindingsPanel extends StatelessWidget {
  const StudioXrayFindingsPanel({super.key, required this.viewModel});

  final StudioViewModel viewModel;

  int _count(List<AtsFinding> findings, AtsFindingSeverity severity) =>
      findings.where((f) => f.severity == severity).length;

  @override
  Widget build(BuildContext context) {
    final result = viewModel.xrayResult;

    // Null covers both "the first pass is still running" and "an edit
    // invalidated the last one" — the same message is honest for each,
    // and the page beside it is already dimmed to say which.
    if (result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const VGap.small(),
            Text(
              context.l10n.studioXrayAnalyzing,
              style: context.appTypography.bodySmall,
            ),
          ],
        ),
      );
    }

    final findings = result.findings;
    if (findings.isEmpty) {
      return AppEmptyState(
        icon: RemixIcons.shield_check_line,
        title: context.l10n.studioXrayNoIssuesTitle,
        message: context.l10n.studioXrayNoIssues,
        messageMaxWidth: 420,
      );
    }

    final critical = _count(findings, AtsFindingSeverity.critical);
    final warning = _count(findings, AtsFindingSeverity.warning);
    final info = _count(findings, AtsFindingSeverity.info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpacing.paddingPanel,
            context.appSpacing.paddingPanel,
            context.appSpacing.paddingPanel,
            context.appSpacing.paddingTight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.studioXrayFindingsTitle,
                style: context.appTypography.titleSmall,
              ),
              const VGap.tiny(),
              Wrap(
                spacing: context.appSpacing.gapSmall,
                runSpacing: context.appSpacing.gapSmall,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (critical > 0)
                    _SeverityChip(
                      severity: AtsFindingSeverity.critical,
                      label: context.l10n.studioXrayCriticalCount(critical),
                    ),
                  if (warning > 0)
                    _SeverityChip(
                      severity: AtsFindingSeverity.warning,
                      label: context.l10n.studioXrayWarningCount(warning),
                    ),
                  if (info > 0)
                    _SeverityChip(
                      severity: AtsFindingSeverity.info,
                      label: context.l10n.studioXrayInfoCount(info),
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              context.appSpacing.paddingPanel,
              0,
              context.appSpacing.paddingPanel,
              context.appSpacing.paddingPanel,
            ),
            itemCount: findings.length,
            separatorBuilder: (_, _) => const VGap.small(),
            // No onTap: tapping a card in the Analyzer frames its evidence
            // with a camera this pane has not got. A card that looks
            // tappable and does nothing is worse than one that plainly
            // is not.
            itemBuilder: (context, index) =>
                AtsFindingCard(finding: findings[index]),
          ),
        ),
      ],
    );
  }
}

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({required this.severity, required this.label});

  final AtsFindingSeverity severity;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = severity.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.appSpacing.paddingTight,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(context.appRadius.large),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(severity.icon, size: context.appIconSize.small, color: color),
          const HGap.tiny(),
          Text(label, style: context.appTypography.caption),
        ],
      ),
    );
  }
}
