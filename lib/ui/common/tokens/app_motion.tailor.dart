// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_motion.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppMotionTailorMixin on ThemeExtension<AppMotion> {
  Duration get fast;
  Duration get camera;
  Duration get layout;
  Duration get iconSwap;

  @override
  AppMotion copyWith({
    Duration? fast,
    Duration? camera,
    Duration? layout,
    Duration? iconSwap,
  }) {
    return AppMotion(
      fast: fast ?? this.fast,
      camera: camera ?? this.camera,
      layout: layout ?? this.layout,
      iconSwap: iconSwap ?? this.iconSwap,
    );
  }

  @override
  AppMotion lerp(covariant ThemeExtension<AppMotion>? other, double t) {
    if (other is! AppMotion) return this as AppMotion;
    return AppMotion(
      fast: t < 0.5 ? fast : other.fast,
      camera: t < 0.5 ? camera : other.camera,
      layout: t < 0.5 ? layout : other.layout,
      iconSwap: t < 0.5 ? iconSwap : other.iconSwap,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppMotion &&
            const DeepCollectionEquality().equals(fast, other.fast) &&
            const DeepCollectionEquality().equals(camera, other.camera) &&
            const DeepCollectionEquality().equals(layout, other.layout) &&
            const DeepCollectionEquality().equals(iconSwap, other.iconSwap));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(fast),
      const DeepCollectionEquality().hash(camera),
      const DeepCollectionEquality().hash(layout),
      const DeepCollectionEquality().hash(iconSwap),
    );
  }
}

extension AppMotionBuildContextProps on BuildContext {
  AppMotion get appMotion => Theme.of(this).extension<AppMotion>()!;
  Duration get fast => appMotion.fast;

  /// The X-Ray overlay's camera pan/zoom (`XrayCameraController`).
  Duration get camera => appMotion.camera;

  /// A panel/column reflow — `VaultViewDesktop`'s card-list/editor split
  /// easing its width and alignment when the editor opens or closes.
  Duration get layout => appMotion.layout;

  /// One glyph turning and fading into another in place, as
  /// `ThemeModeToggle`'s sun/moon/monitor does. Slower than [fast], which
  /// is short enough that a rotation reads as a flicker, and unrelated to
  /// [layout]/[camera] — nothing is being laid out or panned.
  Duration get iconSwap => appMotion.iconSwap;
}
