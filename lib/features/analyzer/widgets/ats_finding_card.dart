import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/ats/ats_finding.dart';
import 'ats_finding_severity_style.dart';

/// One [AtsFinding], in the same block-card frame `BackupSettingsCard`
/// uses — dark container, [context.appRadius.medium] — rather than
/// inventing a new card shape for this feature.
///
/// `colorScheme.primary` is reserved for chrome selection state, so it isn't
/// repurposed here as a fourth severity tone — [selected] uses it anyway,
/// deliberately: this is the one place in the analyzer feature where
/// "chrome selection state" and "this card is selected" are the same
/// thing.
///
/// Doubles as the X-Ray overlay's findings rail entry: [onTap] wires
/// click-to-frame, and a finding with more than one [AtsFinding.evidence]
/// location gets step controls once [selected] — see `AnalyzerXrayPanel`.
class AtsFindingCard extends StatelessWidget {
  const AtsFindingCard({
    super.key,
    required this.finding,
    this.selected = false,
    this.onTap,
    this.stepIndex = 0,
    this.onStep,
  });

  final AtsFinding finding;

  /// Whether this is the X-Ray overlay's currently-framed finding.
  final bool selected;

  /// `null` for a document-level finding with no evidence to jump to —
  /// the card renders identically but isn't tappable (a non-clickable
  /// group, not hidden).
  final VoidCallback? onTap;

  /// Which evidence location is currently framed, when [selected] and
  /// [AtsFinding.evidence] has more than one entry.
  final int stepIndex;

  /// Called with the new step index when the step controls are used.
  final ValueChanged<int>? onStep;

  @override
  Widget build(BuildContext context) {
    final icon = finding.severity.icon;
    final iconColor = finding.severity.color;
    final radius = BorderRadius.circular(context.appRadius.medium);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: EdgeInsets.all(context.appSpacing.paddingCompact),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: selected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const HGap.small(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.title,
                      style: context.appTypography.titleSmall,
                    ),
                    const VGap.tiny(),
                    Text(
                      finding.message,
                      style: context.appTypography.bodySmall,
                    ),
                    if (_locationLabel case final label?) ...[
                      const VGap.tiny(),
                      Text(
                        label,
                        style: context.appTypography.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (selected && finding.evidence.length > 1) ...[
                      const VGap.tiny(),
                      _StepControls(
                        stepIndex: stepIndex,
                        total: finding.evidence.length,
                        onStep: onStep,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Evidence-derived when there's evidence to describe (multiple
  /// locations may span multiple pages, which [AtsFinding.pageIndex] alone
  /// can't express); falls back to [AtsFinding.pageIndex] for a
  /// document-level per-page finding ([AtsFindingCategory.noTextLayer])
  /// that has no node evidence by definition but is still page-anchored.
  String? get _locationLabel {
    if (finding.evidence.isEmpty) {
      return finding.pageIndex != null
          ? 'Page ${finding.pageIndex! + 1}'
          : null;
    }
    final pages = finding.evidence.map((e) => e.pageIndex).toSet().toList()
      ..sort();
    final count = finding.evidence.length;
    if (pages.length == 1) {
      return count == 1
          ? 'Page ${pages.single + 1}'
          : '$count locations on page ${pages.single + 1}';
    }
    return '$count locations across ${pages.length} pages';
  }
}

class _StepControls extends StatelessWidget {
  const _StepControls({
    required this.stepIndex,
    required this.total,
    required this.onStep,
  });

  final int stepIndex;
  final int total;
  final ValueChanged<int>? onStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            RemixIcons.arrow_left_s_line,
            size: context.appIconSize.medium,
          ),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: stepIndex > 0 ? () => onStep?.call(stepIndex - 1) : null,
        ),
        Text(
          '${stepIndex + 1} of $total',
          style: context.appTypography.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        IconButton(
          icon: Icon(
            RemixIcons.arrow_right_s_line,
            size: context.appIconSize.medium,
          ),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: stepIndex < total - 1
              ? () => onStep?.call(stepIndex + 1)
              : null,
        ),
      ],
    );
  }
}
