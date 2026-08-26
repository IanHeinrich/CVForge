/// Direct tests of a pure function, under CLAUDE.md's carve-out for
/// helpers with no ViewModel or Service above them — the same shape and
/// the same reasoning as `test/models/ats/ats_matrix_math_test.dart`.
///
/// Routing these through `PdfExportService` would exercise less of the
/// logic at far higher cost: that boundary returns PDF bytes, from which
/// you cannot readily assert which delimiter matched which.
library;

import 'package:cv_forge/models/render/cv_markup.dart';
import 'package:flutter_test/flutter_test.dart';

/// Compact spelling of an expected run list, so a case reads as the
/// sentence it is testing rather than as a record literal.
List<CvTextRun> _runs(List<(String, String)> spec) => [
  for (final (text, flags) in spec)
    (text: text, bold: flags.contains('b'), italic: flags.contains('i')),
];

void main() {
  group('parseCvMarkup - the three constructs -', () {
    test('plain text is one unemphasised run', () {
      expect(
        parseCvMarkup('Led the migration'),
        _runs([('Led the migration', '')]),
      );
    });

    test('empty string yields no runs', () {
      expect(parseCvMarkup(''), isEmpty);
    });

    test('**x** is bold', () {
      expect(parseCvMarkup('**x**'), _runs([('x', 'b')]));
    });

    test('*x* is italic', () {
      expect(parseCvMarkup('*x*'), _runs([('x', 'i')]));
    });

    test('***x*** is bold and italic', () {
      expect(parseCvMarkup('***x***'), _runs([('x', 'bi')]));
    });

    test('emphasis mid-sentence splits into three runs', () {
      expect(
        parseCvMarkup('Cut **p99 latency** by 40%'),
        _runs([('Cut ', ''), ('p99 latency', 'b'), (' by 40%', '')]),
      );
    });

    test('two separate emphasised phrases in one sentence', () {
      expect(
        parseCvMarkup('Led **platform** work in *Kubernetes*'),
        _runs([
          ('Led ', ''),
          ('platform', 'b'),
          (' work in ', ''),
          ('Kubernetes', 'i'),
        ]),
      );
    });
  });

  group('parseCvMarkup - nesting -', () {
    test('bold inside italic composes to bold-italic on the inner span', () {
      expect(
        parseCvMarkup('*a **b** c*'),
        _runs([('a ', 'i'), ('b', 'bi'), (' c', 'i')]),
      );
    });

    test('italic inside bold composes the same way', () {
      expect(
        parseCvMarkup('**a *b* c**'),
        _runs([('a ', 'b'), ('b', 'bi'), (' c', 'b')]),
      );
    });
  });

  group('parseCvMarkup - stray delimiters stay literal -', () {
    test('multiplication with spaces is not emphasis', () {
      expect(
        parseCvMarkup('Scaled 3 * 4 clusters'),
        _runs([('Scaled 3 * 4 clusters', '')]),
      );
    });

    test('two spaced delimiters are still not emphasis', () {
      expect(parseCvMarkup('a * b * c'), _runs([('a * b * c', '')]));
    });

    test('an unclosed opener prints', () {
      expect(parseCvMarkup('**unclosed'), _runs([('**unclosed', '')]));
    });

    test('a trailing asterisk prints', () {
      expect(parseCvMarkup('grade A*'), _runs([('grade A*', '')]));
    });

    test('a lone asterisk prints', () {
      expect(parseCvMarkup('*'), _runs([('*', '')]));
    });

    test('leftover asterisks sit outside the pair they did not join', () {
      expect(parseCvMarkup('***a**'), _runs([('*', ''), ('a', 'b')]));
    });
  });

  group('parseCvMarkup - the intraword rule -', () {
    // The rule exists for this: an A-level grade is a realistic
    // `Education.grade`, and plain CommonMark flanking italicises it.
    test('A*A*A is a grade, not emphasis', () {
      expect(parseCvMarkup('A*A*A'), _runs([('A*A*A', '')]));
    });

    test('a grade in a longer line is untouched', () {
      expect(
        parseCvMarkup('A Levels: A*A*A in Maths'),
        _runs([('A Levels: A*A*A in Maths', '')]),
      );
    });

    test('intraword emphasis is refused even when well-formed', () {
      expect(parseCvMarkup('super*script*'), _runs([('super*script*', '')]));
    });

    test('word-boundary emphasis still works beside punctuation', () {
      expect(
        parseCvMarkup('(**note**)'),
        _runs([('(', ''), ('note', 'b'), (')', '')]),
      );
    });
  });

  group('parseCvMarkup - escapes -', () {
    test(r'\* prints a literal asterisk and never opens', () {
      expect(
        parseCvMarkup(r'\*not emphasis\*'),
        _runs([('*not emphasis*', '')]),
      );
    });

    test('an escaped grade is a way out of the intraword rule', () {
      expect(parseCvMarkup(r'A\*A\*A'), _runs([('A*A*A', '')]));
    });

    test('a Windows path survives byte-for-byte', () {
      expect(
        parseCvMarkup(r'C:\Users\jordan'),
        _runs([(r'C:\Users\jordan', '')]),
      );
    });

    test('a UNC path survives byte-for-byte', () {
      expect(
        parseCvMarkup(r'\\server\share'),
        _runs([(r'\\server\share', '')]),
      );
    });
  });

  group('parseCvMarkup - underscores are never emphasis -', () {
    test('snake_case is untouched', () {
      expect(
        parseCvMarkup('Owned the user_events_v2 pipeline'),
        _runs([('Owned the user_events_v2 pipeline', '')]),
      );
    });

    test('a dunder name is untouched', () {
      expect(parseCvMarkup('__init__'), _runs([('__init__', '')]));
    });

    test('_x_ is literal, not italic', () {
      expect(parseCvMarkup('_x_'), _runs([('_x_', '')]));
    });
  });

  group('parseCvMarkup - unicode -', () {
    test('a currency amount emphasises without disturbing the symbol', () {
      expect(
        parseCvMarkup('Saved **€2m** annually'),
        _runs([('Saved ', ''), ('€2m', 'b'), (' annually', '')]),
      );
    });

    test('an accented word obeys the intraword rule', () {
      expect(parseCvMarkup('Ü*Ü*Ü'), _runs([('Ü*Ü*Ü', '')]));
    });

    test('a surrogate pair is never split across runs', () {
      final runs = parseCvMarkup('**🚀 launch**');
      expect(runs, _runs([('🚀 launch', 'b')]));
      // Re-joining must reproduce the emoji exactly, not two halves.
      expect(runs.map((r) => r.text).join(), '🚀 launch');
    });

    test('a non-breaking space blocks emphasis like a plain space', () {
      expect(parseCvMarkup('a *\u00a0b*'), _runs([('a *\u00a0b*', '')]));
    });
  });

  group('stripCvMarkup -', () {
    test('removes the markers', () {
      expect(stripCvMarkup('**a**'), 'a');
    });

    test('an all-marker field keeps its markers, because they print', () {
      // Unmatched delimiters are literal text, so a field of nothing but
      // markers is visible content rather than an invisible entry. This
      // is why `CvVaultPruning._isBlank` needs no markup awareness — see
      // the invariant test below, which pins the general rule.
      expect(stripCvMarkup('**'), '**');
      expect(stripCvMarkup('***'), '***');
    });

    test('leaves literal asterisks alone', () {
      expect(stripCvMarkup('3 * 4'), '3 * 4');
      expect(stripCvMarkup('A*A*A'), 'A*A*A');
    });

    test('resolves an escape to the character it prints', () {
      expect(stripCvMarkup(r'\*'), '*');
    });

    test('text with no asterisk is returned unchanged', () {
      expect(stripCvMarkup('nothing here'), 'nothing here');
    });
  });

  group('the load-bearing invariant -', () {
    // Everything downstream — search, blank detection, the LLM length
    // budget — compares against stripCvMarkup while the PDF draws the
    // runs. If the two ever disagree about what a string says, those
    // features go subtly wrong rather than loudly wrong.
    const cases = [
      '',
      'plain',
      '**bold**',
      '*italic*',
      '***both***',
      'Cut **p99** by *40%*',
      '*a **b** c*',
      '3 * 4 = 12',
      '**unclosed',
      'grade A*',
      'A*A*A',
      r'\*escaped\*',
      r'C:\Users\jordan',
      '***a**',
      'snake_case_name',
      '**🚀**',
      '****quad****',
      '*',
      '**',
      'a * b * c',
    ];

    for (final source in cases) {
      test('stripCvMarkup equals the joined runs for "$source"', () {
        expect(
          stripCvMarkup(source),
          parseCvMarkup(source).map((r) => r.text).join(),
        );
      });
    }

    test('nothing non-empty ever strips to empty', () {
      // Structural, not incidental: a maximal run of asterisks is
      // consumed at once, so two delimiter runs can never be adjacent,
      // so a matched pair always has at least one character between it.
      // Anything left over is literal. That is what lets every blank
      // check in the app keep comparing raw strings.
      for (final source in [...cases, '*', '**', '***', '****', '** **']) {
        if (source.isEmpty) continue;
        expect(
          stripCvMarkup(source),
          isNotEmpty,
          reason: '"$source" stripped to nothing',
        );
      }
    });

    test('parsing removes exactly the markers it consumed, and no other '
        'character', () {
      // The earlier, weaker form of this only checked the output had
      // not grown, which let a real bug through: a delimiter stranded
      // inside a pair that closed over it was dropped from the text
      // rather than only from the matcher, so `*a*a*` printed "aa" and
      // lost an asterisk someone had typed.
      for (final source in [...cases, '*a*a*', '*a*b*c*', '**a*b**']) {
        final printed = parseCvMarkup(source).map((r) => r.text).join();
        // Every character that is not punctuation the parser owns
        // survives verbatim, in order.
        final punctuation = RegExp(r'[*\\]');
        expect(
          printed.replaceAll(punctuation, ''),
          source.replaceAll(punctuation, ''),
          reason: 'parsing "$source" altered its words',
        );
      }
    });
  });
}
