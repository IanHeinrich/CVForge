import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_spacing.tailor.dart';

/// The spacing scale as a swappable [ThemeExtension], superseding
/// `app_constants.dart`'s `kdPadding*` (container padding) and
/// `ui_helpers.dart`'s gap constants (sibling spacing) — both keep working
/// unchanged until call sites migrate over to `context.appSpacing`.
@TailorMixin()
class AppSpacing extends ThemeExtension<AppSpacing>
    with _$AppSpacingTailorMixin {
  const AppSpacing({
    required this.gapTiny,
    required this.gapSmall,
    required this.gapMedium,
    required this.paddingTight,
    required this.paddingCompact,
    required this.paddingDefault,
    required this.paddingPanel,
    required this.paddingPage,
  });

  /// Spacing between sibling widgets — was `ui_helpers.dart`'s
  /// `verticalSpace*`/`horizontalSpace*` Widget constants.
  @override
  final double gapTiny;
  @override
  final double gapSmall;
  @override
  final double gapMedium;

  /// Padding inside a container's own border — was `app_constants.dart`'s
  /// `kdPadding*`.
  @override
  final double paddingTight;
  @override
  final double paddingCompact;
  @override
  final double paddingDefault;
  @override
  final double paddingPanel;
  @override
  final double paddingPage;
}

const appSpacing = AppSpacing(
  gapTiny: 5,
  gapSmall: 10,
  gapMedium: 25,
  paddingTight: 8,
  paddingCompact: 12,
  paddingDefault: 16,
  paddingPanel: 20,
  paddingPage: 24,
);
