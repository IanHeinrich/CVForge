import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'studio_panel_heading.dart';
import 'tailorable_field.dart';
import 'tailoring_controls.dart';

/// The persistent AI Assistant card in `StudioSectionNav`: the job ad this
/// draft is being tailored for, the "Tailor with AI" action, and "Undo AI
/// changes" while a pass is applied.
///
/// The job description editor deliberately does **not** reuse
/// [StudioFieldOverrideCard] — that card's [TailorIconButtons] hardcodes
/// "From your Vault"/"Revert to Vault" copy for a field that always has a
/// Vault fallback, which is exactly untrue here: the job description has
/// no Vault source at all, it's draft-only free text. Built from the same
/// lower-level pieces ([TailorableField], [InlineTextOverrideEditor])
/// instead, with a plain pencil/clear pair rather than that Vault-specific
/// copy.
class AiAssistantConfigCard extends StatefulWidget {
  const AiAssistantConfigCard({
    super.key,
    required this.jobDescription,
    required this.onChanged,
    required this.onClear,
    required this.canRun,
    required this.onRun,
    required this.hasUndo,
    required this.onUndo,
    required this.hasApiKey,
    required this.onOpenSettings,
  });

  final String jobDescription;
  final Future<void> Function(String value) onChanged;
  final Future<void> Function() onClear;

  /// Whether [onRun] should be enabled — a non-empty job description *and*
  /// an API key to run it with.
  final bool canRun;
  final VoidCallback onRun;

  final bool hasUndo;
  final VoidCallback onUndo;

  /// False swaps the run button for a route into Settings. The key check
  /// used to happen inside the run dialog, so a user without one wrote a
  /// job description, opened a modal, and only then read "add an API key
  /// in Settings first" — an error where an unmet precondition belongs.
  final bool hasApiKey;
  final Future<void> Function() onOpenSettings;

  @override
  State<AiAssistantConfigCard> createState() => _AiAssistantConfigCardState();
}

class _AiAssistantConfigCardState extends State<AiAssistantConfigCard> {
  bool _editing = false;

  void _toggleEditing() => setState(() => _editing = !_editing);

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.jobDescription.trim().isNotEmpty;
    final previewText = hasDescription
        ? widget.jobDescription
        : context.l10n.studioAiJobAdHint;

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
              StudioPanelHeading(context.l10n.studioAiCardTitle),
              const HGap.small(),
              const _BetaBadge(),
            ],
          ),
          const VGap.tiny(),
          Text(
            widget.hasApiKey
                ? context.l10n.studioAiCardBody
                : context.l10n.studioAiCardBodyNoKey,
            style: context.appTypography.bodySmall,
          ),
          const VGap.small(),
          Row(
            children: [
              Expanded(
                child: Text(
                  previewText,
                  maxLines: _editing ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasDescription
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : context.appPalette.placeholder,
                    fontStyle: hasDescription
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ),
              if (hasDescription && !_editing)
                IconButton(
                  icon: const Icon(
                    RemixIcons.close_line,
                    size: kdTailorIconSize,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  tooltip: context.l10n.studioAiClearJobDescription,
                  onPressed: widget.onClear,
                ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  _editing ? RemixIcons.check_line : RemixIcons.edit_line,
                  size: kdTailorIconSize,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: _editing
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                tooltip: _editing
                    ? context.l10n.commonDone
                    : context.l10n.studioAiEditJobDescription,
                onPressed: _toggleEditing,
              ),
            ],
          ),
          if (_editing)
            InlineTextOverrideEditor(
              field: TailorableField(
                hasOverride: hasDescription,
                effectiveText: widget.jobDescription,
                onChanged: widget.onChanged,
                onRevert: widget.onClear,
                emptyMessage: previewText,
              ),
              onDone: _toggleEditing,
              maxLines: 10,
              minLines: 4,
            ),
          const VGap.small(),
          // A `Wrap`, not a `Row` — this card lives in Studio's fixed
          // ~220px nav column, too narrow for both buttons on one line at
          // once.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.hasApiKey)
                FilledButton(
                  onPressed: widget.canRun ? widget.onRun : null,
                  child: Text(context.l10n.studioAiCardTitle),
                )
              else
                FilledButton.tonal(
                  onPressed: widget.onOpenSettings,
                  child: Text(context.l10n.studioAiSetUpInSettings),
                ),
              if (widget.hasUndo)
                TextButton(
                  onPressed: widget.onUndo,
                  child: Text(context.l10n.studioAiUndo),
                ),
            ],
          ),
          if (widget.hasUndo) ...[
            const VGap.small(),
            // Permanent while a pass is applied, not a dismiss-once modal,
            // since the run that actually invents something is exactly
            // the one a user would have already dismissed the warning
            // for.
            Text(
              context.l10n.studioAiWarning,
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

/// A small stylised "BETA" tag next to the card's heading — AI Assistant
/// tailoring is functional but not yet held to the same bar as the rest of
/// the app, and this flags that inline rather than only in release notes
/// nobody reads before hitting "Tailor with AI".
class _BetaBadge extends StatelessWidget {
  const _BetaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: context.appPalette.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(context.appRadius.small),
        border: Border.all(
          color: context.appPalette.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        context.l10n.studioAiBeta,
        style: context.appTypography.caption.copyWith(
          color: context.appPalette.warning,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
