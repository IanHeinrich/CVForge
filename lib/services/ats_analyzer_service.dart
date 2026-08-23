import 'package:cv_forge/models/ats/ats_extracted_document.dart';
import 'package:cv_forge/models/ats/ats_analysis_result.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';

/// Analyzes an already-extracted PDF for the format problems that make an
/// ATS text extractor misread a resume. Pure Dart, no dependencies — the
/// counterpart to `PdfExtractionService`'s browser-only marshalling, and
/// fully testable on the Flutter VM.
///
/// Ships a reduced check set — see [AtsFindingCategory]'s doc comment
/// for what was cut and why.
class AtsAnalyzerService {
  AtsAnalysisResult analyze(AtsExtractedDocument document) {
    final findings = <AtsFinding>[
      ..._checkNoTextLayer(document),
      ..._checkColumnCrush(document),
      ..._checkGarbledText(document),
      ..._checkMissingHeadings(document),
      ..._checkContactInfo(document),
    ];
    // AtsFindingSeverity is declared critical, warning, info — the
    // enum's declaration order already is display-priority order.
    findings.sort((a, b) => a.severity.index - b.severity.index);

    return AtsAnalysisResult(
      info: document.info,
      totalNodeCount: document.nodes.length,
      findings: findings,
    );
  }

  List<AtsFinding> _checkNoTextLayer(AtsExtractedDocument document) {
    if (document.nodes.isEmpty) {
      return [
        const AtsFinding(
          category: AtsFindingCategory.noTextLayer,
          severity: AtsFindingSeverity.critical,
          title: 'No extractable text found',
          message:
              'This PDF has no text layer at all — likely a scanned image. '
              'Most ATS software will read this as a completely blank '
              'resume.',
        ),
      ];
    }

    final findings = <AtsFinding>[];
    final pagesWithText = document.nodes.map((n) => n.pageIndex).toSet();
    for (var page = 0; page < document.info.pageCount; page++) {
      if (!pagesWithText.contains(page)) {
        findings.add(
          AtsFinding(
            category: AtsFindingCategory.noTextLayer,
            severity: AtsFindingSeverity.warning,
            title: 'Page ${page + 1} has no extractable text',
            message:
                'Page ${page + 1} contributed no text at all, while other '
                'pages did — an ATS will likely skip this page entirely.',
            pageIndex: page,
          ),
        );
      }
    }
    return findings;
  }

  /// Simulates a position-sorting text extractor (e.g. PDFBox with
  /// `setSortByPosition(true)`) by clustering runs sharing a baseline and
  /// checking for a wide horizontal gap between two runs on it — the
  /// signature a multi-column layout leaves when re-read left-to-right
  /// regardless of which block a run actually belongs to. This is *not*
  /// a claim about `pdf.js`'s own reading order, which tracks the content
  /// stream faithfully.
  List<AtsFinding> _checkColumnCrush(AtsExtractedDocument document) {
    final findings = <AtsFinding>[];
    final byPage = <int, List<(int, AtsTextNode)>>{};
    for (var idx = 0; idx < document.nodes.length; idx++) {
      final node = document.nodes[idx];
      byPage.putIfAbsent(node.pageIndex, () => []).add((idx, node));
    }

    for (final entry in byPage.entries) {
      final nodes = [...entry.value]
        ..sort(
          (a, b) =>
              b.$2.transform.baselineY.compareTo(a.$2.transform.baselineY),
        );

      var i = 0;
      while (i < nodes.length) {
        final lineY = nodes[i].$2.transform.baselineY;
        final fontSize = nodes[i].$2.transform.fontSize;
        final tolerance = fontSize > 0 ? fontSize * 0.3 : 3.0;

        final line = <(int, AtsTextNode)>[];
        var j = i;
        while (j < nodes.length &&
            (nodes[j].$2.transform.baselineY - lineY).abs() <= tolerance) {
          line.add(nodes[j]);
          j++;
        }
        i = j;

        if (line.length < 2) continue;
        line.sort(
          (a, b) =>
              a.$2.transform.baselineX.compareTo(b.$2.transform.baselineX),
        );

        for (var k = 0; k < line.length - 1; k++) {
          final (leftIndex, left) = line[k];
          final (rightIndex, right) = line[k + 1];
          final gap =
              right.transform.baselineX -
              (left.transform.baselineX + left.width);
          if (gap > _columnGapThreshold) {
            findings.add(
              AtsFinding(
                category: AtsFindingCategory.columnCrush,
                severity: AtsFindingSeverity.warning,
                title: 'Possible multi-column layout',
                message:
                    '"${_truncate(left.str)}" and "${_truncate(right.str)}" '
                    'sit on the same line with a wide gap between them. A '
                    'text extractor that reads by position rather than by '
                    'the document\'s own structure may merge these into '
                    'one run, e.g. "${_truncate(left.str)}'
                    '${_truncate(right.str)}".',
                pageIndex: entry.key,
                evidence: [
                  AtsFindingEvidence(
                    pageIndex: entry.key,
                    nodeIndex: leftIndex,
                  ),
                  AtsFindingEvidence(
                    pageIndex: entry.key,
                    nodeIndex: rightIndex,
                  ),
                ],
                evidenceShape: AtsEvidenceShape.span,
              ),
            );
            break; // one finding per crushed line is enough signal
          }
        }
      }
    }
    return findings;
  }

