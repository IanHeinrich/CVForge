import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_palette.tailor.dart';

/// The app's semantic colours that Material 3's `ColorScheme` has no slot
/// for, as a swappable [ThemeExtension].
///
/// Everything that *does* map to a `ColorScheme` slot lives there instead
/// and is reached as `Theme.of(context).colorScheme.*` — see
/// `app_colors.dart` for the raw values and which slots they are pinned
/// to. Only add a field here when M3 genuinely has nowhere to put it.
@TailorMixin()
class AppPalette extends ThemeExtension<AppPalette>
    with _$AppPaletteTailorMixin {
  const AppPalette({
    required this.placeholder,
    required this.warning,
    required this.success,
  });

  /// Placeholder and disabled text/icons. Not `onSurface` at reduced
  /// opacity, which is M3's convention — this palette's value is its own
  /// cooler tone rather than a dimmed version of the foreground.
  @override
  final Color placeholder;

  /// Warning severity, for evidence boxes and rail badges.
  @override
  final Color warning;

  /// A positive/confirmed state — a successful connection test, a clean
  /// backup.
  @override
  final Color success;
}

const appPalette = AppPalette(
  placeholder: kcMediumGrey,
  warning: kcWarningColor,
  success: kcSuccessColor,
);
