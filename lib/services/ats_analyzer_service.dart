import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/services/localization_service.dart';
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
  /// Findings carry their own user-facing copy, baked in at
  /// construction (see [AtsFinding.title]/[AtsFinding.message]), so
  /// this service needs strings without a `BuildContext` — which is
  /// the whole reason `LocalizationService` is a locator entry rather
  /// than something that lives on the widget tree.
  final _l10n = locator<LocalizationService>();

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
        AtsFinding(
          category: AtsFindingCategory.noTextLayer,
          severity: AtsFindingSeverity.critical,
          title: _l10n.strings.atsFindingNoTextLayerTitle,
          message: _l10n.strings.atsFindingNoTextLayerBody,
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
            title: _l10n.strings.atsFindingPageNoTextTitle(page + 1),
            message: _l10n.strings.atsFindingPageNoTextBody(page + 1),
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
  ///
  /// A wide gap on its own is not enough, because the commonest CV idiom
  /// there is — an entry title with its date range right-aligned on the
  /// same line — produces one. Merging *that* pair left-to-right yields
  /// the correct reading ("BSc Computer Science at Leeds" then "2015"),
  /// so flagging it is a false positive; every template this app ships
  /// used to trip it, `compact` included, which is the default and is
  /// tagged ATS-safe.
  ///
  /// Two things have to be true together for a gap to be dismissed, and
  /// both were measured against real exports rather than reasoned about:
  ///
  ///  - the right-hand run ends flush with the page's rightmost text edge,
  ///    which is what "right-aligned trailing value" means and what every
  ///    date on every template does (measured: 0.0pt from the edge);
  ///  - something else on the page crosses the gap, so it is a hole in
  ///    ordinary text area rather than a gutter running down a column
  ///    boundary (measured: 3 other lines cross it; a genuine two-column
  ///    fixture has none).
  ///
  /// Requiring both keeps this conservative — it errs toward reporting.
  /// A sidebar whose one line happens to reach the right margin is still
  /// caught through its other lines, since a finding is emitted per
  /// crushed line.
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

      // Group into lines first, then judge gaps — deciding whether a gap
      // is a corridor needs every other line on the page, so the lines
      // cannot be evaluated as they are found.
      final lines = <List<(int, AtsTextNode)>>[];
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
        line.sort(
          (a, b) =>
              a.$2.transform.baselineX.compareTo(b.$2.transform.baselineX),
        );
        lines.add(line);
      }

      final pageRightEdge = nodes
          .map((n) => n.$2.transform.baselineX + n.$2.width)
          .reduce((a, b) => a > b ? a : b);

      for (var l = 0; l < lines.length; l++) {
        final line = lines[l];
        if (line.length < 2) continue;

        for (var k = 0; k < line.length - 1; k++) {
          final (leftIndex, left) = line[k];
          final (rightIndex, right) = line[k + 1];
          final leftEnd = left.transform.baselineX + left.width;
          final gap = right.transform.baselineX - leftEnd;
          if (gap <= _columnGapThreshold) continue;
          if (_isRightAlignedTrailingValue(
            lines,
            line: l,
            right: right,
            corridorX: leftEnd + gap / 2,
            pageRightEdge: pageRightEdge,
          )) {
            continue;
          }

          findings.add(
            AtsFinding(
              category: AtsFindingCategory.columnCrush,
              severity: AtsFindingSeverity.warning,
              title: _l10n.strings.atsFindingColumnCrushTitle,
              message: _l10n.strings.atsFindingColumnCrushBody(
                _truncate(left.str),
                _truncate(right.str),
                '${_truncate(left.str)}${_truncate(right.str)}',
              ),
              pageIndex: entry.key,
              evidence: [
                AtsFindingEvidence(pageIndex: entry.key, nodeIndex: leftIndex),
                AtsFindingEvidence(pageIndex: entry.key, nodeIndex: rightIndex),
              ],
              evidenceShape: AtsEvidenceShape.span,
            ),
          );
          break; // one finding per crushed line is enough signal
        }
      }
    }
    return findings;
  }

  /// Whether this gap is an entry title with a right-aligned date after
  /// it, rather than a column boundary. See [_checkColumnCrush] for the
  /// measurements behind the two conditions.
  bool _isRightAlignedTrailingValue(
    List<List<(int, AtsTextNode)>> lines, {
    required int line,
    required AtsTextNode right,
    required double corridorX,
    required double pageRightEdge,
  }) {
    final endsAtMargin =
        (pageRightEdge - (right.transform.baselineX + right.width)).abs() <=
        _rightAlignTolerance;
    if (!endsAtMargin) return false;

    for (var i = 0; i < lines.length; i++) {
      if (i == line) continue;
      final crosses = lines[i].any((n) {
        final start = n.$2.transform.baselineX;
        return start < corridorX && corridorX < start + n.$2.width;
      });
      if (crosses) return true;
    }
    return false;
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
          title: _l10n.strings.atsFindingGarbledTitle,
          message: _l10n.strings.atsFindingGarbledBody(replacementCount),
          evidence: replacementEvidence,
        ),
      );
    }
    if (embeddedPuaCount > 0) {
      findings.add(
        AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.warning,
          title: _l10n.strings.atsFindingIconFontTitle,
          message: _l10n.strings.atsFindingIconFontBody(embeddedPuaCount),
          evidence: embeddedPuaEvidence,
        ),
      );
    }
    if (phantomGlyphCount > 0) {
      findings.add(
        AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.info,
          title: _l10n.strings.atsFindingDroppedCharsTitle,
          message: _l10n.strings.atsFindingDroppedCharsBody(phantomGlyphCount),
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
        AtsFinding(
          category: AtsFindingCategory.garbledText,
          severity: AtsFindingSeverity.info,
          title: _l10n.strings.atsFindingNonEmbeddedFontTitle,
          message: _l10n.strings.atsFindingNonEmbeddedFontBody,
        ),
      );
    }

    return findings;
  }

  List<AtsFinding> _checkMissingHeadings(AtsExtractedDocument document) {
    final text = document.nodes.map((n) => n.str).join(' ').toLowerCase();
    final findings = <AtsFinding>[];

    // `keywords` are matched against the uploaded PDF's own text, which
    // this app always writes in English (CLAUDE.md: the document's language
    // is a separate axis from the UI's), so they stay English whatever the
    // locale. `id` only selects the ICU branch used for display.
    const sections = [
      (
        id: 'experience',
        keywords: ['experience', 'work history', 'employment'],
      ),
      (id: 'education', keywords: ['education']),
      (id: 'skills', keywords: ['skills', 'competencies']),
    ];

    for (final section in sections) {
      final found = section.keywords.any(text.contains);
      if (!found) {
        findings.add(
          AtsFinding(
            category: AtsFindingCategory.missingHeadings,
            severity: AtsFindingSeverity.info,
            title: _l10n.strings.atsFindingMissingHeadingTitle(section.id),
            message: _l10n.strings.atsFindingMissingHeadingBody(section.id),
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
        AtsFinding(
          category: AtsFindingCategory.contactInfo,
          severity: AtsFindingSeverity.critical,
          title: _l10n.strings.atsFindingNoEmailTitle,
          message: _l10n.strings.atsFindingNoEmailBody,
        ),
      );
    }

    final hasPhoneText = _phonePattern.hasMatch(text);
    final hasPhoneLink = document.links.any((l) => l.url.startsWith('tel:'));
    if (!hasPhoneText && !hasPhoneLink) {
      findings.add(
        AtsFinding(
          category: AtsFindingCategory.contactInfo,
          severity: AtsFindingSeverity.warning,
          title: _l10n.strings.atsFindingNoPhoneTitle,
          message: _l10n.strings.atsFindingNoPhoneBody,
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

  /// How close a run's end has to be to the page's rightmost text edge to
  /// count as right-aligned. Measured at 0.0pt on this app's own exports;
  /// the allowance is for extractor rounding, not for near-misses.
  static const _rightAlignTolerance = 2.0;

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
