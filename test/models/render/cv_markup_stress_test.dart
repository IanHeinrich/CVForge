/// Stress tests for the markup parser, over adversarial input rather than
/// hand-picked cases.
///
/// `cv_markup_test.dart` next door pins *what specific strings mean* — it
/// is the readable specification. This file pins that the parser cannot be
/// made to misbehave, which is a different question and needs a different
/// oracle: on twenty thousand inputs nobody can say what the right runs
/// are, but everybody can say the text must survive.
///
/// The corpus is deliberately hostile. It includes CommonMark's own
/// emphasis and backslash-escape examples, which exist precisely because
/// they broke somebody's parser once. Their expected HTML is **not**
/// asserted — this parser diverges from CommonMark on purpose (no
/// intraword `*`, no `_` emphasis, only `\*` escapes), so the spec's
/// answers are the wrong oracle. Its *inputs* are still the best
/// adversarial corpus available, and the invariants below hold regardless
/// of which emphasis rules a parser picks.
///
/// A seeded fuzzer covers what neither list thinks of. It is what caught
/// the delimiter bug this parser shipped with, when that bug was put back
/// deliberately to check this file was worth having: a delimiter stranded
/// inside a pair that closed over it was dropped from the text rather
/// than only from the matcher, so `*a*a*` printed "aa". No hand-written
/// case here found it; `fuzz[190]` did.
///
/// **What this file does not cover, on purpose.** These are invariants,
/// so they say nothing about what a string *means*. Removing the
/// intraword rule — which would silently italicise every A-level grade in
/// the app — leaves every invariant here intact and this file green.
/// `cv_markup_test.dart` is what fails for that, and the two were checked
/// against each other by breaking the parser four ways: dropped markers,
/// broken coalescing and unspliced leftovers fail here, and only the
/// meaning change fails there.
library;

import 'dart:math';

