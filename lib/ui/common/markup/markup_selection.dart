/// The one mutation behind both the formatting buttons and their keyboard
/// shortcuts — turn an emphasis on or off over whatever is selected — and
/// the reading of that same state the buttons light up from.
///
/// Lives apart from the toolbar because the shortcut path has no toolbar
/// to call into — a field can be formatted from the keyboard whether or
/// not its buttons are on screen.
library;

import 'package:flutter/widgets.dart';

/// The marker for bold. Two asterisks, matching what the parser reads.
const String boldMarker = '**';

/// The marker for italic.
const String italicMarker = '*';

/// The most asterisks a delimiter run can carry meaning for — bold and
/// italic together.
const int _maxRun = 3;

/// Toggles [marker]'s emphasis over [controller]'s selection.
///
/// Modelled as a bit toggle rather than as wrapping or unwrapping a
/// string, because those two are not the whole story: applying italic to
/// an already-bold word has to *compose* into bold-italic, not strip a
/// marker off it. A delimiter run's length says which emphases are on —
/// one is italic, two is bold, three is both — so applying a marker flips
/// its bit and rewrites the run. That gives every case people expect from
/// an editor: a second press removes what the first added, bold then
/// italic gives bold-italic, and removing bold from a bold-italic word
/// leaves it italic.
///
/// The selection is restored over the words themselves, never over the
/// markers, so the toggle stays reversible by pressing again.
///
/// Returns false when there was nothing to act on, so a caller can leave
/// a key event unhandled rather than swallowing it.
bool wrapSelectionInMarker(TextEditingController controller, String marker) {
  final value = controller.value;
  final measured = _measure(value);
  if (measured == null) return false;
  final (:applied, :leadInside, :tailInside) = measured;

  final text = value.text;
  final start = value.selection.start;
  final end = value.selection.end;
  final wanted = applied ^ (marker == boldMarker ? 2 : 1);

  // Consume the existing run from inside the selection first, then from
  // the text around it, so only the asterisks actually being replaced are
  // touched.
  final leadFromInside = applied < leadInside ? applied : leadInside;
  final leadFromOutside = applied - leadFromInside;
  final tailFromInside = applied < tailInside ? applied : tailInside;
  final tailFromOutside = applied - tailFromInside;

  final inner = text.substring(start + leadFromInside, end - tailFromInside);
  final run = '*' * wanted;

  final replaceStart = start - leadFromOutside;
  final replaceEnd = end + tailFromOutside;
  final caret = replaceStart + wanted;

  controller.value = TextEditingValue(
    text: text.replaceRange(replaceStart, replaceEnd, '$run$inner$run'),
    selection: TextSelection(
      baseOffset: caret,
      extentOffset: caret + inner.length,
    ),
  );
  return true;
}

/// Which emphases are already on across [value]'s selection.
///
/// What the toolbar's buttons draw themselves from, and deliberately the
/// same measurement [wrapSelectionInMarker] toggles — a button that lit up
/// from its own reading of the text could show a state its press would not
/// act on. Both go through [_measure] so they cannot disagree.
///
/// Read from the delimiters bounding the selection, so a caret merely
/// resting inside an emphasised word reads as off. That is not an
/// approximation to tighten later: pressing bold there wraps the caret,
/// it does not unbold the word, and the button says what pressing it
/// does.
({bool bold, bool italic}) selectionEmphasis(TextEditingValue value) {
  final applied = _measure(value)?.applied ?? 0;
  return (bold: applied & 2 != 0, italic: applied & 1 != 0);
}

/// The delimiter run around [value]'s selection, or null if there is no
/// selection to measure.
///
/// Markers may sit inside the selection (the user selected `**word**`) or
/// just outside it (they selected `word` between existing markers). Both
/// are the same run, so it is measured on each side across the boundary
/// and treated as one. [applied] is that run as a bitmask — 1 italic, 2
/// bold — and the two inside counts say how much of it the selection
/// already contains, which is what decides where a rewrite takes its
/// asterisks from.
({int applied, int leadInside, int tailInside})? _measure(
  TextEditingValue value,
) {
  final selection = value.selection;
  if (!selection.isValid) return null;

  final text = value.text;
  final start = selection.start;
  final end = selection.end;
  final leadInside = _runForward(text, start, end);
  final tailInside = _runBackward(text, end, floor: start);

  return (
    applied: _min3(
      leadInside + _runBackward(text, start),
      tailInside + _runForward(text, end, text.length),
    ),
    leadInside: leadInside,
    tailInside: tailInside,
  );
}

int _min3(int a, int b) {
  final smaller = a < b ? a : b;
  return smaller < _maxRun ? smaller : _maxRun;
}

/// How many asterisks run forward from [from], stopping at [limit].
int _runForward(String text, int from, int limit) {
  var n = 0;
  while (from + n < limit && n < _maxRun && text.codeUnitAt(from + n) == 0x2a) {
    n++;
  }
  return n;
}

/// How many asterisks run backward from just before [from], stopping at
/// [floor].
int _runBackward(String text, int from, {int floor = 0}) {
  var n = 0;
  while (from - n > floor &&
      n < _maxRun &&
      text.codeUnitAt(from - n - 1) == 0x2a) {
    n++;
  }
  return n;
}
