import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_motion.tailor.dart';

/// Animation durations as a swappable [ThemeExtension]. Add more fields
/// here as further hardcoded `Duration`s are found, rather than
/// pre-guessing a fuller motion scale.
@TailorMixin()
class AppMotion extends ThemeExtension<AppMotion> with _$AppMotionTailorMixin {
  const AppMotion({
    required this.fast,
    required this.camera,
    required this.layout,
  });

  @override
  final Duration fast;

  /// The X-Ray overlay's camera pan/zoom (`XrayCameraController`).
  @override
  final Duration camera;

  /// A panel/column reflow — `VaultViewDesktop`'s card-list/editor split
  /// easing its width and alignment when the editor opens or closes.
  @override
  final Duration layout;
}

const appMotion = AppMotion(
  fast: Duration(milliseconds: 120),
  camera: Duration(milliseconds: 350),
  layout: Duration(milliseconds: 280),
);
