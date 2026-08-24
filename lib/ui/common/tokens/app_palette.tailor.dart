// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_palette.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppPaletteTailorMixin on ThemeExtension<AppPalette> {
  Color get placeholder;
  Color get warning;
  Color get success;

  @override
  AppPalette copyWith({Color? placeholder, Color? warning, Color? success}) {
    return AppPalette(
      placeholder: placeholder ?? this.placeholder,
      warning: warning ?? this.warning,
      success: success ?? this.success,
    );
  }

  @override
  AppPalette lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this as AppPalette;
    return AppPalette(
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppPalette &&
            const DeepCollectionEquality().equals(
              placeholder,
              other.placeholder,
            ) &&
            const DeepCollectionEquality().equals(warning, other.warning) &&
            const DeepCollectionEquality().equals(success, other.success));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(placeholder),
      const DeepCollectionEquality().hash(warning),
      const DeepCollectionEquality().hash(success),
    );
  }
}

extension AppPaletteBuildContextProps on BuildContext {
  AppPalette get appPalette => Theme.of(this).extension<AppPalette>()!;

  /// Placeholder and disabled text/icons. Not `onSurface` at reduced
  /// opacity, which is M3's convention — this palette's value is its own
  /// cooler tone rather than a dimmed version of the foreground.
  Color get placeholder => appPalette.placeholder;

  /// Warning severity, for evidence boxes and rail badges.
  Color get warning => appPalette.warning;

  /// A positive/confirmed state — a successful connection test, a clean
  /// backup.
  Color get success => appPalette.success;
}
