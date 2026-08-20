import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'app_radius.tailor.dart';

/// Corner-radius scale as a swappable [ThemeExtension]. No prior top-level
/// constant existed for these — every call site (`BorderRadius.circular`)
/// currently repeats one of three raw numbers inline; this is the target
/// call sites migrate to, replacing the raw literals.
@TailorMixin()
class AppRadius extends ThemeExtension<AppRadius> with _$AppRadiusTailorMixin {
  const AppRadius({
    required this.small,
    required this.medium,
    required this.large,
  });

  /// A highlight/inline-edit affordance — see `TailoringHighlight`.
  @override
  final double small;

  /// The default for cards, panels, and banners.
  @override
  final double medium;

  /// A dialog's own outer shape.
  @override
  final double large;
}

const appRadius = AppRadius(small: 6, medium: 8, large: 10);
