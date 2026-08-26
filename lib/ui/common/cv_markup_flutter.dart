/// Flutter-side adapter for [parseCvMarkup] — the chrome twin of
/// `templates/design/cv_markup_pdf.dart`.
///
/// Used wherever the app *displays* text a user typed into a printed CV
/// field: the Vault's summary cards, Studio's collapsed field rows and
/// its selection lists. Not used in an editing surface — a field being
/// edited shows the literal characters the user typed, markers included,
/// because those characters are what they are editing and hiding them
/// would leave no way to change them.
library;

import 'package:cv_forge/models/render/cv_markup.dart';
import 'package:flutter/material.dart';

/// [text]'s emphasis as spans carrying **only** `fontWeight`/`fontStyle`.
///
/// Deliberately not a full style per span. Flutter merges nested span
/// styles down the tree, so everything else — colour, size, the
/// strikethrough on an omitted field, the italic an empty field is drawn
/// in — keeps coming from the enclosing `Text.rich(style:)`. A span
/// carrying a complete `TextStyle` would silently drop all of it, which
/// is exactly what would happen to `StudioEntryFieldRow`'s omitted rows.
///
/// That also makes these spliceable into an existing `Text.rich`
/// alongside caller-styled spans, which is how the Studio row uses them.
List<InlineSpan> cvMarkupSpans(String text) => [
  for (final run in parseCvMarkup(text))
    TextSpan(
      text: run.text,
      style: run.bold || run.italic
          ? TextStyle(
              fontWeight: run.bold ? FontWeight.w700 : null,
              fontStyle: run.italic ? FontStyle.italic : null,
            )
          : null,
    ),
];

/// Drop-in for a `Text` showing user-entered CV text.
///
/// Text with no markup takes a fast path that builds the identical
/// `Text` widget, so a CV carrying no emphasis renders through exactly
/// the tree it did before — which is what keeps the golden baselines
/// valid rather than merely equivalent.
Widget cvMarkupText(
  String text, {
  TextStyle? style,
  int? maxLines,
  TextOverflow? overflow,
  TextAlign? textAlign,
}) {
  if (!text.contains('*')) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }
  return Text.rich(
    TextSpan(children: cvMarkupSpans(text)),
    style: style,
    maxLines: maxLines,
    overflow: overflow,
    textAlign: textAlign,
  );
}
