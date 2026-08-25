/// The inline emphasis a user can type into any printed CV field, and the
/// two things the rest of the app needs from it: the styled runs a
/// renderer draws, and the plain text everything else compares against.
///
/// Pure Dart, imports nothing — same rule as `cv_design_tokens.dart`, and
/// the reason the PDF renderer, the Flutter chrome, `models/llm/` and
/// `models/vault/` can all share one parser without a cycle.
///
/// Three constructs, `*` only: `**bold**`, `*italic*`, `***bold
/// italic***`. This is the successor to the `CvBullet.label` field
/// removed in #98 — see `CvBullet`'s doc comment, which explains why
/// emphasis *within* a sentence is the technique that works and a
/// separate field is not.
library;

/// One contiguous stretch of text sharing a single emphasis state — the
/// unit both renderers turn into a styled span.
///
/// A plain record, not a `@freezed` class, for the same reason as
/// `AtsPixelRect`: a per-render calculation result, not persisted app
/// state, with no need of `copyWith`, JSON, or a union over it.
typedef CvTextRun = ({String text, bool bold, bool italic});

const int _star = 0x2a;
const int _backslash = 0x5c;

/// [source] split into emphasis runs.
///
/// Never throws and never returns null: text that is not well-formed
/// markup comes back as literal runs rather than being rejected, because
/// this parses whatever a user typed into a CV field, not a document
/// format they opted into.
///
/// `runs.map((r) => r.text).join()` is always exactly what prints, which
/// is the invariant [stripCvMarkup] is defined against.
List<CvTextRun> parseCvMarkup(String source) {
  if (source.isEmpty) return const [];
  // `\*` is the only escape, so a string with no asterisk cannot contain
  // markup and cannot contain an escape either — it is already its own
  // output. Worth short-circuiting: most CV fields never carry markup.
  if (!source.contains('*')) {
    return [(text: source, bold: false, italic: false)];
  }

  final units = source.codeUnits;
  // Literal characters with escapes already resolved. A delimiter run's
  // own asterisks are NOT appended here — whatever survives matching is
  // spliced back in below.
  final out = <int>[];
  final delims = <_Delim>[];

  var i = 0;
  while (i < units.length) {
    final unit = units[i];
    if (unit == _backslash && i + 1 < units.length && units[i + 1] == _star) {
      // Literal, and deliberately not registered as a delimiter.
      out.add(_star);
      i += 2;
      continue;
    }
    if (unit != _star) {
      out.add(unit);
      i++;
      continue;
    }
    final runStart = i;
    while (i < units.length && units[i] == _star) {
      i++;
    }
    // `prev` reads the last already-unescaped character, so a `\*` before
    // this run is seen as the `*` it prints. Two delimiter runs can never
    // be adjacent — a maximal run is consumed at once — so this is always
    // a literal character or the start of the string.
    final prev = out.isEmpty ? null : out.last;
    final next = i < units.length ? units[i] : null;
    delims.add(
      _Delim(
        outIndex: out.length,
        remaining: i - runStart,
        canOpen: _canOpen(prev, next),
        canClose: _canClose(prev, next),
      ),
    );
  }

  _matchDelimiters(delims);
  return _spliceAndFlag(out, delims);
}

/// What [source] actually prints, with its emphasis marks removed — the
/// form to search against, to test for blankness, and to measure a length
/// budget in.
///
/// Defined as [parseCvMarkup]'s concatenation rather than an independent
/// strip, so the two can never disagree about what a string says.
String stripCvMarkup(String source) {
  if (!source.contains('*')) return source;
  final buffer = StringBuffer();
  for (final run in parseCvMarkup(source)) {
    buffer.write(run.text);
  }
  return buffer.toString();
}

/// One maximal run of unescaped asterisks, and what it is still able to do.
class _Delim {
  _Delim({
    required this.outIndex,
    required this.remaining,
    required this.canOpen,
    required this.canClose,
  });

  /// Where this run sits in the literal-character stream, before its own
  /// surviving asterisks are spliced back in.
  final int outIndex;

  /// Asterisks not yet consumed by a pair. Whatever is left prints.
  int remaining;

  /// Whether this run may still take part in a pair.
  ///
  /// Separate from [remaining] on purpose. A delimiter stranded inside a
  /// pair that closed over it stops being *matchable* — otherwise an
  /// opener inside a finished span could still reach a later closer and
  /// produce spans that cross rather than nest — but its asterisks are
  /// still ordinary characters and still print. Collapsing the two would
  /// silently delete them: `*a*a*` would come out as "aa".
  bool matchable = true;

  final bool canOpen;
  final bool canClose;

  /// The pairs this run closed, recorded on the closer so the emphasis
  /// pass can walk them in one direction.
  final List<_Pair> pairs = [];

  /// Filled in during the splice: where this run's leftover asterisks
  /// begin in the final string.
  int startFinal = 0;
}

/// CommonMark's left-flanking rule, plus this app's own intraword rule.
bool _canOpen(int? prev, int? next) {
  if (_isIntraword(prev, next)) return false;
  if (_isSpace(next)) return false;
  return !_isPunct(next) || _isSpace(prev) || _isPunct(prev);
}

/// CommonMark's right-flanking rule, plus this app's own intraword rule.
bool _canClose(int? prev, int? next) {
  if (_isIntraword(prev, next)) return false;
  if (_isSpace(prev)) return false;
  return !_isPunct(prev) || _isSpace(next) || _isPunct(next);
}

