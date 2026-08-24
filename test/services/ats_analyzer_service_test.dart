import 'package:cv_forge/models/ats/ats_document_info.dart';
import 'package:cv_forge/models/ats/ats_extracted_document.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/ats/ats_font_info.dart';
import 'package:cv_forge/models/ats/ats_link_annotation.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/ats_analyzer_service.dart';
import 'package:cv_forge/models/document/document_strings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

/// Fixture geometry below is copied from real `pdf.js` output captured
/// during the ATS-analyzer spike (a probe run against synthetic PDFs
/// generated with `package:pdf`, plus cv-forge's own PDF export) — not
/// invented numbers. This is what keeps `AtsAnalyzerService` regression-
/// tested on the Flutter VM despite the extraction layer it consumes only
/// running in a browser; see `PdfExtractionService`'s doc comment.
AtsTextNode _node({
  required String str,
  required double x,
  required double y,
  required double width,
  double fontSize = 10,
  int pageIndex = 0,
  String fontName = 'g_d0_f1',
}) => AtsTextNode(
  pageIndex: pageIndex,
  str: str,
  transform: AtsTextMatrix(a: fontSize, b: 0, c: 0, d: fontSize, e: x, f: y),
  width: width,
  fontName: fontName,
);

AtsExtractedDocument _doc({
  required List<AtsTextNode> nodes,
  int pageCount = 1,
  Map<String, AtsFontInfo> fonts = const {},
  List<AtsLinkAnnotation> links = const [],
}) => AtsExtractedDocument(
  info: AtsDocumentInfo(pageCount: pageCount),
  nodes: nodes,
  fonts: fonts,
  links: links,
);

