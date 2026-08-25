import 'package:cv_forge/ui/common/cv_markup_flutter.dart';
import 'package:cv_forge/ui/common/tokens/app_palette.dart';
import 'package:cv_forge/ui/common/tokens/app_spacing.dart';
import 'package:cv_forge/ui/common/tokens/app_typography.dart';
import 'package:flutter/material.dart';

import 'tailorable_field.dart';
import 'tailoring_controls.dart';

/// One printed field's collapsed row: which field it is, what this CV
/// prints for it, and where that value comes from — the Vault glyph, the
/// undo button once it's been tailored, or a lock carrying the reason it
/// can't be. Expands to [InlineTextOverrideEditor] beneath itself while
/// [editing].
///
/// The one row shape for every field in Studio's editor pane: an entry's
/// own fields, a bullet's text, a skill's label, and — through
/// `StudioFieldOverrideCard` — the page-level headline, summary and
/// references. Those were four hand-built rows that had already drifted
/// on typography, on which icons they showed, and on whether they showed
/// any state at all, which is most of why the pane read as inconsistent.
///
/// The trailing cluster keeps its two slots in every case, locked rows
/// included, so a column of mixed rows lines up on one edge rather than
/// stepping in and out by the width of a missing button.
class StudioEntryFieldRow extends StatelessWidget {
  const StudioEntryFieldRow({
    super.key,
    required this.field,
    required this.editing,
    required this.onToggleEdit,
    this.dense = true,
    this.previewMaxLines = 2,
    this.editorMinLines = 2,
    this.editorMaxLines = 4,
    this.contentPadding,
  });

  final StudioEntryField field;

  /// Whether this row's editor is open. Always false for a
  /// [VaultOnlyField], which has no editor to open.
  final bool editing;
  final VoidCallback onToggleEdit;

  /// Caption-sized, for a row nested under an entry. False gives the row
  /// body type, for a page-level field that is the whole pane's subject.
  final bool dense;

  final int previewMaxLines;
  final int editorMinLines;
  final int editorMaxLines;

  /// Defaults to a small horizontal inset, so [TailoringHighlight]'s
  /// tint has room around the text rather than butting against it. A
  /// page-level caller passes [EdgeInsets.zero] to keep the row flush
  /// with the heading above it.
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final baseStyle = dense ? context.appTypography.caption : const TextStyle();
    // An omitted field still shows its value — you need to see what you
    // are choosing to leave off — but struck through and in the
    // placeholder colour, so a glance down the column says what prints.
    final omitted = switch (field) {
      VaultOnlyField(:final omitted) => omitted,
      _ => false,
    };
    final hasText = field.displayText.trim().isNotEmpty;
    // While editing, the value is dropped from the preview entirely —
    // the box directly below holds the same text, in full and editable,
    // and showing it twice made the row read as two fields. The label
    // stays, because the editor no longer carries one.
    final showValue = !editing;

    return TailoringHighlight(
      active: editing,
      child: Padding(
        padding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: context.appSpacing.paddingTight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        // Several rows can sit under one entry — an
                        // education entry owns five — so each says which
                        // field it is. Null for a row whose entry title
                        // already names it.
                        if (field.fieldLabel case final label?)
                          TextSpan(
                            text: '$label  ',
                            style: baseStyle.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        // Emphasis-only spans, so the outer style below
                        // still supplies the colour, the italic an empty
                        // field is drawn in, and the strikethrough on an
                        // omitted one. The empty message is localized
                        // chrome, never user text, so it is not parsed.
                        if (!showValue)
                          const TextSpan(text: '')
                        else if (hasText)
                          ...cvMarkupSpans(field.displayText)
                        else
                          TextSpan(text: field.emptyMessage ?? ''),
                      ],
                    ),
                    maxLines: previewMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: baseStyle.copyWith(
                      color: hasText && !omitted
                          ? scheme.onSurfaceVariant
                          : context.appPalette.placeholder,
                      fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
                      decoration: omitted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),
                switch (field) {
                  TailorableField(:final hasOverride, :final onRevert) =>
                    TailorIconButtons(
                      hasOverride: hasOverride,
                      editing: editing,
                      onToggleEdit: onToggleEdit,
                      onRevert: onRevert,
                    ),
                  VaultOnlyField(
                    :final reason,
                    :final omitted,
                    :final onToggleOmitted,
                  ) =>
                    VaultLockIcon(
                      reason: reason,
                      omitted: omitted,
                      onToggleOmitted: onToggleOmitted,
                    ),
                },
              ],
            ),
            if (editing && field is TailorableField)
              InlineTextOverrideEditor(
                field: field as TailorableField,
                onDone: onToggleEdit,
                minLines: editorMinLines,
                maxLines: editorMaxLines,
              ),
          ],
        ),
      ),
    );
  }
}
