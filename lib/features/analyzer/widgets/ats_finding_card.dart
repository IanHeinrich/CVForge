import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:cv_forge/models/ats/ats_finding.dart';

/// One [AtsFinding], in the same block-card frame `BackupSettingsCard`/
/// `StudioFieldOverrideCard` use — dark container, [context.appRadius.
/// medium] — rather than inventing a new card shape for this feature.
///
/// Severity is shown by icon shape, not a dedicated colour scale: only
/// [AtsFindingSeverity.critical] gets [kcErrorColor] (matching
/// `PersistErrorBanner`'s existing critical-error language); warning and
/// info both read as neutral chrome text, differentiated by icon alone.
/// `kcPrimaryColor` is reserved for chrome selection state, so it isn't
/// repurposed here as a second "warning" tone.
class AtsFindingCard extends StatelessWidget {
  const AtsFindingCard({super.key, required this.finding});

  final AtsFinding finding;

  @override
  Widget build(BuildContext context) {
    final icon = switch (finding.severity) {
      AtsFindingSeverity.critical => RemixIcons.error_warning_fill,
      AtsFindingSeverity.warning => RemixIcons.alert_fill,
      AtsFindingSeverity.info => RemixIcons.information_fill,
    };
    final iconColor = finding.severity == AtsFindingSeverity.critical
        ? kcErrorColor
        : kcLightGrey;

    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      decoration: BoxDecoration(
        color: kcDarkGreyColor,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
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
                Text(finding.title, style: context.appTypography.titleSmall),
                const VGap.tiny(),
                Text(finding.message, style: context.appTypography.bodySmall),
                if (finding.pageIndex != null) ...[
                  const VGap.tiny(),
                  Text(
                    'Page ${finding.pageIndex! + 1}',
                    style: context.appTypography.caption.copyWith(
                      color: kcLightGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
