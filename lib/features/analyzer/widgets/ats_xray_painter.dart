import 'package:flutter/rendering.dart';

import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/ui/common/app_colors.dart';

/// Draws one stroked rectangle per [AtsPixelRect] — the X-Ray overlay's
/// box layer, replacing the one-[Positioned]-[Container]-per-node
/// approach used to validate the coordinate math across a whole page
/// (`docs/ats-xray-overlay-handover.md` §6, step 3 → step 4).
/// [Positioned] widgets don't scale to hundreds of nodes on a dense page;
/// a single painter draws every box in one pass regardless of how many
/// there are.
///
/// This is the first [CustomPainter] in the codebase — no established
/// convention to follow yet (see the handover doc §8's testing-strategy
/// notes).
class AtsXrayPainter extends CustomPainter {
  AtsXrayPainter(this.rects);

  final List<AtsPixelRect> rects;

  /// Low-opacity, same reasoning as step 3's `Container` borders: with a
  /// few hundred overlapping/adjacent boxes on a dense page, a
  /// full-opacity stroke would turn the backdrop into solid purple rather
  /// than something you can still read the text through to spot a
  /// misplaced box.
  static final _paint = Paint()
    ..color = kcPrimaryColor.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    for (final rect in rects) {
      canvas.drawRect(
        Rect.fromLTRB(rect.left, rect.top, rect.right, rect.bottom),
        _paint,
      );
    }
  }

  /// Identity, not deep-equality, on [rects]: the list is only ever
  /// rebuilt when a new PDF is analyzed (see `AnalyzerXrayPanel._load`),
  /// so the same list instance flowing through unrelated widget rebuilds
  /// correctly short-circuits repainting rather than diffing hundreds of
  /// records on every frame.
  @override
  bool shouldRepaint(covariant AtsXrayPainter oldDelegate) =>
      oldDelegate.rects != rects;
}
