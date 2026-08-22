import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:cv_forge/ui/common/tokens/app_radius.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'studio_panel_heading.dart';
import 'tailorable_field.dart';
import 'tailoring_controls.dart';

/// A block-card tailoring editor for a page-level, singular text field —
/// collapsed (showing either the Vault's value or, once tailored, the
/// override) until the user taps the pencil, so it's never ambiguous
/// whether typing here edits the draft or the Vault itself. Shared by
/// every field of this shape (headline, professional summary, references
/// note) rather than one near-identical widget per field.
///
/// Deliberately takes primitives, not a ViewModel — the three fields that
/// use this differ in which getters/setters back them, but the collapsed/
/// editing state machine is identical, so that's the only thing this
/// widget owns.
///
/// Reuses the entity-scoped rows' interaction by construction, not just by
/// resemblance: the same [TailorIconButtons] cluster, and once editing,
/// the same [InlineTextOverrideEditor] (built here from a
/// [TailorableField] wrapping this widget's own primitives) — so Escape,
/// the "Only affects this CV." footer, and the collapse behaviour can't
/// drift between the two call sites. Only the frame differs: this adds a
/// titled block card with an empty-Vault message, since a page-level field
/// has no parent row to hang off, unlike a bullet's own checkbox row.
/// Section visibility (show/hide) lives solely in Studio's "Sections"
/// list now, not here — see `StudioConfigPanel`.
///
/// [_editing] is local presentation state, always starting collapsed
/// regardless of [hasOverride] (mirroring bullets — tailoring a field
/// doesn't imply you want its editor open on every subsequent visit), and
/// changed only by the explicit pencil/checkmark/Escape actions — never
/// recomputed from the model on rebuild, so clearing the text box
/// mid-edit can't collapse the editor out from under the user.
class StudioFieldOverrideCard extends StatefulWidget {
  const StudioFieldOverrideCard({
    super.key,
    required this.label,
    required this.vaultValue,
    required this.hasOverride,
    required this.effectiveValue,
    required this.onChanged,
    required this.onRevert,
    required this.emptyVaultMessage,
  });

  /// Heading text, e.g. "Professional summary".
  final String label;

  /// The Vault's own value — shown collapsed when there's no override,
  /// and used as the "is there anything to tailor yet" check.
  final String? vaultValue;

  /// Whether the draft currently has an override — drives the pill and
  /// which text (Vault's or the override) shows while collapsed.
  final bool hasOverride;

  /// What the edit box is pre-filled with, and what shows collapsed once
  /// [hasOverride] is true: the override if there is one, else
  /// [vaultValue].
  final String effectiveValue;

  final Future<void> Function(String value) onChanged;
  final Future<void> Function() onRevert;

  /// Shown collapsed when there's no override and [vaultValue] is empty,
  /// e.g. "No headline in your Vault yet."
  final String emptyVaultMessage;

  @override
  State<StudioFieldOverrideCard> createState() =>
      _StudioFieldOverrideCardState();
}

class _StudioFieldOverrideCardState extends State<StudioFieldOverrideCard> {
  bool _editing = false;

  void _toggleEditing() => setState(() => _editing = !_editing);

  @override
  Widget build(BuildContext context) {
    final hasVaultValue = (widget.vaultValue ?? '').trim().isNotEmpty;
    final hasAnyValue = widget.hasOverride || hasVaultValue;
    final previewText = widget.hasOverride
        ? widget.effectiveValue
        : (hasVaultValue ? widget.vaultValue! : widget.emptyVaultMessage);

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
          StudioPanelHeading(widget.label),
          const VGap.tiny(),
          Row(
            children: [
              Expanded(
                child: Text(
                  previewText,
                  // One line while editing: the box directly below is
                  // already showing this text in full.
                  maxLines: _editing ? 1 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hasAnyValue ? kcLightGrey : kcMediumGrey,
                    fontStyle: hasAnyValue
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ),
              TailorIconButtons(
                hasOverride: widget.hasOverride,
                editing: _editing,
                onToggleEdit: _toggleEditing,
                onRevert: widget.onRevert,
              ),
            ],
          ),
          if (_editing)
            InlineTextOverrideEditor(
              field: TailorableField(
                hasOverride: widget.hasOverride,
                effectiveText: widget.effectiveValue,
                onChanged: widget.onChanged,
                onRevert: widget.onRevert,
                emptyMessage: widget.emptyVaultMessage,
              ),
              onDone: _toggleEditing,
              // A page-level field is typically longer prose than a
              // bullet — a bigger box to start from, same widget either
              // way.
              maxLines: 6,
              minLines: 3,
            ),
        ],
      ),
    );
  }
}
