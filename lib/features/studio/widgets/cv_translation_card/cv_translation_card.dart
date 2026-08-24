import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/widgets/common/app_beta_badge/app_beta_badge.dart';
import 'package:flutter/material.dart';

import 'package:cv_forge/features/studio/widgets/studio_panel_heading.dart';

/// Studio's "translate this CV" card — a sibling of
/// `AiAssistantConfigCard`, sitting directly beneath it in the section nav
/// column and deliberately shaped like it: same container, same heading +
/// [AppBetaBadge], same `Wrap` of actions, same standing warning once a
/// pass has been applied.
///
/// It is a card in that column rather than a control in the document bar,
/// even though the language it translates into is chosen there. The bar's
/// single-row budget is tuned for the controls it already has, and this
/// belongs with the other thing in the app that sends the CV to a model.
///
/// Takes plain values and callbacks rather than the ViewModel, matching
/// `AiAssistantConfigCard` — the card renders a state machine it does not
/// own.
class CvTranslationCard extends StatelessWidget {
  const CvTranslationCard({
    super.key,
    required this.targetLanguage,
    required this.translatedLanguage,
    required this.isStale,
    required this.hasApiKey,
    required this.canRemove,
    required this.onRun,
    required this.onRemove,
    required this.onOpenSettings,
  });

  /// The language a run would translate into — the draft's own document
  /// language, chosen in the document bar.
  final String targetLanguage;

  /// The language this draft was last translated into, or null if it never
  /// has been.
  final String? translatedLanguage;

  /// Whether [translatedLanguage] and [targetLanguage] have diverged — the
  /// user changed the CV's language after translating it, so what is on
  /// the page is a translation into the wrong language.
  final bool isStale;

  final bool hasApiKey;

  /// Whether there is a pre-translation snapshot to restore. Offering
  /// Remove without one gives a button that silently does nothing.
  final bool canRemove;

  final VoidCallback onRun;
  final Future<void> Function() onRemove;
  final Future<void> Function() onOpenSettings;

  bool get _hasTranslation => translatedLanguage != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StudioPanelHeading(context.l10n.studioTranslateCardTitle),
              const HGap.small(),
              const AppBetaBadge(),
            ],
          ),
          const VGap.tiny(),
          Text(
            hasApiKey
                ? context.l10n.studioTranslateCardBody
                : context.l10n.studioTranslateCardBodyNoKey,
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          _StatusLine(
            targetLanguage: targetLanguage,
            translatedLanguage: translatedLanguage,
            isStale: isStale,
          ),
          const VGap.small(),
          // A `Wrap`, not a `Row` — this column is too narrow for both
          // buttons on one line, the same constraint
          // `AiAssistantConfigCard` documents.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!hasApiKey)
                FilledButton.tonal(
                  onPressed: onOpenSettings,
                  child: Text(context.l10n.studioAiSetUpInSettings),
                )
              else
                FilledButton(
                  onPressed: onRun,
                  child: Text(
                    _hasTranslation
                        ? context.l10n.studioTranslateRunAgain
                        : context.l10n.studioTranslateCardTitle,
                  ),
                ),
              if (_hasTranslation && canRemove)
                TextButton(
                  onPressed: onRemove,
                  child: Text(context.l10n.studioTranslateRemove),
                ),
            ],
          ),
          if (hasApiKey && !_hasTranslation) ...[
            const VGap.small(),
            // Run order is the one thing about this feature a user cannot
            // discover by trying it: tailoring after translating quietly
            // puts English back, because both passes write to the same
            // override layer and neither records which wrote what.
            Text(
              context.l10n.studioTranslateTailorFirst,
              style: context.appTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (_hasTranslation) ...[
            const VGap.small(),
            // Permanent while a translation is applied, for the same
            // reason `studioAiWarning` is: the run worth checking is
            // exactly the one whose warning would already be dismissed.
            Text(
              context.l10n.studioTranslateWarning,
              style: context.appTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.targetLanguage,
    required this.translatedLanguage,
    required this.isStale,
  });

  final String targetLanguage;
  final String? translatedLanguage;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final translated = translatedLanguage;
    final (text, isWarning) = switch ((translated, isStale)) {
      (final t?, true) => (
        context.l10n.studioTranslateCardStale(t, targetLanguage),
        true,
      ),
      (final t?, false) => (
        context.l10n.studioTranslateCardTranslated(t),
        false,
      ),
      _ => (context.l10n.studioTranslateCardTarget(targetLanguage), false),
    };

    return Text(
      text,
      style: context.appTypography.bodySmall.copyWith(
        color: isWarning
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
