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

  static const _cornerRadius = Radius.circular(3);

  /// Low-opacity, same reasoning as step 3's `Container` borders: with a
  /// few hundred overlapping/adjacent boxes on a dense page, a
  /// full-opacity stroke would turn the backdrop into solid purple rather
  /// than something you can still read the text through to spot a
  /// misplaced box.
  static final _ambientPaint = Paint()
    ..color = kcPrimaryColor.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  /// Dimmer than [_ambientPaint] — used instead of it while [showFlowLines]
  /// is on, so the boxes recede and the flow line (drawn on top) is the
  /// thing the eye follows, not one of several competing strokes.
  static final _ambientDimPaint = Paint()
    ..color = kcPrimaryColor.withValues(alpha: 0.18)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  /// The line/hull layer's readability problem is different from the
  /// boxes': the backdrop here is the *rasterized PDF page itself* — a
  /// real resume, almost always a white/light background — not the app's
  /// own dark chrome. A single fixed colour (this was `kcWhite` at low
  /// alpha originally) reads as invisible on the exact backgrounds this
  /// feature spends most of its time on. A light-then-dark "halo" stroke
  /// — a wide pale pass under a narrow dark one — stays legible regardless
  /// of what's underneath, the same trick map/chart labels use to stay
  /// readable over arbitrary imagery.
  static final _lineHaloPaint = Paint()
    ..color = kcWhite.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round;

  static final _flowLinePaint = Paint()
    ..color = kcPrimaryColorDark.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;

  static final _hullPaint = Paint()
    ..color = kcPrimaryColorDark.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  /// The reading-order chain's start — a hollow ring rather than a filled
  /// dot, so it doesn't read as just another node marker.
  static final _startRingPaint = Paint()
    ..color = kcPrimaryColorDark
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  static final _startRingHaloPaint = Paint()
    ..color = kcWhite.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4.5;

  static final _endMarkerPaint = Paint()
    ..color = kcPrimaryColorDark
    ..style = PaintingStyle.fill;

  static final _endMarkerHaloPaint = Paint()
    ..color = kcWhite.withValues(alpha: 0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  static final _dotPaint = Paint()
    ..color = kcPrimaryColorDark.withValues(alpha: 0.9)
    ..style = PaintingStyle.fill;

  static final _dotHaloPaint = Paint()
    ..color = kcWhite.withValues(alpha: 0.9)
    ..style = PaintingStyle.fill;

  /// The selected box needs to be unmistakable at a glance, not just a
  /// thicker version of the evidence stroke — a filled wash plus a bright
  /// halo-outlined border, so it reads clearly even at a quick glance or
  /// at low zoom.
  Paint _selectedFillPaint(AtsFindingSeverity? severity) => Paint()
    ..color = _severityColor(severity).withValues(alpha: 0.28)
    ..style = PaintingStyle.fill;

  Paint _selectedHaloPaint() => Paint()
    ..color = kcWhite.withValues(alpha: 0.95)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6;

  Paint _selectedStrokePaint(AtsFindingSeverity? severity) => Paint()
    ..color = _severityColor(severity)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  Paint _evidencePaint(AtsFindingSeverity? severity) => Paint()
    ..color = _severityColor(severity).withValues(alpha: 0.7)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;

  Color _severityColor(AtsFindingSeverity? severity) => switch (severity) {
    AtsFindingSeverity.critical => kcErrorColor,
    AtsFindingSeverity.warning => kcWarningColor,
    AtsFindingSeverity.info => kcLightGrey,
    null => kcPrimaryColor,
  };

  Rect _rectOf(AtsPixelRect r) =>
      Rect.fromLTRB(r.left, r.top, r.right, r.bottom);

  RRect _roundedRectOf(AtsPixelRect r) =>
      RRect.fromRectAndRadius(_rectOf(r), _cornerRadius);

  Offset _centerOf(AtsPixelRect r) => _rectOf(r).center;

  void _drawHaloLine(Canvas canvas, Offset from, Offset to) {
    canvas.drawLine(from, to, _lineHaloPaint);
    canvas.drawLine(from, to, _flowLinePaint);
  }

  void _drawHaloPath(Canvas canvas, Path path) {
    canvas.drawPath(path, _lineHaloPaint);
    canvas.drawPath(path, _flowLinePaint);
  }

  void _drawHaloRRect(Canvas canvas, RRect rrect) {
    canvas.drawRRect(rrect, _lineHaloPaint);
    canvas.drawRRect(rrect, _hullPaint);
  }

  /// A small filled triangle at [tip], pointing away from [from] — the
  /// arrowhead that marks where the reading-order chain *ends*, so
  /// direction is legible without having to trace the whole path back to
  /// the start.
  void _drawArrowhead(Canvas canvas, Offset from, Offset tip) {
    const size = 7.0;
    final direction = tip - from;
    final length = direction.distance;
    if (length == 0) return;
    final unit = direction / length;
    final normal = Offset(-unit.dy, unit.dx);
    final base = tip - unit * size;
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        base.dx + normal.dx * size * 0.55,
        base.dy + normal.dy * size * 0.55,
      )
      ..lineTo(
        base.dx - normal.dx * size * 0.55,
        base.dy - normal.dy * size * 0.55,
      )
      ..close();
    canvas.drawPath(path, _endMarkerHaloPaint);
    canvas.drawPath(path, _endMarkerPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ambient pass first so evidence/selected boxes paint on top of it,
    // never the reverse. Dimmed while the flow line is showing, so the
    // line — not the backdrop of boxes it has to be traced through — is
    // the thing that reads clearly.
    final ambientCenters = <Offset>[];
    final ambientPaint = showFlowLines ? _ambientDimPaint : _ambientPaint;
    for (final box in boxes) {
      if (box.style != AtsXrayBoxStyle.ambient) continue;
      canvas.drawRect(_rectOf(box.rect), ambientPaint);
      ambientCenters.add(_centerOf(box.rect));
    }

    if (showFlowLines && ambientCenters.length >= 2) {
      for (var i = 0; i < ambientCenters.length - 1; i++) {
        final from = ambientCenters[i];
        final to = ambientCenters[i + 1];
        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(to.dx, from.dy, from.dx, to.dy, to.dx, to.dy);
        _drawHaloPath(canvas, path);
      }
      // A dot at every intermediate node anchors the "connect the dots"
      // reading — without these the line runs *through* each box's
      // interior with nothing marking where one hop ends and the next
      // begins, which is exactly what read as hard to follow.
      for (var i = 1; i < ambientCenters.length - 1; i++) {
        canvas.drawCircle(ambientCenters[i], 3.5, _dotHaloPaint);
        canvas.drawCircle(ambientCenters[i], 2, _dotPaint);
      }
      // Start and end need to look different from every dot in between —
      // a hollow ring for "this is where reading order begins", a small
      // arrowhead for "this is where it ends and which way it was going".
      final start = ambientCenters.first;
      canvas.drawCircle(start, 5, _startRingHaloPaint);
      canvas.drawCircle(start, 5, _startRingPaint);
      _drawArrowhead(
        canvas,
        ambientCenters[ambientCenters.length - 2],
        ambientCenters.last,
      );
    }

    for (final box in boxes) {
      if (box.style == AtsXrayBoxStyle.evidence) {
        canvas.drawRect(_rectOf(box.rect), _evidencePaint(box.severity));
      } else if (box.style == AtsXrayBoxStyle.selected) {
        final rrect = _roundedRectOf(box.rect);
        canvas.drawRRect(rrect, _selectedFillPaint(box.severity));
        canvas.drawRRect(rrect, _selectedHaloPaint());
        canvas.drawRRect(rrect, _selectedStrokePaint(box.severity));
      }
    }

    final selection = this.selection;
    if (selection != null &&
        selection.rects.isNotEmpty &&
        selection.shape == AtsEvidenceShape.span) {
      final union = _rectOf(atsUnionRect(selection.rects));
      _drawHaloRRect(
        canvas,
        RRect.fromRectAndRadius(union.inflate(6), _cornerRadius * 2),
      );
      if (selection.rects.length >= 2) {
        _drawHaloLine(
          canvas,
          _centerOf(selection.rects.first),
          _centerOf(selection.rects.last),
        );
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
