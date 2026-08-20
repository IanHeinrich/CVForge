// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_typography.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppTypographyTailorMixin on ThemeExtension<AppTypography> {
  TextStyle get titleLarge;
  TextStyle get titleMedium;
  TextStyle get titleSmall;
  TextStyle get bodySmall;
  TextStyle get caption;

  @override
  AppTypography copyWith({
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodySmall,
    TextStyle? caption,
  }) {
    return AppTypography(
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodySmall: bodySmall ?? this.bodySmall,
      caption: caption ?? this.caption,
    );
  }

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this as AppTypography;
    return AppTypography(
      titleLarge: TextStyle.lerp(titleLarge, other.titleLarge, t)!,
      titleMedium: TextStyle.lerp(titleMedium, other.titleMedium, t)!,
      titleSmall: TextStyle.lerp(titleSmall, other.titleSmall, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppTypography &&
            const DeepCollectionEquality().equals(
              titleLarge,
              other.titleLarge,
            ) &&
            const DeepCollectionEquality().equals(
              titleMedium,
              other.titleMedium,
            ) &&
            const DeepCollectionEquality().equals(
              titleSmall,
              other.titleSmall,
            ) &&
            const DeepCollectionEquality().equals(bodySmall, other.bodySmall) &&
            const DeepCollectionEquality().equals(caption, other.caption));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(titleLarge),
      const DeepCollectionEquality().hash(titleMedium),
      const DeepCollectionEquality().hash(titleSmall),
      const DeepCollectionEquality().hash(bodySmall),
      const DeepCollectionEquality().hash(caption),
    );
  }
}

extension AppTypographyBuildContextProps on BuildContext {
  AppTypography get appTypography => Theme.of(this).extension<AppTypography>()!;
  TextStyle get titleLarge => appTypography.titleLarge;
  TextStyle get titleMedium => appTypography.titleMedium;
  TextStyle get titleSmall => appTypography.titleSmall;
  TextStyle get bodySmall => appTypography.bodySmall;

  /// The smallest text in the chrome — helper/status text under a form
  /// field, a chip label, a bulk-action button. Deliberately carries no
  /// color of its own (unlike [bodySmall]): every call site so far picks
  /// its own color (or none, inheriting the ambient one) and sometimes a
  /// weight or italic, so this only centralizes the one thing they all
  /// actually share — the size — via `.copyWith(...)`.
  TextStyle get caption => appTypography.caption;
}
