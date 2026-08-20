import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

import '../app_colors.dart';

part 'app_typography.tailor.dart';

/// Named text-style roles for the chrome — Vault/Studio's own UI, not the
/// CV document (that's styled entirely by `CvDesignTokens`; see
/// `app_theme.dart`'s doc comment). A [ThemeExtension], not routed through
/// `ThemeData.textTheme`: Material 3 merges a supplied `TextTheme` into
/// its own `Typography` defaults, which introduces non-null
/// `letterSpacing`/`height` a bare `TextStyle` doesn't have and measurably
/// shifts glyph metrics — confirmed against this project's pixel-exact
/// golden tests. A `ThemeExtension` field is what stays byte-identical to
/// what widgets used to declare inline, while still being reachable via
/// `context.appTypography` instead of a top-level const.
///
/// A widget applies one of these directly (`style:
/// context.appTypography.titleLarge`) rather than inventing its own
/// fontSize/fontWeight pair, so the same conceptual heading role can't end
/// up at three different sizes across three widgets.
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
  // A page-level empty/error state's heading — "Your Vault is empty",
  // "CVForge couldn't load your data".
  titleLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: kcWhite,
  ),
  // A dialog or side-panel's own title.
  titleMedium: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: kcWhite,
  ),
  // A heading above one group of cards/items — "Work history", "Sections".
  titleSmall: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: kcWhite,
  ),
  // A collapsed card's secondary line, or italic free-text notes beneath
  // it — see `AppSummaryCard`.
  bodySmall: TextStyle(fontSize: 13, color: kcLightGrey),
);
