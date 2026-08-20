import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'tokens/app_motion.dart';
import 'tokens/app_radius.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

/// The app's own editor-chrome theme — NOT the CV document's typography.
/// The document is styled entirely by `CvDesignTokens` (`lib/templates/
/// design/`) and rendered with a bundled serif face; this theme only
/// governs the surrounding Vault/Studio UI, which uses the platform's
/// default font.
///
/// [kcPrimaryColor] is reserved for selection/interaction state in the
/// chrome (highlighted nav item, "included in draft" toggle, etc.) — it
/// must never appear inside the CV output itself.
ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kcPrimaryColor,
    brightness: Brightness.dark,
    surface: kcDarkGreyColor,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kcBackgroundColor,
    canvasColor: kcBackgroundColor,
    dividerColor: kcMediumGrey,
    extensions: const [appSpacing, appRadius, appTypography, appMotion],
  );
}