/// A delimiter with a letter or digit on BOTH sides is literal text.
///
/// CommonMark allows intraword `*` (it only forbids intraword `_`). This
/// forbids both, for one concrete reason: `A*A*A` is a UK A-level grade
/// and a realistic `Education.grade` value, and under plain flanking it
/// silently italicises to "A" + emphasised "A" + "A". `**bold**` is
/// unaffected, since its delimiters sit at word boundaries.
///
/// It also removes the one genuine ATS hazard in this feature. Emphasis
/// inside a word splits it across two text-showing operators in the PDF,
/// which some extractors rejoin with a space — so `super**script**` could
/// reach a parser as "super script". Nothing legitimate on a CV needs it.
bool _isIntraword(int? prev, int? next) => _isAlnum(prev) && _isAlnum(next);

/// A string boundary counts as whitespace, which is what makes a leading
/// or trailing delimiter unable to close or open respectively.
///
/// U+00A0 is included deliberately: pasted CV text is full of
/// non-breaking spaces, and treating one as a letter would make a
/// delimiter beside it behave differently from one beside a plain space.
bool _isSpace(int? unit) =>
    unit == null ||
    unit == 0x20 || // space
    (unit >= 0x09 && unit <= 0x0d) || // tab, LF, VT, FF, CR
    unit == 0xa0; // no-break space

/// ASCII punctuation, plus the few typographic marks this app already
/// ships glyphs for and therefore sees in real CV text.
bool _isPunct(int? unit) {
  if (unit == null) return false;
  return (unit >= 0x21 && unit <= 0x2f) ||
      (unit >= 0x3a && unit <= 0x40) ||
      (unit >= 0x5b && unit <= 0x60) ||
      (unit >= 0x7b && unit <= 0x7e) ||
      unit == 0x2013 || // en dash
      unit == 0x2014 || // em dash
      unit == 0x2018 || // ' '
      unit == 0x2019 ||
      unit == 0x201c || // " "
      unit == 0x201d;
}

/// Anything that is neither whitespace nor punctuation — so accented
/// letters and non-Latin scripts count, which is what the intraword rule
/// needs. A surrogate half lands here too, and correctly: a delimiter can
/// never fall between the halves of a pair, so the pair is only ever
/// *beside* a delimiter, where it should read as a letter.
bool _isAlnum(int? unit) => unit != null && !_isSpace(unit) && !_isPunct(unit);

/// The delimiter-stack pass: for each run that can close, reach back for
/// the nearest earlier run that can open and still has asterisks left.
void _matchDelimiters(List<_Delim> delims) {
  for (var c = 0; c < delims.length; c++) {
    final closer = delims[c];
    if (!closer.canClose || !closer.matchable) continue;
    var o = c - 1;
    while (o >= 0 && closer.remaining > 0) {
      final opener = delims[o];
      if (!opener.canOpen || !opener.matchable || opener.remaining == 0) {
        o--;
        continue;
      }
      final strong = opener.remaining >= 2 && closer.remaining >= 2;
      final used = strong ? 2 : 1;
      opener.remaining -= used;
      closer.remaining -= used;
      closer.pairs.add(_Pair(opener: o, strong: strong));
      // CommonMark's "remove the delimiters between the pair" step —
      // from the stack, not from the text. Without it an opener inside a
      // just-closed span could still match a later closer, producing
      // spans that cross rather than nest; with it done wrongly, the
      // stranded asterisks vanish off the page instead of printing.
      for (var k = o + 1; k < c; k++) {
        delims[k].matchable = false;
      }
      if (opener.remaining == 0) o--;
    }
  }
}

/// Splice every unmatched asterisk back into the text, then paint the
/// emphasis each surviving pair covers.
///
/// Leftovers are spliced before the flags are applied, which is what puts
/// them *outside* their own pair (so `***a**` prints a literal `*` then
/// bold `a`) but still *inside* any enclosing pair.
List<CvTextRun> _spliceAndFlag(List<int> out, List<_Delim> delims) {
  final text = <int>[];
  var cursor = 0;
  for (final delim in delims) {
    while (cursor < delim.outIndex) {
      text.add(out[cursor]);
      cursor++;
    }
    delim.startFinal = text.length;
    for (var n = 0; n < delim.remaining; n++) {
      text.add(_star);
    }
  }
  while (cursor < out.length) {
    text.add(out[cursor]);
    cursor++;
  }

  final bold = List<bool>.filled(text.length, false);
  final italic = List<bool>.filled(text.length, false);
  for (var c = 0; c < delims.length; c++) {
    final closer = delims[c];
    for (final pair in closer.pairs) {
      final opener = delims[pair.opener];
      final from = opener.startFinal + opener.remaining;
      final to = closer.startFinal;
      for (var k = from; k < to; k++) {
        if (pair.strong) {
          bold[k] = true;
        } else {
          italic[k] = true;
        }
      }
    }
  }

  return _coalesce(text, bold, italic);
}

/// Adjacent characters of equal emphasis become one run.
List<CvTextRun> _coalesce(List<int> text, List<bool> bold, List<bool> italic) {
  if (text.isEmpty) return const [];
  final runs = <CvTextRun>[];
  var start = 0;
  for (var k = 1; k <= text.length; k++) {
    final ended = k == text.length;
    if (ended || bold[k] != bold[start] || italic[k] != italic[start]) {
      runs.add((
        text: String.fromCharCodes(text, start, k),
        bold: bold[start],
        italic: italic[start],
      ));
      start = k;
    }
  }
  return runs;
}

/// One matched delimiter pair, recorded on its closer.
class _Pair {
  const _Pair({required this.opener, required this.strong});

  final int opener;
  final bool strong;
}
