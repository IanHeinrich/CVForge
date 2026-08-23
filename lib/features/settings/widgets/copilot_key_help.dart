import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';

/// The "How do I get an API key?" disclosure inside [CopilotSettingsCard] —
/// per-provider setup steps, real links into that provider's console, and
/// the spend advice a BYOK app owes anyone about to paste a billable
/// credential into it.
///
/// Collapsed by default and expanding *in place* rather than opening a
/// dialog, deliberately: this is reference material followed while typing
/// into the key field directly below it, and a modal would have to be
/// dismissed to reach that field. The existing dialogs in this app are
/// decisions (confirm delete) and pickers (template gallery), which is a
/// different job.
class CopilotKeyHelp extends StatelessWidget {
  const CopilotKeyHelp({super.key, required this.provider});

  final LlmProvider provider;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // ExpansionTile draws its own top/bottom dividers from the ambient
      // theme; the card already has its own separation, so a rule here
      // just reads as a stray line across the middle of a form.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        // Named per provider rather than a generic "How do I get a key?" —
        // the card's provider dropdown sits directly above this, so the
        // help must visibly answer for whichever provider is selected.
        title: Text(
          'How do I get a ${provider.displayName} API key?',
          style: context.appTypography.bodySmall,
        ),
        leading: Icon(
          RemixIcons.question_line,
          size: context.appIconSize.small,
          color: kcLightGrey,
        ),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.only(
          bottom: context.appSpacing.paddingCompact,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (index, step) in provider.apiKeySteps.indexed)
            Padding(
              padding: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
              child: _NumberedStep(number: index + 1, text: step),
            ),
          const VGap.small(),
          _LinkButton(
            icon: RemixIcons.external_link_line,
            label: 'Open ${provider.displayName} key settings',
            url: provider.apiKeyConsoleUrl,
          ),
          const VGap.medium(),
          const _SpendWarning(),
          const VGap.small(),
          _LinkButton(
            icon: RemixIcons.wallet_line,
            label: 'Open billing & spend limits',
            url: provider.billingConsoleUrl,
          ),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          // A fixed gutter so multi-line steps wrap flush with each other
          // rather than under their own number.
          width: context.appSpacing.paddingPanel,
          child: Text(
            '$number.',
            style: context.appTypography.bodySmall.copyWith(
              color: kcLightGrey,
            ),
          ),
        ),
        Expanded(
          child: Text(text, style: context.appTypography.bodySmall),
        ),
      ],
    );
  }
}

/// The spend advice, stated once for every provider rather than repeated
/// into each one's own step list — see [LlmProvider.apiKeySteps]' doc
/// comment for why this lives here and not there.
class _SpendWarning extends StatelessWidget {
  const _SpendWarning();

  static const _points = [
    'Turn OFF auto top-up / auto-reload. Left on, a runaway or leaked key '
        'can recharge itself indefinitely.',
    'Set a hard monthly spend cap, as low as you are willing to pay.',
    'Use a key created only for CVForge, so you can revoke it without '
        'breaking anything else.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      decoration: BoxDecoration(
        color: kcWarningColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(context.appRadius.small),
        border: Border.all(color: kcWarningColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                RemixIcons.error_warning_line,
                size: context.appIconSize.small,
                color: kcWarningColor,
              ),
              const HGap.small(),
              Text(
                'Protect yourself from surprise bills',
                style: context.appTypography.bodySmall.copyWith(
                  color: kcWarningColor,
                ),
              ),
            ],
          ),
          const VGap.tiny(),
          for (final point in _points)
            Padding(
              padding: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: context.appTypography.bodySmall),
                  Expanded(
                    child: Text(
                      point,
                      style: context.appTypography.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens [url] in a new tab. Failure is swallowed rather than surfaced:
/// the only thing that can go wrong here is the browser refusing the
/// navigation, and an error banner on a *help* panel would be noise on top
/// of a user who can still read the address in the link's own tooltip.
class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final Uri url;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: url.toString(),
      child: OutlinedButton.icon(
        onPressed: () => launchUrl(url, mode: LaunchMode.externalApplication),
        icon: Icon(icon, size: context.appIconSize.small),
        label: Text(label),
      ),
    );
  }
}
