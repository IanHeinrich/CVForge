// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvPreferences {

 RegionProfile get defaultRegion; String? get assistantProviderId; String? get assistantModelId;/// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
/// draft with, set via the "Save as my default" action in Studio.
/// Null means no default has ever been saved — a new draft then falls
/// back to its chosen template's own `CvTemplate.sectionOrder`. Never
/// re-resolved against an existing draft; it only ever seeds a draft
/// at creation time. Saved and reset together with
/// [defaultHiddenSections] by the same Studio action, so the two
/// fields never drift apart, but kept as two fields rather than one
/// combined value — same shape as `CvDraft.sectionOrder` /
/// `CvDraft.hiddenSections` being separate fields there too.
 List<CvSectionType>? get defaultSectionOrder;/// Same seed-only rationale as [defaultSectionOrder], one field over
/// for `CvDraft.hiddenSections` — which sections a brand-new draft
/// starts with hidden. Null means no default has been saved, so a new
/// draft starts with nothing hidden.
 Set<CvSectionType>? get defaultHiddenSections;/// When any field above last changed — the tie-break when two devices
/// have both edited their preferences since they last agreed. These
/// are flat scalars with no ids to merge by, so unlike the Vault there
/// is nothing finer to fall back on.
 DateTime get updatedAt;
/// Create a copy of CvPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvPreferencesCopyWith<CvPreferences> get copyWith => _$CvPreferencesCopyWithImpl<CvPreferences>(this as CvPreferences, _$identity);

  /// Serializes this CvPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvPreferences&&(identical(other.defaultRegion, defaultRegion) || other.defaultRegion == defaultRegion)&&(identical(other.assistantProviderId, assistantProviderId) || other.assistantProviderId == assistantProviderId)&&(identical(other.assistantModelId, assistantModelId) || other.assistantModelId == assistantModelId)&&const DeepCollectionEquality().equals(other.defaultSectionOrder, defaultSectionOrder)&&const DeepCollectionEquality().equals(other.defaultHiddenSections, defaultHiddenSections)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultRegion,assistantProviderId,assistantModelId,const DeepCollectionEquality().hash(defaultSectionOrder),const DeepCollectionEquality().hash(defaultHiddenSections),updatedAt);