void main() {
  // AtsAnalyzerService bakes each finding's user-facing copy in at
  // construction, so it resolves LocalizationService from the locator —
  // which means it can only be built once the locator is populated, not at
  // main() scope the way it used to be.
  late AtsAnalyzerService service;

  setUp(() {
    registerServices();
    service = AtsAnalyzerService();
  });
  tearDown(() => locator.reset());

  group('AtsAnalyzerServiceTest - no text layer', () {
    test('zero nodes across the whole document is a critical finding', () {
      final result = service.analyze(_doc(nodes: []));

      expect(
        result.findings,
        contains(
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.noTextLayer &&
                f.severity == AtsFindingSeverity.critical &&
                f.pageIndex == null,
          ),
        ),
      );
    });

    test('a page with no nodes while another page has text is a warning', () {
      final result = service.analyze(
        _doc(
          pageCount: 2,
          nodes: [_node(str: 'Jordan Ellery', x: 56.69, y: 769.8, width: 145)],
        ),
      );

      expect(
        result.findings,
        contains(
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.noTextLayer &&
                f.severity == AtsFindingSeverity.warning &&
                f.pageIndex == 1,
          ),
        ),
      );
    });

    test('a single populated page raises no per-page finding', () {
      final result = service.analyze(
        _doc(
          nodes: [_node(str: 'Jordan Ellery', x: 56.69, y: 769.8, width: 145)],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.noTextLayer,
        ),
        isEmpty,
      );
    });
  });

  group('AtsAnalyzerServiceTest - column crush', () {
    test(
      'two runs sharing a baseline with a wide gap (the spike Skills / '
      'Experience two-column fixture, real captured geometry) is flagged',
      () {
        final result = service.analyze(
          _doc(
            nodes: [
              _node(
                str: 'Skills',
                x: 56.69,
                y: 774.61,
                width: 28.74,
                fontSize: 11,
              ),
              _node(
                str: 'Dart and Flutter',
                x: 82.2,
                y: 760.93,
                width: 83.36,
                fontSize: 12,
              ),
              _node(
                str: 'Experience',
                x: 337.64,
                y: 774.61,
                width: 58.7,
                fontSize: 11,
              ),
            ],
          ),
        );

        expect(
          result.findings,
          contains(
            predicate<AtsFinding>(
              (f) => f.category == AtsFindingCategory.columnCrush,
            ),
          ),
        );

        final finding = result.findings.singleWhere(
          (f) => f.category == AtsFindingCategory.columnCrush,
        );
        expect(finding.evidenceShape, AtsEvidenceShape.span);
        // "Skills" (index 0) and "Experience" (index 2) are the crushed
        // pair — "Dart and Flutter" (index 1) sits on a different line
        // entirely and must not be pulled in as evidence.
        expect(
          finding.evidence,
          containsAll([
            const AtsFindingEvidence(pageIndex: 0, nodeIndex: 0),
            const AtsFindingEvidence(pageIndex: 0, nodeIndex: 2),
          ]),
        );
        expect(finding.evidence, hasLength(2));
      },
    );

    test('an ordinary single-column line (the spike single_column.pdf '
        'fixture, real captured geometry) raises no column-crush finding', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(
              str: 'Jordan Alex Rivera',
              x: 56.69,
              y: 769.8,
              width: 144.94,
              fontSize: 16,
            ),
            _node(
              str: 'Senior Widget Engineer, Acme Corp (Jan 2022 - Present)',
              x: 56.69,
              y: 731.76,
              width: 255.1,
            ),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.columnCrush,
        ),
        isEmpty,
      );
    });

    test('an entry title with its date range right-aligned on the same line '
        'is NOT flagged — merging that pair left-to-right yields the '
        'correct reading, and every template this app ships produces it', () {
      // Geometry lifted from a real `photo_header` export: body prose
      // reaching x~530 above and below, and two entry lines whose date
      // sits hard against the right margin.
      final result = service.analyze(
        _doc(
          nodes: [
            for (var i = 0; i < 6; i++)
              _node(
                str:
                    'Backend engineer with nine years building payment '
                    'systems that stay up.',
                x: 57,
                y: 700.0 - i * 16.3,
                width: 473,
                fontSize: 12,
              ),
            // The crushed-looking pair: a short title, then the date
            // right-aligned to the same margin the prose reaches.
            _node(
              str: 'BSc Computer Science at University of Leeds',
              x: 57,
              y: 560,
              width: 268,
              fontSize: 12,
            ),
            _node(str: '2015', x: 513, y: 560, width: 25, fontSize: 12),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.columnCrush,
        ),
        isEmpty,
      );
    });

    test('a genuine sidebar still flags even when a full-width name above '
        'it crosses the gutter — one crossing line does not make a '
        'corridor into body text', () {
      final result = service.analyze(
        _doc(
          nodes: [
            // Full-width name across the top, crossing the gutter at x~300.
            _node(
              str: 'Jordan Alex Rivera',
              x: 57,
              y: 760,
              width: 460,
              fontSize: 16,
            ),
            // Two columns beneath: nothing crosses x~300 again.
            for (var i = 0; i < 8; i++) ...[
              _node(
                str: 'Left column line',
                x: 57,
                y: 720.0 - i * 14,
                width: 150,
                fontSize: 11,
              ),
              _node(
                str: 'Right column line',
                x: 340,
                y: 720.0 - i * 14,
                width: 170,
                fontSize: 11,
              ),
            ],
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.columnCrush,
        ),
        isNotEmpty,
      );
    });

    test('two words on the same line with a normal word gap is not flagged '
        'as a crush', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: 'Senior', x: 56.69, y: 700, width: 30),
            _node(str: 'Engineer', x: 90, y: 700, width: 40),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.columnCrush,
        ),
        isEmpty,
      );
    });
  });

  group('AtsAnalyzerServiceTest - garbled text', () {
    test('a replacement character (U+FFFD) is a critical finding', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: 'Man\u{FFFD}aged a team', x: 56.69, y: 700, width: 90),
          ],
        ),
      );

      expect(
        result.findings,
        contains(
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.garbledText &&
                f.severity == AtsFindingSeverity.critical,
          ),
        ),
      );

      final finding = result.findings.singleWhere(
        (f) =>
            f.category == AtsFindingCategory.garbledText &&
            f.severity == AtsFindingSeverity.critical,
      );
      expect(finding.evidenceShape, AtsEvidenceShape.scattered);
      expect(finding.evidence, [
        const AtsFindingEvidence(pageIndex: 0, nodeIndex: 0),
      ]);
    });

    test('a leading PUA glyph (a bullet, the shape a leading bullet glyph '
        'took when pdf.js chunked it into the same run as the text that '
        'follows it) is not flagged', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(
              str: '\u{F0B7} Led the migration effort.',
              x: 64.47,
              y: 762.11,
              width: 105.61,
            ),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.garbledText,
        ),
        isEmpty,
      );
    });

    test('a PUA glyph embedded mid-word is a warning finding', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: 'Man\u{F0B7}aged a team', x: 56.69, y: 700, width: 90),
          ],
        ),
      );

      expect(
        result.findings,
        contains(
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.garbledText &&
                f.severity == AtsFindingSeverity.warning,
          ),
        ),
      );

      final finding = result.findings.singleWhere(
        (f) =>
            f.category == AtsFindingCategory.garbledText &&
            f.severity == AtsFindingSeverity.warning,
      );
      expect(finding.evidenceShape, AtsEvidenceShape.scattered);
      expect(finding.evidence, [
        const AtsFindingEvidence(pageIndex: 0, nodeIndex: 0),
      ]);
    });

    test('a short run whose width implies characters the extracted string '
        "does not have (a dropped glyph that left one surviving visible "
        'character) is an info-level finding — the known limitation is '
        'this only catches an isolated short run, not a dropped glyph '
        'merged into a longer sentence run, which the spike’s real '
        'capture happened to produce; see '
        'AtsAnalyzerService._checkGarbledText', () {
      final result = service.analyze(
        // A run with an 18pt advance but only one surviving character —
        // the shape a dropped glyph next to a surviving one leaves.
        _doc(
          nodes: [_node(str: 'x', x: 56.69, y: 700, width: 18, fontSize: 10)],
        ),
      );

      expect(
        result.findings,
        contains(
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.garbledText &&
                f.severity == AtsFindingSeverity.info,
          ),
        ),
      );

      final finding = result.findings.singleWhere(
        (f) =>
            f.category == AtsFindingCategory.garbledText &&
            f.severity == AtsFindingSeverity.info,
      );
      expect(finding.evidenceShape, AtsEvidenceShape.scattered);
      expect(finding.evidence, [
        const AtsFindingEvidence(pageIndex: 0, nodeIndex: 0),
      ]);
    });

    test('a wide PURE-whitespace run is never flagged as a phantom glyph — '
        'regression test for a real false positive found against '
        'cv-forge’s own exported PDFs: justified/right-aligned text pads a '
        'line to width with exactly one wide single-space run (confirmed '
        'via a real extraction: str " " at width 138-329pt, fontSize '
        '10.5pt), which has no missing characters to have dropped in the '
        'first place', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: ' ', x: 56.69, y: 700, width: 212.45, fontSize: 10.5),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.garbledText,
        ),
        isEmpty,
      );
    });

    test('ordinary text with a non-embedded font raises no garbled finding '
        'on its own — a non-embedded standard font extracts perfectly '
        'cleanly (the spike single_column.pdf fixture: Helvetica, '
        'missingFile: true)', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(
              str: 'Senior Widget Engineer, Acme Corp (Jan 2022 - Present)',
              x: 56.69,
              y: 731.76,
              width: 255.1,
            ),
          ],
          fonts: const {'g_d0_f1': AtsFontInfo(missingFile: true)},
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.garbledText,
        ),
        isEmpty,
      );
    });
  });

  group('AtsAnalyzerServiceTest - missing headings', () {
    test('a document mentioning none of the canonical headings gets a '
        'finding per missing heading', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(
              str: 'Jordan Ellery, a very good person indeed',
              x: 0,
              y: 0,
              width: 100,
            ),
          ],
        ),
      );

      final missing = result.findings.where(
        (f) => f.category == AtsFindingCategory.missingHeadings,
      );
      expect(missing, hasLength(3)); // Experience, Education, Skills
    });

    test('a document containing all three canonical headings gets no '
        'missing-heading findings', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: 'Experience', x: 0, y: 30, width: 50),
            _node(str: 'Education', x: 0, y: 20, width: 50),
            _node(str: 'Skills', x: 0, y: 10, width: 50),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.missingHeadings,
        ),
        isEmpty,
      );
    });

    test('a CV this app exported in Spanish analyses clean — the headings '
        'are matched in every language the app can write one in, not just '
        'English', () {
      final spanish = DocumentLanguage.es419.strings;
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: spanish.experience, x: 0, y: 30, width: 50),
            _node(str: spanish.education, x: 0, y: 20, width: 50),
            _node(str: spanish.skills, x: 0, y: 10, width: 50),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) => f.category == AtsFindingCategory.missingHeadings,
        ),
        isEmpty,
      );
    });

    test('every shipped document language is covered, so adding one cannot '
        'quietly start failing its own exports', () {
      for (final language in DocumentLanguage.values) {
        final strings = language.strings;
        final result = service.analyze(
          _doc(
            nodes: [
              _node(str: strings.experience, x: 0, y: 30, width: 50),
              _node(str: strings.education, x: 0, y: 20, width: 50),
              _node(str: strings.skills, x: 0, y: 10, width: 50),
            ],
          ),
        );

        expect(
          result.findings.where(
            (f) => f.category == AtsFindingCategory.missingHeadings,
          ),
          isEmpty,
          reason: '${language.name} headings were not recognised',
        );
      }
    });
  });

  group('AtsAnalyzerServiceTest - contact info', () {
    test('no email and no phone anywhere raises both findings', () {
      final result = service.analyze(
        _doc(nodes: [_node(str: 'Jordan Ellery', x: 0, y: 0, width: 100)]),
      );

      expect(
        result.findings,
        containsAll([
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.contactInfo &&
                f.severity == AtsFindingSeverity.critical,
          ),
          predicate<AtsFinding>(
            (f) =>
                f.category == AtsFindingCategory.contactInfo &&
                f.severity == AtsFindingSeverity.warning,
          ),
        ]),
      );
    });

    test('an email recoverable only via a mailto: Link annotation — the '
        'spike’s real-PDF finding — suppresses the missing-email '
        'finding', () {
      final result = service.analyze(
        _doc(
          nodes: [_node(str: 'Jordan Ellery', x: 0, y: 0, width: 100)],
          links: const [
            AtsLinkAnnotation(
              pageIndex: 0,
              url: 'mailto:jordan.ellery@example.com',
            ),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) =>
              f.category == AtsFindingCategory.contactInfo &&
              f.severity == AtsFindingSeverity.critical,
        ),
        isEmpty,
      );
    });

    test('an email found directly in extracted text suppresses the '
        'missing-email finding', () {
      final result = service.analyze(
        _doc(
          nodes: [
            _node(str: 'jordan.ellery@example.com', x: 0, y: 0, width: 100),
          ],
        ),
      );

      expect(
        result.findings.where(
          (f) =>
              f.category == AtsFindingCategory.contactInfo &&
              f.severity == AtsFindingSeverity.critical,
        ),
        isEmpty,
      );
    });
  });

  group('AtsAnalyzerServiceTest - findings ordering', () {
    test('findings are ordered most-severe first', () {
      final result = service.analyze(_doc(nodes: []));

      // AtsFindingSeverity is declared critical, warning, info — the
      // enum's declaration order already is display-priority order.
      final ranks = result.findings.map((f) => f.severity.index).toList();
      final sorted = [...ranks]..sort();
      expect(ranks, sorted);
    });
  });
}
