import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'tokens/app_icon_size.dart';
import 'tokens/app_motion.dart';
import 'tokens/app_palette.dart';
import 'tokens/app_radius.dart';
import 'tokens/app_spacing.dart';
import 'tokens/app_typography.dart';

/// The raw colours one brightness of the chrome theme is built from.
///
/// The whole point of routing both themes through one record is that
/// [buildAppTheme] below has a single body: every slot is pinned once, and
/// a slot that exists in one theme cannot quietly go missing from the
/// other. `app_colors.dart` stays the registry of raw values; this is only
/// the pairing between them.
typedef _ThemeColors = ({
  Brightness brightness,
  Color surface,
  Color surfaceSunken,
  Color surfaceRaised,
  Color surfaceOverlay,
  Color border,
  Color borderStrong,
  Color onSurface,
  Color onSurfaceVariant,
  Color error,
  Color hoverBase,
  double hoverAlpha,
});

const _ThemeColors _darkColors = (
  brightness: Brightness.dark,
  surface: kcSurface,
  surfaceSunken: kcSurfaceSunken,
  surfaceRaised: kcSurfaceRaised,
  surfaceOverlay: kcSurfaceOverlay,
  border: kcBorderColor,
  borderStrong: kcBorderStrong,
  onSurface: kcWhite,
  onSurfaceVariant: kcLightGrey,
  error: kcErrorColor,
  hoverBase: kcWhite,
  hoverAlpha: 0.06,
);

const _ThemeColors _lightColors = (
  brightness: Brightness.light,
  surface: kcSurfaceLight,
  surfaceSunken: kcSurfaceSunkenLight,
  surfaceRaised: kcSurfaceRaisedLight,
  surfaceOverlay: kcSurfaceOverlayLight,
  border: kcBorderColorLight,
  borderStrong: kcBorderStrongLight,
  onSurface: kcOnSurfaceLight,
  onSurfaceVariant: kcOnSurfaceVariantLight,
  error: kcErrorColorLight,
  // A white overlay is invisible on a light surface, so light hovers tint
  // *down* rather than up. Slightly weaker than dark's 0.06 because a dark
  // wash on a pale surface reads stronger at the same alpha.
  hoverBase: kcOnSurfaceLight,
  hoverAlpha: 0.05,
);

