import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'tokens/app_icon_size.dart';
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
  // `fromSeed` derives every ColorScheme slot as a *tone* of the seed hue
  // tuned for dark-mode contrast — `primary` comes out a pale lavender,
  // not the actual brand purple. `copyWith` then pins the slots this app
  // already has a named, in-use color for (`kc*` in app_colors.dart) so
  // Material-default-styled widgets (buttons, chips, TextField's error
  // state) match the brand color used everywhere else (the nav rail,
  // checkboxes) instead of a washed-out seed-derived approximation of it.
  // The `surface*`/`outline*` slots pin the elevation ramp declared in
  // app_colors.dart, so Material-default-styled widgets (`Card`,
  // `NavigationRail`, `Divider`) read the right tier with no per-widget
  // override — see that file's file-level comment for the ramp itself.
  // Every other slot stays seed-derived — nobody's designed a value for
  // those yet.
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: kcPrimaryColor,
        brightness: Brightness.dark,
        surface: kcSurface,
      ).copyWith(
        primary: kcPrimaryColor,
        onPrimary: kcWhite,
        error: kcErrorColor,
        onError: kcWhite,
        surfaceContainerLowest: kcSurfaceSunken,
        surfaceContainerLow: kcSurfaceRaised,
        surfaceContainer: kcSurfaceRaised,
        surfaceContainerHigh: kcSurfaceOverlay,
        surfaceContainerHighest: kcSurfaceOverlay,
        outlineVariant: kcBorderColor,
        outline: kcBorderStrong,
      );

  // Deliberately squares off Material 3's default pill-shaped buttons to
  // `appRadius.medium` — the same radius already used by cards, dialogs,
  // and panels — so buttons stop being the one pill-shaped element in an
  // otherwise squared-off UI. Colors are untouched; only shape changes.
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(appRadius.medium),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: kcSurfaceSunken,
    canvasColor: kcSurfaceSunken,
    dividerColor: kcBorderColor,
    extensions: const [
      appSpacing,
      appRadius,
      appTypography,
      appMotion,
      appIconSize,
    ],
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: buttonShape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: buttonShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: buttonShape),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kcSurfaceRaised,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appRadius.large),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(appRadius.medium),
      ),
    ),
    // FilterChip/ChoiceChip selection reads `selectedColor`, not `primary`
    // — pinning only `colorScheme.primary` above (see its doc comment)
    // left selected chips on the seed-derived `secondaryContainer` tone,
    // a visibly different color family from the nav rail/buttons. Only
    // the selected-state slots are pinned; unselected chips keep their
    // seed-derived look, same as every other not-yet-designed slot.
    chipTheme: ChipThemeData(
      selectedColor: kcPrimaryColor,
      checkmarkColor: kcWhite,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: kcPrimaryColor,
      unselectedLabelColor: kcLightGrey,
      indicatorColor: kcPrimaryColor,
    ),
  );
}
