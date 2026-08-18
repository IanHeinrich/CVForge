/// Faked small caps: `package:pdf` has no OpenType `smcp` feature support,
/// so a small-caps effect is built by splitting text into runs — the
/// first letter of each word at full size, the rest of the word
/// uppercased and rendered smaller. Both renderers consume this same
/// split, so they can't diverge on which letters get shrunk.
library;

enum SmallCapsRunSize { full, reduced }

class SmallCapsRun {
  const SmallCapsRun(this.text, this.size);

  final String text;
  final SmallCapsRunSize size;
}

final _letter = RegExp(r'[A-Za-z]');

/// Splits [input] into small-caps runs. Non-letter characters (spaces,
/// punctuation, digits) pass through unchanged at full size.
List<SmallCapsRun> buildSmallCapsRuns(String input) {
  final runs = <SmallCapsRun>[];
  var i = 0;

  while (i < input.length) {
    final char = input[i];

    if (!_letter.hasMatch(char)) {
      // Coalesce consecutive non-letters into one full-size run.
      final start = i;
      while (i < input.length && !_letter.hasMatch(input[i])) {
        i++;
      }
      runs.add(SmallCapsRun(input.substring(start, i), SmallCapsRunSize.full));
      continue;
    }

    // Start of a word: first letter full size, rest reduced+uppercased.
    runs.add(SmallCapsRun(char.toUpperCase(), SmallCapsRunSize.full));
    i++;

    final restStart = i;
    while (i < input.length && _letter.hasMatch(input[i])) {
      i++;
    }
    if (i > restStart) {
      runs.add(
        SmallCapsRun(
          input.substring(restStart, i).toUpperCase(),
          SmallCapsRunSize.reduced,
        ),
      );
    }
  }

  return runs;
}