/// The app's own editor-chrome theme — NOT the CV document's typography.
/// The document is styled entirely by `CvDesignTokens` (`lib/templates/
/// design/`) and rendered with a bundled serif face; this theme only
/// governs the surrounding Vault/Studio UI, which uses the platform's
/// default font.
///
/// [kcPrimaryColor] is reserved for selection/interaction state in the
/// chrome (highlighted nav item, "included in draft" toggle, etc.) — it
/// must never appear inside the CV output itself. It is also the one
/// colour that does not vary by [brightness]; see `app_colors.dart`'s
/// light block for the measured contrast ratios behind that.
///
/// [brightness] defaults to dark because dark is the product's default
/// theme — so a caller that just wants "the theme this app ships with"
/// (every golden test, via `pumpGoldenScreen`) gets it without restating
/// the choice. Only `main.dart` passes the argument, once per slot.
ThemeData buildAppTheme({Brightness brightness = Brightness.dark}) {
  final c = brightness == Brightness.dark ? _darkColors : _lightColors;

  // `fromSeed` derives every ColorScheme slot as a *tone* of the seed hue
  // tuned for the requested brightness — `primary` comes out a pale
  // lavender in dark, not the actual brand purple. `copyWith` then pins the
  // slots this app already has a named, in-use color for (`kc*` in
  // app_colors.dart) so Material-default-styled widgets (buttons, chips,
  // TextField's error state) match the brand color used everywhere else
  // (the nav rail, checkboxes) instead of a washed-out seed-derived
  // approximation of it. The `surface*`/`outline*` slots pin the elevation
  // ramp declared in app_colors.dart, so Material-default-styled widgets
  // (`Card`, `NavigationRail`, `Divider`) read the right tier with no
  // per-widget override — see that file's file-level comment for the ramp
  // itself. Every other slot stays seed-derived — nobody's designed a
  // value for those yet.
  //
  // The seed is deliberately the same in both themes: changing it would
  // shift every *unpinned* slot (secondary, tertiary, inverseSurface,
  // scrim) invisibly, in a theme nothing here has designed values for.
  final seeded =
      ColorScheme.fromSeed(
        seedColor: kcPrimaryColor,
        brightness: c.brightness,
        surface: c.surface,
      ).copyWith(
        primary: kcPrimaryColor,
        onPrimary: kcWhite,
        // This app's foregrounds are neutral; the seed derives purple-tinted
        // ones. Pinned so Material-default widgets and this app's own widgets
        // read the same two values instead of two near-identical palettes side
        // by side, and so the light theme changes them here, not at every call
        // site.
        onSurface: c.onSurface,
        onSurfaceVariant: c.onSurfaceVariant,
        error: c.error,
        onError: kcWhite,
        surfaceContainerLowest: c.surfaceSunken,
        surfaceContainerLow: c.surfaceRaised,
        surfaceContainer: c.surfaceRaised,
        surfaceContainerHigh: c.surfaceOverlay,
        surfaceContainerHighest: c.surfaceOverlay,
        outlineVariant: c.border,
        outline: c.borderStrong,
      );

  // M3 washes `surfaceTint` over elevated surfaces (`Card`, `Dialog`).
  // Against the dark ramp the seed-derived tint is near-invisible, but on
  // the pale ramp it gives every elevated surface a lilac cast the ramp
  // above deliberately doesn't have. Applied as a light-only tail rather
  // than a slot in the shared `copyWith` above, so the dark path returns
  // the identical object it always did.
  final colorScheme = brightness == Brightness.light
      ? seeded.copyWith(surfaceTint: Colors.transparent)
      : seeded;

  // Deliberately squares off Material 3's default pill-shaped buttons to
  // `appRadius.medium` — the same radius already used by cards, dialogs,
  // and panels — so buttons stop being the one pill-shaped element in an
  // otherwise squared-off UI. Colors are untouched; only shape changes.
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(appRadius.medium),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: c.brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: c.surfaceSunken,
    canvasColor: c.surfaceSunken,
    dividerColor: c.border,
    extensions: brightness == Brightness.dark
        ? const [
            appSpacing,
            appRadius,
            appTypography,
            appMotion,
            appIconSize,
            appPalette,
          ]
        : [
            appSpacing,
            appRadius,
            appTypographyLight,
            appMotion,
            appIconSize,
            appPaletteLight,
          ],
    // Cards (`AppSummaryCard`, drafts/template gallery cards) wrap a plain
    // `InkWell` with no `overlayColor` of its own, so they fall through to
    // these theme-level defaults — Material's own dark-theme default is a
    // ~4% white overlay, which measured as a near-invisible ~9/255 channel
    // shift on this palette's already-dark card surfaces, leaving every
    // clickable card looking inert until actually pressed. `primary`-tinted
    // overlays (rather than plain white/black) also tie the feedback to the
    // brand accent already used for every other selected/active state.
    // Buttons are unaffected — `Filled`/`Outlined`/`TextButton` define their
    // own `overlayColor` in Material 3 and never fall back to these.
    //
    // Kept as an expression rather than folded into a literal: `Color.a` is
    // a double, so `withValues(alpha: 0.06)` is not the same value as the
    // nearest 8-bit hex (0x0F is 0.0588), and collapsing it would be a real
    // one-channel shift on every hovered card.
    hoverColor: c.hoverBase.withValues(alpha: c.hoverAlpha),
    focusColor: kcPrimaryColor.withValues(alpha: 0.12),
    highlightColor: kcPrimaryColor.withValues(alpha: 0.08),
    splashColor: kcPrimaryColor.withValues(alpha: 0.14),
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
      backgroundColor: c.surfaceRaised,
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
    tabBarTheme: TabBarThemeData(
      labelColor: kcPrimaryColor,
      unselectedLabelColor: c.onSurfaceVariant,
      indicatorColor: kcPrimaryColor,
    ),
  );
}

/// Maps the app's own persisted [AppThemeMode] onto Flutter's [ThemeMode].
///
/// Lives here rather than on the enum because `lib/models/` must not
/// import Flutter — the enum is deliberately Flutter-free, and this is the
/// one place that bridges it.
extension AppThemeModeMaterial on AppThemeMode {
  ThemeMode get materialThemeMode => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
