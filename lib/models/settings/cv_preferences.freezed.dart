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

 String? get aiAssistantProviderId; String? get aiAssistantModelId;/// When an AI Assistant connection test first succeeded on *any*
/// device. Lets a second device prompt for just the key rather than
/// the whole setup, without the key itself having to travel.
///
/// Never cleared by removing a key — it records that setup happened,
/// not that this device is configured. [ApiKeyOrigin] owns the latter.
 DateTime? get aiAssistantConfiguredAt;/// The UI language as a BCP-47 tag; null means "follow the browser's
/// own locale", so only an *explicit* choice ever syncs.
///
/// A tag rather than an enum, so adding a language is one new `.arb`
/// file. `LocalizationService` validates it on read and falls back to
/// the platform locale for a language this build no longer ships.
///
/// Never the language the CV is written in — that is
/// `DocumentLanguage`, which owns the distinction.
 String? get localeTag;/// When any field above last changed — the tie-break when two devices
/// have both edited since they last agreed. Flat scalars with no ids,
/// so unlike the Vault there is nothing finer to merge by.
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvPreferences&&(identical(other.aiAssistantProviderId, aiAssistantProviderId) || other.aiAssistantProviderId == aiAssistantProviderId)&&(identical(other.aiAssistantModelId, aiAssistantModelId) || other.aiAssistantModelId == aiAssistantModelId)&&(identical(other.aiAssistantConfiguredAt, aiAssistantConfiguredAt) || other.aiAssistantConfiguredAt == aiAssistantConfiguredAt)&&(identical(other.localeTag, localeTag) || other.localeTag == localeTag)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aiAssistantProviderId,aiAssistantModelId,aiAssistantConfiguredAt,localeTag,updatedAt);

@override
String toString() {
  return 'CvPreferences(aiAssistantProviderId: $aiAssistantProviderId, aiAssistantModelId: $aiAssistantModelId, aiAssistantConfiguredAt: $aiAssistantConfiguredAt, localeTag: $localeTag, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CvPreferencesCopyWith<$Res>  {
  factory $CvPreferencesCopyWith(CvPreferences value, $Res Function(CvPreferences) _then) = _$CvPreferencesCopyWithImpl;
@useResult
$Res call({
 String? aiAssistantProviderId, String? aiAssistantModelId, DateTime? aiAssistantConfiguredAt, String? localeTag, DateTime updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? aiAssistantProviderId = freezed,Object? aiAssistantModelId = freezed,Object? aiAssistantConfiguredAt = freezed,Object? localeTag = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
aiAssistantProviderId: freezed == aiAssistantProviderId ? _self.aiAssistantProviderId : aiAssistantProviderId // ignore: cast_nullable_to_non_nullable
as String?,aiAssistantModelId: freezed == aiAssistantModelId ? _self.aiAssistantModelId : aiAssistantModelId // ignore: cast_nullable_to_non_nullable
as String?,aiAssistantConfiguredAt: freezed == aiAssistantConfiguredAt ? _self.aiAssistantConfiguredAt : aiAssistantConfiguredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localeTag: freezed == localeTag ? _self.localeTag : localeTag // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? aiAssistantProviderId,  String? aiAssistantModelId,  DateTime? aiAssistantConfiguredAt,  String? localeTag,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvPreferences() when $default != null:
return $default(_that.aiAssistantProviderId,_that.aiAssistantModelId,_that.aiAssistantConfiguredAt,_that.localeTag,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? aiAssistantProviderId,  String? aiAssistantModelId,  DateTime? aiAssistantConfiguredAt,  String? localeTag,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CvPreferences():
return $default(_that.aiAssistantProviderId,_that.aiAssistantModelId,_that.aiAssistantConfiguredAt,_that.localeTag,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? aiAssistantProviderId,  String? aiAssistantModelId,  DateTime? aiAssistantConfiguredAt,  String? localeTag,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CvPreferences() when $default != null:
return $default(_that.aiAssistantProviderId,_that.aiAssistantModelId,_that.aiAssistantConfiguredAt,_that.localeTag,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvPreferences implements CvPreferences {
  const _CvPreferences({this.aiAssistantProviderId, this.aiAssistantModelId, this.aiAssistantConfiguredAt, this.localeTag, required this.updatedAt});
  factory _CvPreferences.fromJson(Map<String, dynamic> json) => _$CvPreferencesFromJson(json);

@override final  String? aiAssistantProviderId;
@override final  String? aiAssistantModelId;
/// When an AI Assistant connection test first succeeded on *any*
/// device. Lets a second device prompt for just the key rather than
/// the whole setup, without the key itself having to travel.
///
/// Never cleared by removing a key — it records that setup happened,
/// not that this device is configured. [ApiKeyOrigin] owns the latter.
@override final  DateTime? aiAssistantConfiguredAt;
/// The UI language as a BCP-47 tag; null means "follow the browser's
/// own locale", so only an *explicit* choice ever syncs.
///
/// A tag rather than an enum, so adding a language is one new `.arb`
/// file. `LocalizationService` validates it on read and falls back to
/// the platform locale for a language this build no longer ships.
///
/// Never the language the CV is written in — that is
/// `DocumentLanguage`, which owns the distinction.
@override final  String? localeTag;
/// When any field above last changed — the tie-break when two devices
/// have both edited since they last agreed. Flat scalars with no ids,
/// so unlike the Vault there is nothing finer to merge by.
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvPreferences&&(identical(other.aiAssistantProviderId, aiAssistantProviderId) || other.aiAssistantProviderId == aiAssistantProviderId)&&(identical(other.aiAssistantModelId, aiAssistantModelId) || other.aiAssistantModelId == aiAssistantModelId)&&(identical(other.aiAssistantConfiguredAt, aiAssistantConfiguredAt) || other.aiAssistantConfiguredAt == aiAssistantConfiguredAt)&&(identical(other.localeTag, localeTag) || other.localeTag == localeTag)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,aiAssistantProviderId,aiAssistantModelId,aiAssistantConfiguredAt,localeTag,updatedAt);

@override
String toString() {
  return 'CvPreferences(aiAssistantProviderId: $aiAssistantProviderId, aiAssistantModelId: $aiAssistantModelId, aiAssistantConfiguredAt: $aiAssistantConfiguredAt, localeTag: $localeTag, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CvPreferencesCopyWith<$Res> implements $CvPreferencesCopyWith<$Res> {
  factory _$CvPreferencesCopyWith(_CvPreferences value, $Res Function(_CvPreferences) _then) = __$CvPreferencesCopyWithImpl;
@override @useResult
$Res call({
 String? aiAssistantProviderId, String? aiAssistantModelId, DateTime? aiAssistantConfiguredAt, String? localeTag, DateTime updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? aiAssistantProviderId = freezed,Object? aiAssistantModelId = freezed,Object? aiAssistantConfiguredAt = freezed,Object? localeTag = freezed,Object? updatedAt = null,}) {
  return _then(_CvPreferences(
aiAssistantProviderId: freezed == aiAssistantProviderId ? _self.aiAssistantProviderId : aiAssistantProviderId // ignore: cast_nullable_to_non_nullable
as String?,aiAssistantModelId: freezed == aiAssistantModelId ? _self.aiAssistantModelId : aiAssistantModelId // ignore: cast_nullable_to_non_nullable
as String?,aiAssistantConfiguredAt: freezed == aiAssistantConfiguredAt ? _self.aiAssistantConfiguredAt : aiAssistantConfiguredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,localeTag: freezed == localeTag ? _self.localeTag : localeTag // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