  List<AtsFinding> _checkGarbledText(AtsExtractedDocument document) {
    final findings = <AtsFinding>[];
    var replacementCount = 0;
    var embeddedPuaCount = 0;
    var phantomGlyphCount = 0;
    final replacementEvidence = <AtsFindingEvidence>[];
    final embeddedPuaEvidence = <AtsFindingEvidence>[];
    final phantomGlyphEvidence = <AtsFindingEvidence>[];

    for (var idx = 0; idx < document.nodes.length; idx++) {
      final node = document.nodes[idx];
      final str = node.str;
      final nodeReplacementCount = _countCodeUnits(str, _isReplacementChar);
      replacementCount += nodeReplacementCount;
      if (nodeReplacementCount > 0) {
        replacementEvidence.add(
          AtsFindingEvidence(pageIndex: node.pageIndex, nodeIndex: idx),
        );
      }

      // A PUA glyph as the first character of a run reads as a bullet,
      // not garbled text: pdf.js chunks a leading bullet glyph into the
      // same run as the text that follows it. A PUA glyph anywhere else
      // in the run is the garbled case.
      var nodeHasEmbeddedPua = false;
      for (var i = 1; i < str.length; i++) {
        if (_isPua(str.codeUnitAt(i))) {
          embeddedPuaCount++;
          nodeHasEmbeddedPua = true;
        }
      }
      if (nodeHasEmbeddedPua) {
        embeddedPuaEvidence.add(
          AtsFindingEvidence(pageIndex: node.pageIndex, nodeIndex: idx),
        );
      }

      // "Phantom glyph": an advance width spent with implausibly few
      // characters to show for it — the failure a non-embedded-font PUA
      // bullet produces, leaving a nonzero width and zero surviving
      // characters rather than a visible PUA/replacement codepoint. Only
      // checked on short runs with at least
      // one non-whitespace character: a *pure*-whitespace run (`trimmed`
      // empty) never had any characters to drop in the first place, and a
      // wide single-space run is a completely ordinary PDF layout
      // technique for justification/alignment — confirmed a real false
      // positive against cv-forge's own generated PDFs, which pad a line
      // to width with exactly this kind of run.
      final fontSize = node.transform.fontSize;
      final trimmed = str.trim();
      if (fontSize > 0 && trimmed.isNotEmpty && trimmed.length <= 3) {
        final avgCharWidth = node.width / str.length;
        if (avgCharWidth > fontSize * 1.3) {
          phantomGlyphCount++;
          phantomGlyphEvidence.add(
            AtsFindingEvidence(pageIndex: node.pageIndex, nodeIndex: idx),
          );
        }
      }
    }

    if (replacementCount > 0) {
      findings.add(
        AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.critical,
          title: 'Unreadable characters found',
          message:
              'Found $replacementCount character(s) that failed to decode '
              'to readable text — the font used likely has a missing or '
              'broken character map. An ATS will see this text as garbage.',
          evidence: replacementEvidence,
        ),
      );
    }
    if (embeddedPuaCount > 0) {
      findings.add(
        AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.warning,
          title: 'Possible icon/symbol font glyphs in text',
          message:
              'Found $embeddedPuaCount character(s) from a private-use '
              'code range embedded within words — a common sign of an '
              'icon or symbol font (e.g. Wingdings) rather than real text, '
              'which most ATS parsers will render as blanks or gibberish.',
          evidence: embeddedPuaEvidence,
        ),
      );
    }
    if (phantomGlyphCount > 0) {
      findings.add(
        AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.info,
          title: 'Possible dropped characters',
          message:
              'Found $phantomGlyphCount short run(s) where more space was '
              'used than the extracted characters account for — a sign a '
              'symbol (often a bullet) silently failed to extract at all.',
          evidence: phantomGlyphEvidence,
        ),
      );
    }

    // Non-embedded fonts corroborate (but don't by themselves prove) a
    // garbled-text risk — surfaced only alongside a real textual signal
    // above, never on its own, since most non-embedded standard fonts
    // (Helvetica, Times) extract perfectly cleanly.
    if ((replacementCount > 0 || embeddedPuaCount > 0) &&
        document.fonts.values.any((f) => f.missingFile)) {
      findings.add(
        const AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.info,
          title: 'Non-embedded font in use',
          message:
              'This PDF relies on at least one font that is not embedded '
              'in the file. Combined with the unreadable text found above, '
              'this is a likely contributing cause.',
        ),
      );
    }

    return findings;
  }

  List<AtsFinding> _checkMissingHeadings(AtsExtractedDocument document) {
    final text = document.nodes.map((n) => n.str).join(' ').toLowerCase();
    final findings = <AtsFinding>[];

    const sections = [
      (
        label: 'Experience',
        keywords: ['experience', 'work history', 'employment'],
      ),
      (label: 'Education', keywords: ['education']),
      (label: 'Skills', keywords: ['skills', 'competencies']),
    ];

    for (final section in sections) {
      final found = section.keywords.any(text.contains);
      if (!found) {
        findings.add(
          AtsFinding(
            category: AtsFindingCategory.missingHeadings,
            severity: AtsFindingSeverity.info,
            title: 'No ${section.label} section detected',
            message:
                'Couldn\'t find a heading for ${section.label} anywhere in '
                'the document. Some ATS software structures a resume by '
                'matching canonical section headings, and may file this '
                'content as unstructured text if the heading is missing or '
                'phrased unusually.',
          ),
        );
      }
    }
    return findings;
  }

  static final _emailPattern = RegExp(r'[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}');
  static final _phonePattern = RegExp(r'(\+?\d[\d\s().-]{7,}\d)');

  List<AtsFinding> _checkContactInfo(AtsExtractedDocument document) {
    final text = document.nodes.map((n) => n.str).join(' ');
    final findings = <AtsFinding>[];

    final hasEmailText = _emailPattern.hasMatch(text);
    final hasEmailLink = document.links.any((l) => l.url.startsWith('mailto:'));
    if (!hasEmailText && !hasEmailLink) {
      findings.add(
        const AtsFinding(
          category: AtsFindingCategory.contactInfo,
          severity: AtsFindingSeverity.critical,
          title: 'No email address found',
          message:
              'Couldn\'t find an email address in the extracted text or in '
              'any clickable link. Most ATS software requires a readable '
              'email address to file an application.',
        ),
      );
    }

    final hasPhoneText = _phonePattern.hasMatch(text);
    final hasPhoneLink = document.links.any((l) => l.url.startsWith('tel:'));
    if (!hasPhoneText && !hasPhoneLink) {
      findings.add(
        const AtsFinding(
          category: AtsFindingCategory.contactInfo,
          severity: AtsFindingSeverity.warning,
          title: 'No phone number found',
          message:
              'Couldn\'t find a phone number in the extracted text or in '
              'any clickable link.',
        ),
      );
    }
    return findings;
  }

  /// PDF points. A gap this wide reads as two separate columns rather
  /// than intra-line word spacing — comfortably past a normal inter-word
  /// gap (a few points at typical body sizes) but inside a realistic
  /// column gutter. Absolute, not scaled by font size like the same-line
  /// tolerance above: a column gutter's width is a page-layout decision,
  /// not a text-size one.
  static const _columnGapThreshold = 60.0;

  bool _isPua(int codeUnit) => codeUnit >= 0xE000 && codeUnit <= 0xF8FF;

  bool _isReplacementChar(int codeUnit) => codeUnit == 0xFFFD;

  int _countCodeUnits(String str, bool Function(int) predicate) {
    var count = 0;
    for (var i = 0; i < str.length; i++) {
      if (predicate(str.codeUnitAt(i))) count++;
    }
    return count;
  }

  String _truncate(String str) =>
      str.length <= 24 ? str : '${str.substring(0, 24)}…';
}
