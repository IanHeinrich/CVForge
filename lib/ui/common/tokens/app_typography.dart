import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

import '../app_text_styles.dart';

part 'app_typography.tailor.dart';

/// The named text-style roles from `app_text_styles.dart`, re-exposed as a
/// swappable [ThemeExtension]. The `ktsX` constants stay in place — and
/// stay the values this reads — for the reason documented there (Material
/// 3's `TextTheme` merge shifts glyph metrics enough to break pixel-exact
/// golden tests); this only changes *how* a widget reaches them, from a
/// top-level const to `context.appTypography`, so they can vary by theme
/// later without that risk.
@TailorMixin()
class AppTypography extends ThemeExtension<AppTypography>
    with _$AppTypographyTailorMixin {
  const AppTypography({
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodySmall,
  });

  @override
  final TextStyle titleLarge;
  @override
  final TextStyle titleMedium;
  @override
  final TextStyle titleSmall;
  @override
  final TextStyle bodySmall;
}

const appTypography = AppTypography(
  titleLarge: ktsTitleLarge,
  titleMedium: ktsTitleMedium,
  titleSmall: ktsTitleSmall,
  bodySmall: ktsBodySmall,
);
