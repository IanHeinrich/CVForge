import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:cv_forge/ui/common/ui_helpers.dart';
import 'package:flutter/material.dart';

import 'studio_entry_field_row.dart';
import 'studio_panel_heading.dart';
import 'tailorable_field.dart';

/// A flat tailoring editor for a page-level, singular text field —
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
/// Renders the entity-scoped rows' interaction by construction, not just
/// by resemblance: it *is* a [StudioEntryFieldRow], built from this
/// widget's own primitives, so the state glyph, Escape, and the collapse
/// behaviour can't drift between the two call sites. Only the frame
/// differs: this adds a heading and an empty-Vault message, and asks for
/// body type and a bigger editor, since a page-level field has no
/// parent row to hang off, unlike a bullet's own checkbox row — no card
/// box around it, matching every other Studio section editor, since the
/// section's own pane is already the boundary (a card *inside* an
/// already-bounded pane read as an unexplained inconsistency, not a
/// meaningful one). Section visibility (show/hide) lives solely in
/// Studio's "Sections" list now, not here — see `StudioSectionNav`.
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
    this.includeLabel,
    this.included,
    this.onToggleInclude,
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

  /// An optional "print this at all" checkbox beside the heading, for a
  /// field with no section checkbox of its own to omit it. All three are
  /// supplied together or not at all; the summary passes none, since
  /// hiding it is what its own section checkbox already does.
  ///
  /// Deliberately independent of the override — unchecking hides the
  /// field but keeps any edit, so re-checking restores it.
  final String? includeLabel;
  final bool? included;
  final Future<void> Function()? onToggleInclude;

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

    // Flat — no card frame; see class doc comment for why.
    return Padding(
      padding: EdgeInsets.only(bottom: context.appSpacing.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.onToggleInclude case final toggle?)
            Row(
              children: [
                Expanded(child: StudioPanelHeading(widget.label)),
                Semantics(
                  label: widget.includeLabel,
                  child: Checkbox(
                    value: widget.included ?? true,
                    onChanged: (_) => toggle(),
                  ),
                ),
                Text(
                  widget.includeLabel!,
                  style: context.appTypography.caption,
                ),
              ],
            )
          else
            StudioPanelHeading(widget.label),
          const VGap.tiny(),
          StudioEntryFieldRow(
            field: TailorableField(
              hasOverride: widget.hasOverride,
              // Empty rather than [effectiveValue] when there is nothing
              // yet, so the row falls through to `emptyMessage` and shows
              // the empty-Vault prompt in its placeholder style — and so
              // the edit box opens blank rather than pre-filled with that
              // prompt as if it were text.
              effectiveText: hasAnyValue ? widget.effectiveValue : '',
              vaultText: widget.vaultValue,
              onChanged: widget.onChanged,
              onRevert: widget.onRevert,
              emptyMessage: widget.emptyVaultMessage,
            ),
            editing: _editing,
            onToggleEdit: _toggleEditing,
            // A page-level field is the pane's whole subject, so it gets
            // body type and a bigger box than a row nested under an
            // entry, and sits flush with the heading directly above it.
            dense: false,
            previewMaxLines: 3,
            editorMinLines: 3,
            editorMaxLines: 6,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
