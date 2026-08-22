import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_icon_size.tailor.dart';

/// Icon-size scale as a swappable [ThemeExtension]. No prior shared scale
/// existed for these — every call site (an `Icon`'s or emoji `Text`'s
/// `size`/`fontSize`) currently repeated one of a handful of raw numbers
/// inline; this is the target call sites migrate to.
@TailorMixin()
class AppIconSize extends ThemeExtension<AppIconSize>
    with _$AppIconSizeTailorMixin {
  const AppIconSize({
    required this.tiny,
    required this.small,
    required this.medium,
    required this.large,
    required this.xLarge,
  });

  /// A step arrow or other tightly-packed inline icon.
  @override
  final double tiny;

  /// A caption-row glyph — an icon paired with `AppTypography.caption`.
  @override
  final double small;

  /// The default icon size used through most of the chrome.
  @override
  final double medium;

  /// A card's leading mark — a region flag, a template thumbnail's icon.
  @override
  final double large;

  /// A full empty-state illustration icon.
  @override
  final double xLarge;
}

const appIconSize = AppIconSize(
  tiny: 14,
  small: 16,
  medium: 18,
  large: 28,
  xLarge: 48,
);
