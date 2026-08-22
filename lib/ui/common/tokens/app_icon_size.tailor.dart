// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_icon_size.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppIconSizeTailorMixin on ThemeExtension<AppIconSize> {
  double get tiny;
  double get small;
  double get medium;
  double get large;
  double get xLarge;

  @override
  AppIconSize copyWith({
    double? tiny,
    double? small,
    double? medium,
    double? large,
    double? xLarge,
  }) {
    return AppIconSize(
      tiny: tiny ?? this.tiny,
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
      xLarge: xLarge ?? this.xLarge,
    );
  }

  @override
  AppIconSize lerp(covariant ThemeExtension<AppIconSize>? other, double t) {
    if (other is! AppIconSize) return this as AppIconSize;
    return AppIconSize(
      tiny: t < 0.5 ? tiny : other.tiny,
      small: t < 0.5 ? small : other.small,
      medium: t < 0.5 ? medium : other.medium,
      large: t < 0.5 ? large : other.large,
      xLarge: t < 0.5 ? xLarge : other.xLarge,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppIconSize &&
            const DeepCollectionEquality().equals(tiny, other.tiny) &&
            const DeepCollectionEquality().equals(small, other.small) &&
            const DeepCollectionEquality().equals(medium, other.medium) &&
            const DeepCollectionEquality().equals(large, other.large) &&
            const DeepCollectionEquality().equals(xLarge, other.xLarge));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(tiny),
      const DeepCollectionEquality().hash(small),
      const DeepCollectionEquality().hash(medium),
      const DeepCollectionEquality().hash(large),
      const DeepCollectionEquality().hash(xLarge),
    );
  }
}

extension AppIconSizeBuildContextProps on BuildContext {
  AppIconSize get appIconSize => Theme.of(this).extension<AppIconSize>()!;

  /// A step arrow or other tightly-packed inline icon.
  double get tiny => appIconSize.tiny;

  /// A caption-row glyph — an icon paired with `AppTypography.caption`.
  double get small => appIconSize.small;

  /// The default icon size used through most of the chrome.
  double get medium => appIconSize.medium;

  /// A card's leading mark — a region flag, a template thumbnail's icon.
  double get large => appIconSize.large;

  /// A full empty-state illustration icon.
  double get xLarge => appIconSize.xLarge;
}
