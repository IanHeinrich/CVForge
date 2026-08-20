import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_motion.tailor.dart';

/// Animation durations as a swappable [ThemeExtension]. Currently just the
/// one duration in active use (`TailoringHighlight`'s `AnimatedContainer`,
/// hardcoded inline today) — add more fields here as further hardcoded
/// `Duration`s are found, rather than pre-guessing a fuller motion scale.
@TailorMixin()
class AppMotion extends ThemeExtension<AppMotion> with _$AppMotionTailorMixin {
  const AppMotion({required this.fast});

  @override
  final Duration fast;
}

const appMotion = AppMotion(fast: Duration(milliseconds: 120));
