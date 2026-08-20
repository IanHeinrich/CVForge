// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_radius.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppRadiusTailorMixin on ThemeExtension<AppRadius> {
  double get small;
  double get medium;
  double get large;

  @override
  AppRadius copyWith({double? small, double? medium, double? large}) {
    return AppRadius(
      small: small ?? this.small,
      medium: medium ?? this.medium,
      large: large ?? this.large,
    );
  }

  @override
  AppRadius lerp(covariant ThemeExtension<AppRadius>? other, double t) {
    if (other is! AppRadius) return this as AppRadius;
    return AppRadius(
      small: t < 0.5 ? small : other.small,
      medium: t < 0.5 ? medium : other.medium,
      large: t < 0.5 ? large : other.large,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppRadius &&
            const DeepCollectionEquality().equals(small, other.small) &&
            const DeepCollectionEquality().equals(medium, other.medium) &&
            const DeepCollectionEquality().equals(large, other.large));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(small),
      const DeepCollectionEquality().hash(medium),
      const DeepCollectionEquality().hash(large),
    );
  }
}

extension AppRadiusBuildContextProps on BuildContext {
  AppRadius get appRadius => Theme.of(this).extension<AppRadius>()!;

  /// A highlight/inline-edit affordance — see `TailoringHighlight`.
  double get small => appRadius.small;

  /// The default for cards, panels, and banners.
  double get medium => appRadius.medium;

  /// A dialog's own outer shape.
  double get large => appRadius.large;
}
