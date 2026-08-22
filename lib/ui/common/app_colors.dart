import 'package:flutter/material.dart';

/// The app's surface elevation ramp. Four tiers, darkest (the page ground)
/// to lightest (a hovered/nested surface), plus two line weights. Widgets
/// should not reference these six consts directly — they're pinned onto
/// `buildAppTheme()`'s `ColorScheme` container slots (see that file), so
/// widget code reads `Theme.of(context).colorScheme.*` (or picks up a
/// Material default, e.g. `Card`) and only this file and `app_theme.dart`
/// know the raw values. Keeping every widget on the theme, rather than a
/// literal tier name, is what lets a future light theme invert the ramp
/// without touching call sites.
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

/// Placeholder and disabled text/icon colour. This is `kcMediumGrey`'s one
/// remaining job — it used to also carry border/divider colour and the
/// preview pane's backdrop, both split out above.
const Color kcMediumGrey = Color(0xFF474A54);
const Color kcLightGrey = Color.fromARGB(255, 187, 187, 187);
const Color kcWhite = Color(0xFFFFFFFF);
const Color kcErrorColor = Color(0xFFE05252);

/// The warning-severity colour for evidence boxes/rail badges —
/// `kcErrorColor` already means critical elsewhere in the app, so warning
/// needs its own tone rather than reusing it at lower opacity.
const Color kcWarningColor = Color(0xFFE0A83B);

/// A positive/confirmed-state colour — a successful connection test, a
/// clean backup state. No prior use case existed for this before 7.7;
/// `kcPrimaryColor` is brand purple, not semantically "success".
const Color kcSuccessColor = Color(0xFF4CAF7D);
