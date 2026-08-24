import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cv_forge/services/llm/llm_provider.dart';
import 'package:cv_forge/ui/common/tokens/app_icon_size.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_warning_surface.dart';

/// The "How do I get an API key?" disclosure inside [AiAssistantSettingsCard] —
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
class AiAssistantKeyHelp extends StatelessWidget {
  const AiAssistantKeyHelp({super.key, required this.provider});

  final LlmProvider provider;

  @override
  Widget build(BuildContext context) {
    return Theme(
      // ExpansionTile draws its own top/bottom dividers from the ambient
      // theme; the card already has its own separation, so a rule here
      // just reads as a stray line across the middle of a form.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      // ExpansionTile is a ListTile underneath, and a ListTile paints its
      // ink splash onto the nearest Material *ancestor* — which here is
      // above the card's own decorated background, so the ripple would be
      // painted behind that background and never seen. Flutter asserts on
      // exactly this. Its own suggested fix: give the tile a Material of
      // its own, transparent so the card's colour still shows through.
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          // Named per provider rather than a generic "How do I get a key?" —
          // the card's provider dropdown sits directly above this, so the
          // help must visibly answer for whichever provider is selected.
          title: Text(
            context.l10n.settingsAiHelpTitle(provider.displayName),
            style: context.appTypography.bodySmall,
          ),
          leading: Icon(
            RemixIcons.question_line,
            size: context.appIconSize.small,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              label: context.l10n.settingsAiHelpOpenKeySettings(
                provider.displayName,
              ),
              url: provider.apiKeyConsoleUrl,
            ),
            const VGap.medium(),
            const _SpendWarning(),
            const VGap.small(),
            _LinkButton(
              icon: RemixIcons.wallet_line,
              label: context.l10n.settingsAiHelpOpenBilling,
              url: provider.billingConsoleUrl,
            ),
          ],
        ),
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
            context.l10n.settingsAiHelpStepNumber(number),
            style: context.appTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(text, style: context.appTypography.bodySmall)),
      ],
    );
  }
}

/// The spend advice, stated once for every provider rather than repeated
/// into each one's own step list — see [LlmProvider.apiKeySteps]' doc
/// comment for why this lives here and not there.
class _SpendWarning extends StatelessWidget {
  const _SpendWarning();

  /// Built from context rather than held as a `const` list, since each
  /// point is now a localized lookup.
  static List<String> _pointsFor(BuildContext context) => [
    context.l10n.settingsAiHelpNoAutoTopUp,
    context.l10n.settingsAiHelpSpendCap,
    context.l10n.settingsAiHelpDedicatedKey,
  ];

  @override
  Widget build(BuildContext context) {
    return AppWarningSurface(
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      radius: context.appRadius.small,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppWarningSurface.icon(context),
              const HGap.small(),
              Text(
                context.l10n.settingsAiHelpProtectTitle,
                style: context.appTypography.bodySmall.copyWith(
                  color: context.appPalette.warning,
                ),
              ),
            ],
          ),
          const VGap.tiny(),
          for (final point in _pointsFor(context))
            Padding(
              padding: EdgeInsets.only(bottom: context.appSpacing.gapTiny),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: context.appTypography.bodySmall),
                  Expanded(
                    child: Text(point, style: context.appTypography.bodySmall),
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