@override
String toString() {
  return 'CvPreferences(defaultRegion: $defaultRegion, assistantProviderId: $assistantProviderId, assistantModelId: $assistantModelId, defaultSectionOrder: $defaultSectionOrder, defaultHiddenSections: $defaultHiddenSections, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CvPreferencesCopyWith<$Res>  {
  factory $CvPreferencesCopyWith(CvPreferences value, $Res Function(CvPreferences) _then) = _$CvPreferencesCopyWithImpl;
@useResult
$Res call({
 RegionProfile defaultRegion, String? assistantProviderId, String? assistantModelId, List<CvSectionType>? defaultSectionOrder, Set<CvSectionType>? defaultHiddenSections, DateTime updatedAt
});




}
/// @nodoc
class _$CvPreferencesCopyWithImpl<$Res>
    implements $CvPreferencesCopyWith<$Res> {
  _$CvPreferencesCopyWithImpl(this._self, this._then);

  final CvPreferences _self;
  final $Res Function(CvPreferences) _then;

/// Create a copy of CvPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultRegion = null,Object? assistantProviderId = freezed,Object? assistantModelId = freezed,Object? defaultSectionOrder = freezed,Object? defaultHiddenSections = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
defaultRegion: null == defaultRegion ? _self.defaultRegion : defaultRegion // ignore: cast_nullable_to_non_nullable
as RegionProfile,assistantProviderId: freezed == assistantProviderId ? _self.assistantProviderId : assistantProviderId // ignore: cast_nullable_to_non_nullable
as String?,assistantModelId: freezed == assistantModelId ? _self.assistantModelId : assistantModelId // ignore: cast_nullable_to_non_nullable
as String?,defaultSectionOrder: freezed == defaultSectionOrder ? _self.defaultSectionOrder : defaultSectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>?,defaultHiddenSections: freezed == defaultHiddenSections ? _self.defaultHiddenSections : defaultHiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CvPreferences].
extension CvPreferencesPatterns on CvPreferences {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvPreferences() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvPreferences value)  $default,){
final _that = this;
switch (_that) {
case _CvPreferences():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _CvPreferences() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RegionProfile defaultRegion,  String? assistantProviderId,  String? assistantModelId,  List<CvSectionType>? defaultSectionOrder,  Set<CvSectionType>? defaultHiddenSections,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvPreferences() when $default != null:
return $default(_that.defaultRegion,_that.assistantProviderId,_that.assistantModelId,_that.defaultSectionOrder,_that.defaultHiddenSections,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RegionProfile defaultRegion,  String? assistantProviderId,  String? assistantModelId,  List<CvSectionType>? defaultSectionOrder,  Set<CvSectionType>? defaultHiddenSections,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CvPreferences():
return $default(_that.defaultRegion,_that.assistantProviderId,_that.assistantModelId,_that.defaultSectionOrder,_that.defaultHiddenSections,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RegionProfile defaultRegion,  String? assistantProviderId,  String? assistantModelId,  List<CvSectionType>? defaultSectionOrder,  Set<CvSectionType>? defaultHiddenSections,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CvPreferences() when $default != null:
return $default(_that.defaultRegion,_that.assistantProviderId,_that.assistantModelId,_that.defaultSectionOrder,_that.defaultHiddenSections,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvPreferences implements CvPreferences {
  const _CvPreferences({this.defaultRegion = RegionProfile.uk, this.assistantProviderId, this.assistantModelId, final  List<CvSectionType>? defaultSectionOrder, final  Set<CvSectionType>? defaultHiddenSections, required this.updatedAt}): _defaultSectionOrder = defaultSectionOrder,_defaultHiddenSections = defaultHiddenSections;
  factory _CvPreferences.fromJson(Map<String, dynamic> json) => _$CvPreferencesFromJson(json);

@override@JsonKey() final  RegionProfile defaultRegion;
@override final  String? assistantProviderId;
@override final  String? assistantModelId;
/// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
/// draft with, set via the "Save as my default" action in Studio.
/// Null means no default has ever been saved — a new draft then falls
/// back to its chosen template's own `CvTemplate.sectionOrder`. Never
/// re-resolved against an existing draft; it only ever seeds a draft
/// at creation time. Saved and reset together with
/// [defaultHiddenSections] by the same Studio action, so the two
/// fields never drift apart, but kept as two fields rather than one
/// combined value — same shape as `CvDraft.sectionOrder` /
/// `CvDraft.hiddenSections` being separate fields there too.
 final  List<CvSectionType>? _defaultSectionOrder;
/// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
/// draft with, set via the "Save as my default" action in Studio.
/// Null means no default has ever been saved — a new draft then falls
/// back to its chosen template's own `CvTemplate.sectionOrder`. Never
/// re-resolved against an existing draft; it only ever seeds a draft
/// at creation time. Saved and reset together with
/// [defaultHiddenSections] by the same Studio action, so the two
/// fields never drift apart, but kept as two fields rather than one
/// combined value — same shape as `CvDraft.sectionOrder` /
/// `CvDraft.hiddenSections` being separate fields there too.
@override List<CvSectionType>? get defaultSectionOrder {
  final value = _defaultSectionOrder;
  if (value == null) return null;
  if (_defaultSectionOrder is EqualUnmodifiableListView) return _defaultSectionOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Same seed-only rationale as [defaultSectionOrder], one field over
/// for `CvDraft.hiddenSections` — which sections a brand-new draft
/// starts with hidden. Null means no default has been saved, so a new
/// draft starts with nothing hidden.
 final  Set<CvSectionType>? _defaultHiddenSections;
/// Same seed-only rationale as [defaultSectionOrder], one field over
/// for `CvDraft.hiddenSections` — which sections a brand-new draft
/// starts with hidden. Null means no default has been saved, so a new
/// draft starts with nothing hidden.
@override Set<CvSectionType>? get defaultHiddenSections {
  final value = _defaultHiddenSections;
  if (value == null) return null;
  if (_defaultHiddenSections is EqualUnmodifiableSetView) return _defaultHiddenSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(value);
}

/// When any field above last changed — the tie-break when two devices
/// have both edited their preferences since they last agreed. These
/// are flat scalars with no ids to merge by, so unlike the Vault there
/// is nothing finer to fall back on.
@override final  DateTime updatedAt;

/// Create a copy of CvPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvPreferencesCopyWith<_CvPreferences> get copyWith => __$CvPreferencesCopyWithImpl<_CvPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvPreferences&&(identical(other.defaultRegion, defaultRegion) || other.defaultRegion == defaultRegion)&&(identical(other.assistantProviderId, assistantProviderId) || other.assistantProviderId == assistantProviderId)&&(identical(other.assistantModelId, assistantModelId) || other.assistantModelId == assistantModelId)&&const DeepCollectionEquality().equals(other._defaultSectionOrder, _defaultSectionOrder)&&const DeepCollectionEquality().equals(other._defaultHiddenSections, _defaultHiddenSections)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,defaultRegion,assistantProviderId,assistantModelId,const DeepCollectionEquality().hash(_defaultSectionOrder),const DeepCollectionEquality().hash(_defaultHiddenSections),updatedAt);

@override
String toString() {
  return 'CvPreferences(defaultRegion: $defaultRegion, assistantProviderId: $assistantProviderId, assistantModelId: $assistantModelId, defaultSectionOrder: $defaultSectionOrder, defaultHiddenSections: $defaultHiddenSections, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CvPreferencesCopyWith<$Res> implements $CvPreferencesCopyWith<$Res> {
  factory _$CvPreferencesCopyWith(_CvPreferences value, $Res Function(_CvPreferences) _then) = __$CvPreferencesCopyWithImpl;
@override @useResult
$Res call({
 RegionProfile defaultRegion, String? assistantProviderId, String? assistantModelId, List<CvSectionType>? defaultSectionOrder, Set<CvSectionType>? defaultHiddenSections, DateTime updatedAt
});




}
/// @nodoc
class __$CvPreferencesCopyWithImpl<$Res>
    implements _$CvPreferencesCopyWith<$Res> {
  __$CvPreferencesCopyWithImpl(this._self, this._then);

  final _CvPreferences _self;
  final $Res Function(_CvPreferences) _then;

/// Create a copy of CvPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultRegion = null,Object? assistantProviderId = freezed,Object? assistantModelId = freezed,Object? defaultSectionOrder = freezed,Object? defaultHiddenSections = freezed,Object? updatedAt = null,}) {
  return _then(_CvPreferences(
defaultRegion: null == defaultRegion ? _self.defaultRegion : defaultRegion // ignore: cast_nullable_to_non_nullable
as RegionProfile,assistantProviderId: freezed == assistantProviderId ? _self.assistantProviderId : assistantProviderId // ignore: cast_nullable_to_non_nullable
as String?,assistantModelId: freezed == assistantModelId ? _self.assistantModelId : assistantModelId // ignore: cast_nullable_to_non_nullable
as String?,defaultSectionOrder: freezed == defaultSectionOrder ? _self._defaultSectionOrder : defaultSectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>?,defaultHiddenSections: freezed == defaultHiddenSections ? _self._defaultHiddenSections : defaultHiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
