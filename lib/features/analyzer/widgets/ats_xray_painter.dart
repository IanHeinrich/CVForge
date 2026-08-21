import 'package:flutter/rendering.dart';

import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/ui/common/app_colors.dart';

/// How one [AtsXrayBox] should be drawn — three layers, painted in this
/// order so a selected/evidence box always sits visually on top of the
/// faint every-node backdrop rather than being drawn-over by it.
enum AtsXrayBoxStyle { ambient, evidence, selected }

/// One drawable box: a rect, how to style it, and (for [AtsXrayBoxStyle.
/// evidence]/[AtsXrayBoxStyle.selected]) the severity driving its colour.
/// `null` severity paints the faint ambient stroke regardless of [style].
typedef AtsXrayBox = ({
  AtsPixelRect rect,
  AtsXrayBoxStyle style,
  AtsFindingSeverity? severity,
});

/// The currently-selected finding's evidence, for the connector/hull drawn
/// over its boxes — see [AtsEvidenceShape]'s doc comment for why [span]
/// and [scattered] evidence are drawn differently.
typedef AtsXraySelection = ({List<AtsPixelRect> rects, AtsEvidenceShape shape});

/// Draws the X-Ray overlay's whole box layer in one pass: the faint
/// every-node backdrop, severity-coloured evidence boxes, the selected
/// finding's emphasis and span connector/hull, and (optionally) reading-
/// order flow lines — replacing the one-[Positioned]-[Container]-per-node
/// approach used to validate the coordinate math across a whole page
/// (`docs/ats-xray-overlay-handover.md` §6, step 3 → step 4). [Positioned]
/// widgets don't scale to hundreds of nodes on a dense page; a single
/// painter draws every box in one pass regardless of how many there are.
///
/// This is the first [CustomPainter] in the codebase — no established
/// convention to follow yet (see the handover doc §8's testing-strategy
/// notes).
class AtsXrayPainter extends CustomPainter {
  AtsXrayPainter(this.boxes, {this.showFlowLines = false, this.selection});

  final List<AtsXrayBox> boxes;

  /// Reading-order flow lines between consecutive [AtsXrayBoxStyle.
  /// ambient] boxes — i.e. every node, in extraction order, regardless of
  /// [selection]. Off by default: the spike measured up to ~400 nodes on a
  /// dense page, and lines for every one of them at once is noise unless
  /// a user has actually asked to see reading order.
  final bool showFlowLines;

  /// The selected finding's evidence, if any — drawn with a connector
  /// (`span`) or nothing extra beyond per-box emphasis (`scattered`); see
  /// [AtsXraySelection].
  final AtsXraySelection? selection;

  /// Low-opacity, same reasoning as step 3's `Container` borders: with a
  /// few hundred overlapping/adjacent boxes on a dense page, a
  /// full-opacity stroke would turn the backdrop into solid purple rather
  /// than something you can still read the text through to spot a
  /// misplaced box.
  static final _ambientPaint = Paint()
    ..color = kcPrimaryColor.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static final _flowLinePaint = Paint()
    ..color = kcWhite.withValues(alpha: 0.35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  static final _hullPaint = Paint()
    ..color = kcWhite.withValues(alpha: 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  Paint _evidencePaint(AtsFindingSeverity? severity, {required bool selected}) {
    return Paint()
      ..color = _severityColor(
        severity,
      ).withValues(alpha: selected ? 0.95 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = selected ? 3 : 2;
  }

  Color _severityColor(AtsFindingSeverity? severity) => switch (severity) {
    AtsFindingSeverity.critical => kcErrorColor,
    AtsFindingSeverity.warning => kcWarningColor,
    AtsFindingSeverity.info => kcLightGrey,
    null => kcPrimaryColor,
  };

  Rect _rectOf(AtsPixelRect r) =>
      Rect.fromLTRB(r.left, r.top, r.right, r.bottom);

  Offset _centerOf(AtsPixelRect r) => _rectOf(r).center;

  @override
  void paint(Canvas canvas, Size size) {
    // Ambient pass first so evidence/selected boxes paint on top of it,
    // never the reverse.
    final ambientCenters = <Offset>[];
    for (final box in boxes) {
      if (box.style != AtsXrayBoxStyle.ambient) continue;
      canvas.drawRect(_rectOf(box.rect), _ambientPaint);
      ambientCenters.add(_centerOf(box.rect));
    }

    if (showFlowLines) {
      for (var i = 0; i < ambientCenters.length - 1; i++) {
        final from = ambientCenters[i];
        final to = ambientCenters[i + 1];
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(to.dx, from.dy, from.dx, to.dy, to.dx, to.dy);
        canvas.drawPath(path, _flowLinePaint);
      }
    }

    for (final box in boxes) {
      if (box.style == AtsXrayBoxStyle.ambient) continue;
      canvas.drawRect(
        _rectOf(box.rect),
        _evidencePaint(
          box.severity,
          selected: box.style == AtsXrayBoxStyle.selected,
        ),
      );
    }

    final selection = this.selection;
    if (selection != null && selection.rects.isNotEmpty) {
      final union = _rectOf(atsUnionRect(selection.rects));
      if (selection.shape == AtsEvidenceShape.span) {
        canvas.drawRect(union.inflate(4), _hullPaint);
        if (selection.rects.length >= 2) {
          final from = _centerOf(selection.rects.first);
          final to = _centerOf(selection.rects.last);
          canvas.drawLine(from, to, _hullPaint);
        }
      }
    }
  }

  /// Identity, not deep-equality, on [boxes]: the list is only ever
  /// rebuilt when a new PDF is analyzed or a finding is (de)selected (see
  /// `AnalyzerXrayPanel`), so the same list instance flowing through
  /// unrelated widget rebuilds correctly short-circuits repainting rather
  /// than diffing hundreds of records on every frame. [selection]'s
  /// `rects` list is compared the same way.
  @override
  bool shouldRepaint(covariant AtsXrayPainter oldDelegate) =>
      oldDelegate.boxes != boxes ||
      oldDelegate.showFlowLines != showFlowLines ||
      oldDelegate.selection?.rects != selection?.rects ||
      oldDelegate.selection?.shape != selection?.shape;
}
