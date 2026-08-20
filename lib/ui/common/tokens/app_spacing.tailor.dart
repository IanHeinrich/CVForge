// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_spacing.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppSpacingTailorMixin on ThemeExtension<AppSpacing> {
  double get gapTiny;
  double get gapSmall;
  double get gapMedium;
  double get paddingHairline;
  double get paddingTight;
  double get paddingCompact;
  double get paddingDefault;
  double get paddingPanel;
  double get paddingPage;

  @override
  AppSpacing copyWith({
    double? gapTiny,
    double? gapSmall,
    double? gapMedium,
    double? paddingHairline,
    double? paddingTight,
    double? paddingCompact,
    double? paddingDefault,
    double? paddingPanel,
    double? paddingPage,
  }) {
    return AppSpacing(
      gapTiny: gapTiny ?? this.gapTiny,
      gapSmall: gapSmall ?? this.gapSmall,
      gapMedium: gapMedium ?? this.gapMedium,
      paddingHairline: paddingHairline ?? this.paddingHairline,
      paddingTight: paddingTight ?? this.paddingTight,
      paddingCompact: paddingCompact ?? this.paddingCompact,
      paddingDefault: paddingDefault ?? this.paddingDefault,
      paddingPanel: paddingPanel ?? this.paddingPanel,
      paddingPage: paddingPage ?? this.paddingPage,
    );
  }

  @override
  AppSpacing lerp(covariant ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) return this as AppSpacing;
    return AppSpacing(
      gapTiny: t < 0.5 ? gapTiny : other.gapTiny,
      gapSmall: t < 0.5 ? gapSmall : other.gapSmall,
      gapMedium: t < 0.5 ? gapMedium : other.gapMedium,
      paddingHairline: t < 0.5 ? paddingHairline : other.paddingHairline,
      paddingTight: t < 0.5 ? paddingTight : other.paddingTight,
      paddingCompact: t < 0.5 ? paddingCompact : other.paddingCompact,
      paddingDefault: t < 0.5 ? paddingDefault : other.paddingDefault,
      paddingPanel: t < 0.5 ? paddingPanel : other.paddingPanel,
      paddingPage: t < 0.5 ? paddingPage : other.paddingPage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppSpacing &&
            const DeepCollectionEquality().equals(gapTiny, other.gapTiny) &&
            const DeepCollectionEquality().equals(gapSmall, other.gapSmall) &&
            const DeepCollectionEquality().equals(gapMedium, other.gapMedium) &&
            const DeepCollectionEquality().equals(
              paddingHairline,
              other.paddingHairline,
            ) &&
            const DeepCollectionEquality().equals(
              paddingTight,
              other.paddingTight,
            ) &&
            const DeepCollectionEquality().equals(
              paddingCompact,
              other.paddingCompact,
            ) &&
            const DeepCollectionEquality().equals(
              paddingDefault,
              other.paddingDefault,
            ) &&
            const DeepCollectionEquality().equals(
              paddingPanel,
              other.paddingPanel,
            ) &&
            const DeepCollectionEquality().equals(
              paddingPage,
              other.paddingPage,
            ));
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(gapTiny),
      const DeepCollectionEquality().hash(gapSmall),
      const DeepCollectionEquality().hash(gapMedium),
      const DeepCollectionEquality().hash(paddingHairline),
      const DeepCollectionEquality().hash(paddingTight),
      const DeepCollectionEquality().hash(paddingCompact),
      const DeepCollectionEquality().hash(paddingDefault),
      const DeepCollectionEquality().hash(paddingPanel),
      const DeepCollectionEquality().hash(paddingPage),
    );
  }
}

extension AppSpacingBuildContextProps on BuildContext {
  AppSpacing get appSpacing => Theme.of(this).extension<AppSpacing>()!;

  /// Spacing between sibling widgets — was `ui_helpers.dart`'s
  /// `verticalSpace*`/`horizontalSpace*` Widget constants.
  double get gapTiny => appSpacing.gapTiny;
  double get gapSmall => appSpacing.gapSmall;
  double get gapMedium => appSpacing.gapMedium;

  /// Padding inside a container's own border — was `app_constants.dart`'s
  /// `kdPadding*`.
  ///
  /// [paddingHairline] is the one tier below [paddingTight] — the smallest
  /// deliberate gap in the scale (an icon nudged next to adjacent text, an
  /// inline editor's own vertical breathing room), rather than a semantic
  /// role of its own like the others.
  double get paddingHairline => appSpacing.paddingHairline;
  double get paddingTight => appSpacing.paddingTight;
  double get paddingCompact => appSpacing.paddingCompact;
  double get paddingDefault => appSpacing.paddingDefault;
  double get paddingPanel => appSpacing.paddingPanel;
  double get paddingPage => appSpacing.paddingPage;
}
