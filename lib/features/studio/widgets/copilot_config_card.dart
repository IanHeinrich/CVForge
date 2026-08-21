import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'studio_panel_heading.dart';
import 'tailorable_field.dart';
import 'tailoring_controls.dart';

/// The persistent Copilot card in [StudioConfigPanel] (plan.md's 4.5): the
/// job ad this draft is being tailored for, the "Tailor with AI" action,
/// and "Undo AI changes" while a pass is applied.
///
/// The job description editor deliberately does **not** reuse
/// [StudioFieldOverrideCard] — that card's [TailorIconButtons] hardcodes
/// "From your Vault"/"Revert to Vault" copy for a field that always has a
/// Vault fallback, which is exactly untrue here: the job description has
/// no Vault source at all, it's draft-only free text. Built from the same
/// lower-level pieces ([TailorableField], [InlineTextOverrideEditor])
/// instead, with a plain pencil/clear pair rather than that Vault-specific
/// copy.
class CopilotConfigCard extends StatefulWidget {
  const CopilotConfigCard({
    super.key,
    required this.jobDescription,
    required this.onChanged,
    required this.onClear,
    required this.canRun,
    required this.onRun,
    required this.hasUndo,
    required this.onUndo,
  });

  final String jobDescription;
  final Future<void> Function(String value) onChanged;
  final Future<void> Function() onClear;

  /// Whether [onRun] should be enabled — a non-empty job description.
  final bool canRun;
  final VoidCallback onRun;

  final bool hasUndo;
  final VoidCallback onUndo;

  @override
  State<CopilotConfigCard> createState() => _CopilotConfigCardState();
}

class _CopilotConfigCardState extends State<CopilotConfigCard> {
  bool _editing = false;

  void _toggleEditing() => setState(() => _editing = !_editing);

  @override
  Widget build(BuildContext context) {
    final hasDescription = widget.jobDescription.trim().isNotEmpty;
    final previewText = hasDescription
        ? widget.jobDescription
        : 'Paste the job ad you\'re tailoring this CV for.';

    return Container(
      margin: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
      padding: EdgeInsets.all(context.appSpacing.paddingCompact),
      decoration: BoxDecoration(
        color: kcDarkGreyColor,
        borderRadius: BorderRadius.circular(context.appRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StudioPanelHeading('Tailor with AI'),
          const VGap.tiny(),
          Text(
            'Bring your own API key in Settings, then paste a job ad here '
            'to select and rewrite this CV for it.',
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
                    color: hasDescription ? kcLightGrey : kcMediumGrey,
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
                  constraints: const BoxConstraints(),
                  color: kcLightGrey,
                  tooltip: 'Clear job description',
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
                color: _editing ? kcPrimaryColor : kcLightGrey,
                tooltip: _editing ? 'Done' : 'Edit job description',
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
          Row(
            children: [
              FilledButton(
                onPressed: widget.canRun ? widget.onRun : null,
                child: const Text('Tailor with AI'),
              ),
              if (widget.hasUndo) ...[
                const HGap.small(),
                TextButton(
                  onPressed: widget.onUndo,
                  child: const Text('Undo AI changes'),
                ),
              ],
            ],
          ),
          if (widget.hasUndo) ...[
            const VGap.small(),
            // Permanent while a pass is applied (decision 11, plan.md
            // 4.5) — not a dismiss-once modal, since the run that
            // actually invents something is exactly the one a user would
            // have already dismissed the warning for.
            Text(
              'AI-written. Check every rewritten bullet against what you '
              'actually did.',
              style: context.appTypography.bodySmall.copyWith(
                color: kcErrorColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
