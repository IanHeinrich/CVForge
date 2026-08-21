import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:cv_forge/models/ats/ats_matrix_math.dart';

/// The X-Ray overlay's camera: pure transform math (fit-to-viewport,
/// frame-a-rect) plus the animation plumbing that moves
/// [transformationController] smoothly between them. Owns no domain
/// knowledge of findings, pages, or selection — `AnalyzerXrayPanel`
/// decides *what* to frame; this only knows *how* to get the camera
/// there.
class XrayCameraController {
  XrayCameraController({
    required TickerProvider vsync,
    required Duration duration,
  }) : _animationController = AnimationController(
         vsync: vsync,
         duration: duration,
       );

  final TransformationController transformationController =
      TransformationController();

  /// One controller reused for every camera move, not recreated per move,
  /// so [animateTo] can always interrupt whatever move is already
  /// in flight.
  final AnimationController _animationController;
  void Function()? _animationListener;

  /// The whole page, scaled down to fit and centred — the sane opening
  /// view, and what double-tap returns to.
  Matrix4 fitTransform(Size viewport, Size content) {
    if (viewport.isEmpty || content.isEmpty) return Matrix4.identity();
    final scale = math.min(
      viewport.width / content.width,
      viewport.height / content.height,
    );
    // Column-major (`setEntry(row, col, _)`), so column 3 is translation
    // and this composes as `x' = scale * x + dx` — scale first, then
    // centre what's left over.
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, (viewport.width - content.width * scale) / 2)
      ..setEntry(1, 3, (viewport.height - content.height * scale) / 2);
  }

  /// Frames [rect] centred in [viewport] with [padding] pixels of margin,
  /// clamped to the same zoom range as `InteractiveViewer.minScale`/
  /// `maxScale`.
  Matrix4 frameTransform(
    AtsPixelRect rect,
    Size viewport, {
    double padding = 48,
  }) {
    final width = (rect.right - rect.left) + padding * 2;
    final height = (rect.bottom - rect.top) + padding * 2;
    if (viewport.isEmpty || width <= 0 || height <= 0) {
      return transformationController.value;
    }
    final scale = math
        .min(viewport.width / width, viewport.height / height)
        .clamp(0.1, 8.0);
    final cx = (rect.left + rect.right) / 2;
    final cy = (rect.top + rect.bottom) / 2;
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, viewport.width / 2 - cx * scale)
      ..setEntry(1, 3, viewport.height / 2 - cy * scale);
  }

  /// Animates [transformationController] to [target]. Safe to call
  /// mid-build (as `AnalyzerXrayPanel` does, to avoid a snap-then-
  /// catch-up flicker on every selection): `_animationController.reset()`
  /// does notify its listeners synchronously, but at `t == 0`
  /// `Matrix4Tween.evaluate` short-circuits to the literal `begin`
  /// instance — the same object [transformationController.value] already
  /// holds — so the listener's assignment below is a same-value no-op
  /// that `ValueNotifier` swallows before it ever reaches
  /// `InteractiveViewer`'s own `setState`.
  void animateTo(Matrix4 target) {
    // Interrupting an in-flight move: drop its listener before starting
    // the next one, or the stale animation keeps writing over the new
    // one's frames.
    final previousListener = _animationListener;
    if (previousListener != null) {
      _animationController.removeListener(previousListener);
    }
    final animation =
        Matrix4Tween(
          begin: transformationController.value,
          end: target,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
    void listener() => transformationController.value = animation.value;
    _animationListener = listener;
    _animationController.addListener(listener);
    _animationController
      ..reset()
      ..forward();
  }

  void dispose() {
    transformationController.dispose();
    _animationController.dispose();
  }
}
