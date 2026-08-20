import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Named text-style roles for the chrome — Vault/Studio's own UI, not the
/// CV document (that's styled entirely by `CvDesignTokens`; see
/// `app_theme.dart`'s doc comment). Plain top-level constants, not routed
/// through `ThemeData.textTheme`: Material 3 merges a supplied
/// `TextTheme` into its own `Typography` defaults, which introduces
/// non-null `letterSpacing`/`height` a bare `TextStyle` doesn't have and
/// measurably shifts glyph metrics — confirmed against this project's
/// pixel-exact golden tests. A plain constant is what stays byte-identical
/// to what widgets already declared inline.
///
/// A widget applies one of these directly (`style: ktsTitleLarge`) rather
/// than inventing its own fontSize/fontWeight pair, so the same
/// conceptual heading role can't end up at three different sizes across
/// three widgets.

/// A page-level empty/error state's heading — "Your Vault is empty",
/// "CVForge couldn't load your data".
const ktsTitleLarge = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w700,
  color: kcWhite,
);

/// A dialog or side-panel's own title.
const ktsTitleMedium = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w700,
  color: kcWhite,
);

/// A heading above one group of cards/items — "Work history", "Sections".
const ktsTitleSmall = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: kcWhite,
);

/// A collapsed card's secondary line, or italic free-text notes beneath
/// it — see `AppSummaryCard`.
const ktsBodySmall = TextStyle(fontSize: 13, color: kcLightGrey);