import 'package:cv_forge/models/render/cv_markup.dart';
import 'package:cv_forge/ui/common/cv_markup_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every invariant the parser owes its callers, checked at once.
///
/// Stated as properties rather than expected outputs because that is what
/// survives contact with input nobody wrote by hand. Each one is load
/// bearing somewhere:
///
/// - **Never throws.** This runs on every keystroke in a focused field.
/// - **Strip equals the joined runs.** Search, the LLM length budget and
///   the on-screen counter all compare against `stripCvMarkup` while the
///   PDF draws the runs; if the two ever disagree those features go
///   quietly wrong rather than loudly.
/// - **Never grows.** Parsing removes markers; it may not invent text.
/// - **No empty runs, and no two adjacent runs share an emphasis.** Both
///   would mean coalescing missed something, which shows up in the PDF as
///   avoidable extra spans.
/// - **Every character that is not a marker survives, in order.** The one
///   that matters most: a CV must print what someone typed.
/// - **The Flutter adapter agrees.** It is the second consumer of the same
///   runs, so it is worth proving it cannot drift from the first.
void _checkInvariants(String source, {required String label}) {
  late final List<CvTextRun> runs;
  late final String stripped;
  expect(
    () {
      runs = parseCvMarkup(source);
      stripped = stripCvMarkup(source);
    },
    returnsNormally,
    reason: '$label threw on ${source.codeUnits}',
  );

  final joined = runs.map((r) => r.text).join();

  expect(stripped, joined, reason: '$label: strip disagreed with the runs');
  expect(
    joined.length,
    lessThanOrEqualTo(source.length),
    reason: '$label: parsing invented characters',
  );
  expect(
    runs.where((r) => r.text.isEmpty),
    isEmpty,
    reason: '$label: produced an empty run',
  );

  for (var i = 1; i < runs.length; i++) {
    final same =
        runs[i].bold == runs[i - 1].bold &&
        runs[i].italic == runs[i - 1].italic;
    expect(same, isFalse, reason: '$label: adjacent runs were not coalesced');
  }

  // Only markers and escape slashes may be removed, so stripping both from
  // each side must leave identical text.
  String bare(String s) => s.replaceAll('*', '').replaceAll(r'\', '');
  expect(
    bare(joined),
    bare(source),
    reason: '$label: altered or dropped a character that was not a marker',
  );

  // Markers are accounted for, not merely allowed to vanish. The check
  // above deliberately ignores asterisks on both sides, so on its own it
  // cannot see a marker being *dropped* — which is exactly the bug this
  // parser shipped with. Every consumed asterisk belongs to a matched
  // pair, and a pair always takes the same count from each end, so the
  // number consumed can only ever be even. An odd count means one went
  // missing.
  // An escaped `\*` prints an asterisk that was never a delimiter, so it
  // is credited back before the difference is taken.
  final printedDelimiters =
      '*'.allMatches(joined).length - _escapedStars(source);
  final consumed = _delimiterStars(source) - printedDelimiters;
  expect(
    consumed.isEven && consumed >= 0,
    isTrue,
    reason:
        '$label: consumed $consumed asterisks, which no set of matched '
        'pairs can account for — one was dropped rather than printed',
  );

  final spanText = cvMarkupSpans(
    source,
  ).map((s) => (s as TextSpan).text ?? '').join();
  expect(
    spanText,
    joined,
    reason: '$label: the Flutter adapter drew different text',
  );
}

/// Asterisks in [source] that are candidates to be markers — an escaped
/// `\*` is a literal the parser must print, never a delimiter.
int _delimiterStars(String source) {
  var count = 0;
  for (var i = 0; i < source.length; i++) {
    if (source[i] == r'\' && i + 1 < source.length && source[i + 1] == '*') {
      i++;
      continue;
    }
    if (source[i] == '*') count++;
  }
  return count;
}

/// How many `\*` escapes [source] contains. Each one prints an asterisk
/// that was never a candidate delimiter, so the count is what separates a
/// marker the parser consumed from one it was never offered.
int _escapedStars(String source) {
  var count = 0;
  for (var i = 0; i < source.length - 1; i++) {
    if (source[i] == r'\' && source[i + 1] == '*') {
      count++;
      i++;
    }
  }
  return count;
}

/// Things that turn up in real CVs and would be embarrassing to mangle.
const _cvCorpus = <String, String>{
  'A-level grades': 'A*A*A',
  'grades in a sentence': 'A Levels: A*A*A in Maths, Physics and Chemistry',
  'a single starred grade': 'Predicted A*',
  'multiplication': 'Scaled 3 * 4 clusters',
  'arithmetic in a metric': r'Cost per unit: $5 * 1000 units',
  'a footnote marker': 'Références disponibles sur demande*',
  'a leading footnote': '*Contact details available on request',
  'a Windows path': r'C:\Users\jordan\Documents\cv.pdf',
  'a UNC share': r'\\fileserver\team\portfolio',
  'a SQL wildcard': 'SELECT * FROM candidates WHERE active = 1',
  'a shell glob': 'rm -rf ./build/* && flutter build web',
  'a grep invocation': r'grep -rn "TODO" **/*.dart',
  'a snake_case identifier': 'Owned the user_events_v2 ingestion pipeline',
  'a dunder method': 'Implemented __init__ and __repr__',
  'an acronym with underscores': 'Raised AUC_ROC from 0.71 to 0.88',
  'a C pointer': 'Refactored char* handling in the parser',
  'a C double pointer': 'Rewrote int **matrix allocation',
  'intraword bold is refused': 'a**b**c',
  'a bolded role': '**Senior** Platform Engineer',
  'two emphases in one line': 'Cut **p99 latency** by *40%* in one quarter',
  'bold italic': '***Led*** the platform migration',
  'a bolded currency amount': 'Saved **€2m** across three markets',
  'emoji beside emphasis': '🚀 **Launched** the payments rewrite',
  'an accented word': 'Café **manager** for two years',
  'a combining accent': 'Cre\u0301ateur of **the** thing',
  'a zero-width space': 'a\u200b*b*',
  'right-to-left text': 'עברית **bold** English',
  'a non-breaking space': 'Cut latency\u00a0**40%**',
  'bare double marker': '**',
  'bare triple marker': '***',
  'bare quad marker': '****',
  'a long delimiter run': '********************',
  'markers around nothing': '** **',
  'an escaped pair': r'\*not emphasis\*',
  'an escaped grade': r'A\*A\*A',
  'a lone backslash': r'ends with a backslash \\',
  'multi-line prose': 'First line **bold**\nSecond line *italic*',
  'only whitespace': '   ',
  'empty': '',
};

/// CommonMark's own emphasis and backslash-escape examples, used as
/// adversarial input only — see the library comment for why their expected
/// output is not asserted.
const _specCorpus = <String>[
  '\\!\\"\\#\\\$\\%\\&\\\'\\(\\)\\*\\+\\,\\-\\.\\/\\:\\;\\<\\=\\>\\?\\@\\[\\\\\\]\\^\\_\\`\\{\\|\\}\\~',
  '\\\t\\A\\a\\ \\3\\φ\\«',
  '\\*not emphasized*',
  '\\<br/> not a tag',
  '\\[not a link](/foo)',
  '\\`not code`',
  '1\\. not a list',
  '\\* not a list',
  '\\# not a heading',
  '\\[foo]: /url "not a reference"',
  '\\&ouml; not a character entity',
  '*foo bar*',
  'a * foo bar*',
  'a*"foo"*',
  '* a *',
  '*\$*alpha.',
  '*£*bravo.',
  '*€*charlie.',
  '*𞋿*delta.',
  'foo*bar*',
  '5*6*78',
  '_foo bar_',
  '_ foo bar_',
  'a_"foo"_',
  'foo_bar_',
  '5_6_78',
  'пристаням_стремятся_',
  'aa_"bb"_cc',
  'foo-_(bar)_',
  '_foo*',
  '*foo bar *',
  '*foo bar',
  '*',
  '*(*foo)',
  '*(*foo*)*',
  '*foo*bar',
  '_foo bar _',
  '_(_foo)',
  '_(_foo_)_',
  '_foo_bar',
  '_пристаням_стремятся',
  '_foo_bar_baz_',
  '_(bar)_.',
  '**foo bar**',
  '** foo bar**',
  'a**"foo"**',
  'foo**bar**',
  '__foo bar__',
  '__ foo bar__',
  '__',
  'foo bar__',
  'a__"foo"__',
  'foo__bar__',
  '5__6__78',
  'пристаням__стремятся__',
  '__foo, __bar__, baz__',
  'foo-__(bar)__',
  '**foo bar **',
  '**(**foo)',
  '*(**foo**)*',
  '**Gomphocarpus (*Gomphocarpus physocarpus*, syn.',
  '*Asclepias physocarpa*)**',
  '**foo "*bar*" foo**',
  '**foo**bar',
  '__foo bar __',
  '__(__foo)',
  '_(__foo__)_',
  '__foo__bar',
  '__пристаням__стремятся',
  '__foo__bar__baz__',
  '__(bar)__.',
  '*foo [bar](/url)*',
  '*foo',
  'bar*',
  '_foo __bar__ baz_',
  '_foo _bar_ baz_',
  '__foo_ bar_',
  '*foo *bar**',
  '*foo **bar** baz*',
  '*foo**bar**baz*',
  '*foo**bar*',
  '***foo** bar*',
  '*foo **bar***',
  '*foo**bar***',
  'foo***bar***baz',
  'foo******bar*********baz',
  '*foo **bar *baz* bim** bop*',
  '*foo [*bar*](/url)*',
  '** is not an empty emphasis',
  '**** is not an empty strong emphasis',
  '**foo [bar](/url)**',
  '**foo',
  'bar**',
  '__foo _bar_ baz__',
  '__foo __bar__ baz__',
  '____foo__ bar__',
  '**foo **bar****',
  '**foo *bar* baz**',
  '**foo*bar*baz**',
  '***foo* bar**',
  '**foo *bar***',
  '**foo *bar **baz**',
  'bim* bop**',
  '**foo [*bar*](/url)**',
  '__ is not an empty emphasis',
  '____ is not an empty strong emphasis',
  'foo ***',
  'foo *\\**',
  'foo *_*',
  'foo *****',
  'foo **\\***',
  'foo **_**',
  '**foo*',
  '*foo**',
  '***foo**',
  '****foo*',
  '**foo***',
  '*foo****',
  'foo ___',
  'foo _\\__',
  'foo _*_',
  'foo _____',
  'foo __\\___',
  'foo __*__',
  '__foo_',
  '_foo__',
  '___foo__',
  '____foo_',
  '__foo___',
  '_foo____',
  '**foo**',
  '*_foo_*',
  '__foo__',
  '_*foo*_',
  '****foo****',
  '____foo____',
  '******foo******',
  '***foo***',
  '_____foo_____',
  '*foo _bar* baz_',
  '*foo __bar *baz bim__ bam*',
  '**foo **bar baz**',
  '*foo *bar baz*',
  '*[bar*](/url)',
  '_foo [bar_](/url)',
  '*<img src="foo" title="*"/>',
  '**<a href="**">',
  '__<a href="__">',
  '*a `*`*',
  '_a `_`_',
  '**a<https://foo.bar/?q=**>',
  '__a<https://foo.bar/?q=__>',
];

void main() {
  group('cv_markup stress - text a real CV contains -', () {
    _cvCorpus.forEach((name, source) {
      test(name, () => _checkInvariants(source, label: name));
    });
  });

  group("cv_markup stress - CommonMark's own adversarial examples -", () {
    for (final (index, source) in _specCorpus.indexed) {
      test('spec input $index: ${_readable(source)}', () {
        _checkInvariants(source, label: 'spec[$index]');
      });
    }
  });

  group('cv_markup stress - generated input -', () {
    test('holds over 20,000 seeded random strings', () {
      // Seeded, so a failure names one reproducible string rather than a
      // mood. The alphabet is the punctuation the parser reasons about
      // plus the character classes its flanking rules split on.
      final rng = Random(20260826);
      const alphabet = [
        '*',
        r'\',
        'a',
        'A',
        '1',
        ' ',
        '\t',
        '_',
        '.',
        '-',
        '\u00a0',
        '€',
        '🚀',
        '\u0301',
      ];

      for (var i = 0; i < 20000; i++) {
        final length = rng.nextInt(13);
        final buffer = StringBuffer();
        for (var j = 0; j < length; j++) {
          buffer.write(alphabet[rng.nextInt(alphabet.length)]);
        }
        _checkInvariants(buffer.toString(), label: 'fuzz[$i]');
      }
    });

    test('holds over long runs of markers, which is where a delimiter '
        'stack is most likely to do something quadratic or wrong', () {
      for (var n = 1; n <= 64; n++) {
        _checkInvariants('*' * n, label: 'run of $n');
        _checkInvariants('${'*' * n}word${'*' * n}', label: 'wrapped in $n');
        _checkInvariants('a${'*' * n}b', label: 'intraword run of $n');
      }
    });

    test('holds on a field far longer than any CV needs', () {
      final long = List.filled(2000, 'Cut **p99** by *40%*').join(' ');
      _checkInvariants(long, label: 'long field');
    });
  });

  group(
    'cv_markup stress - the property that deliberately does NOT hold -',
    () {
      test('stripping is a one-way projection, not a normal form — applying '
          'it twice may differ, because resolving an escape can expose '
          'characters that then read as markers', () {
        // Nothing in the app strips twice; this is pinned so the difference
        // reads as understood rather than as a bug someone should "fix".
        const source = r'\*not emphasis*';
        expect(stripCvMarkup(source), '*not emphasis*');
        expect(stripCvMarkup(stripCvMarkup(source)), 'not emphasis');
      });
    },
  );
}

/// A test name safe to print — control characters and very long inputs
/// make for unreadable output when a case fails.
String _readable(String source) {
  final flattened = source
      .replaceAll('\n', r'\n')
      .replaceAll('\t', r'\t')
      .replaceAll('\u00a0', r'\u00a0');
  return flattened.length <= 40
      ? '"$flattened"'
      : '"${flattened.substring(0, 40)}"…';
}
