import 'package:flutter/material.dart';

/// The app's surface elevation ramp: four tiers, page ground to
/// hovered/nested surface, plus two line weights.
///
/// Widgets never reference these directly. `buildAppTheme()` pins them onto
/// `ColorScheme` container slots, so widget code reads
/// `Theme.of(context).colorScheme.*` and only this file and
/// `app_theme.dart` know the raw values — which is what lets the light
/// theme invert the ramp without touching a call site.
const Color kcPrimaryColor = Color(0xFF9600FF);
const Color kcPrimaryColorDark = Color(0xFF300151);

/// The page ground — behind everything, never on a card.
const Color kcSurfaceSunken = Color(0xFF101114);

/// The default panel/rail surface.
const Color kcSurface = Color(0xFF1A1B1E);

/// A card or dialog sitting on [kcSurface].
const Color kcSurfaceRaised = Color(0xFF22242A);

/// A hovered/nested card, or an inline editor inside a card.
const Color kcSurfaceOverlay = Color(0xFF2B2E36);

/// Hairline borders and dividers.
const Color kcBorderColor = Color(0xFF2F323A);

/// A border that needs to read as deliberate rather than incidental — a
/// focused field, a selected card's edge.
const Color kcBorderStrong = Color(0xFF454956);

/// Placeholder and disabled text/icon colour.
const Color kcMediumGrey = Color(0xFF474A54);
const Color kcLightGrey = Color.fromARGB(255, 187, 187, 187);
const Color kcWhite = Color(0xFFFFFFFF);
const Color kcErrorColor = Color(0xFFE05252);

/// Warning severity — `kcErrorColor` already means critical, so this needs
/// its own tone rather than that one at lower opacity.
const Color kcWarningColor = Color(0xFFE0A83B);

/// A positive/confirmed state. `kcPrimaryColor` is brand purple, not
/// semantically "success".
const Color kcSuccessColor = Color(0xFF4CAF7D);

/// The light-theme counterparts, same order and same four-tier semantics
/// with the luminance inverted. `app_theme.dart` picks between the two
/// sets and pins the winner onto the same `ColorScheme` slots.
///
/// [kcPrimaryColor] has no light variant: 5.25:1 on the light surfaces and
/// 5.61:1 white-on-purple both clear AA, so the brand accent stays one
/// colour rather than becoming a second, nearly-identical purple. The
/// three semantic colours do change — their dark values fail badly on
/// near-white (the amber is ~2:1), so each has a darkened twin.

/// The page ground — behind everything, never on a card.
const Color kcSurfaceSunkenLight = Color(0xFFE9EBF0);

/// The default panel/rail surface.
const Color kcSurfaceLight = Color(0xFFF2F3F6);

/// A card or dialog sitting on [kcSurfaceLight].
const Color kcSurfaceRaisedLight = Color(0xFFFAFBFC);

/// A hovered/nested card, or an inline editor inside a card.
const Color kcSurfaceOverlayLight = Color(0xFFFFFFFF);

/// Hairline borders and dividers.
const Color kcBorderColorLight = Color(0xFFD8DCE3);

/// A border that needs to read as deliberate rather than incidental.
const Color kcBorderStrongLight = Color(0xFFA8AFBC);

/// The primary foreground — light mode's counterpart to [kcWhite]. Not
/// pure black: 17.3:1 on the raised surface is already far past AA, and
/// pure black on near-white reads harsher than it needs to.
const Color kcOnSurfaceLight = Color(0xFF14161A);

/// The muted foreground — secondary lines, unselected rail labels. 5.75:1.
const Color kcOnSurfaceVariantLight = Color(0xFF5A6270);

/// Placeholder and disabled text, mirroring [kcMediumGrey]. Low-contrast
/// on purpose: WCAG exempts placeholder text, and one that meets AA stops
/// reading as a placeholder.
const Color kcMediumGreyLight = Color(0xFF9096A3);

/// 5.25:1 on the light ramp. [kcErrorColor] itself manages only 3.57:1
/// there, which is why this exists.
const Color kcErrorColorLight = Color(0xFFC62828);

/// 4.80:1. The dark theme's amber is the worst offender on light at ~2:1,
/// so this goes considerably darker rather than slightly.
const Color kcWarningColorLight = Color(0xFF9A6100);

/// 4.98:1.
const Color kcSuccessColorLight = Color(0xFF1E7A4D);
