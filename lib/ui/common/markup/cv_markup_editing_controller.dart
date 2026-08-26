/// A [TextEditingController] that paints emphasis while it is being
/// typed: `**bold**` shows *bold* actually bold, with the asterisks
/// dimmed rather than hidden.
///
/// The characters are untouched and every offset is preserved, so the
/// caret, selection, and deletion all behave exactly as in a plain field
/// — only the painting changes. That honesty is the point. Hiding the
/// markers would make them impossible to remove, and a field that shows
/// something other than what it stores is a field you cannot reason about
/// while editing it.
library;

import 'package:cv_forge/models/render/cv_markup.dart';
import 'package:flutter/widgets.dart';

/// Paints [parseCvMarkup]'s runs, and dims the delimiters between them.
class CvMarkupEditingController extends TextEditingController {
  CvMarkupEditingController({super.text, required this.markerColor});

  /// What a delimiter is drawn in — dimmed, so the eye reads the words
  /// and not the punctuation holding them. Mutable because it is a theme
  /// value, resolved by the field that owns this on each build.
  Color markerColor;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // While an IME is composing, the text on screen is provisional and
    // the platform expects it drawn as one underlined run. Styling inside
    // that run would fight it, so defer until the composition commits.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    return _styled(style);
  }

  TextSpan _styled(TextStyle? style) {
    final source = text;
    if (!source.contains('*')) {
      return TextSpan(text: source, style: style);
    }

    final runs = parseCvMarkup(source);
    final children = <TextSpan>[];
    // Walk the source alongside the runs. A run's text always appears in
    // order, so whatever sits between one run's end and the next one's
    // start is delimiter — no separate index bookkeeping needed.
    var cursor = 0;
    for (final run in runs) {
      final at = source.indexOf(run.text, cursor);
      if (at < 0) {
        // Should not happen — the runs are built from this string — but a
        // text field must never throw while someone is typing into it.
        return TextSpan(text: source, style: style);
      }
      if (at > cursor) {
        children.add(
          TextSpan(
            text: source.substring(cursor, at),
            style: (style ?? const TextStyle()).copyWith(color: markerColor),
          ),
        );
      }
      children.add(
        TextSpan(
          text: run.text,
          style: run.bold || run.italic
              ? (style ?? const TextStyle()).copyWith(
                  fontWeight: run.bold ? FontWeight.w700 : null,
                  fontStyle: run.italic ? FontStyle.italic : null,
                )
              : style,
        ),
      );
      cursor = at + run.text.length;
    }
    if (cursor < source.length) {
      children.add(
        TextSpan(
          text: source.substring(cursor),
          style: (style ?? const TextStyle()).copyWith(color: markerColor),
        ),
      );
    }

    return TextSpan(style: style, children: children);
  }
}
