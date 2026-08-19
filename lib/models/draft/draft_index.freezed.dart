// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_index.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftIndex {

 int get schemaVersion; List<String> get draftIds; String? get activeDraftId;
/// Create a copy of DraftIndex
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftIndexCopyWith<DraftIndex> get copyWith => _$DraftIndexCopyWithImpl<DraftIndex>(this as DraftIndex, _$identity);

  /// Serializes this DraftIndex to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftIndex&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other.draftIds, draftIds)&&(identical(other.activeDraftId, activeDraftId) || other.activeDraftId == activeDraftId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(draftIds),activeDraftId);

@override
String toString() {
  return 'DraftIndex(schemaVersion: $schemaVersion, draftIds: $draftIds, activeDraftId: $activeDraftId)';
}


}

/// @nodoc
abstract mixin class $DraftIndexCopyWith<$Res>  {
  factory $DraftIndexCopyWith(DraftIndex value, $Res Function(DraftIndex) _then) = _$DraftIndexCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, List<String> draftIds, String? activeDraftId
});




}
/// @nodoc
class _$DraftIndexCopyWithImpl<$Res>
    implements $DraftIndexCopyWith<$Res> {
  _$DraftIndexCopyWithImpl(this._self, this._then);

  final DraftIndex _self;
  final $Res Function(DraftIndex) _then;

/// Create a copy of DraftIndex
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? draftIds = null,Object? activeDraftId = freezed,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,draftIds: null == draftIds ? _self.draftIds : draftIds // ignore: cast_nullable_to_non_nullable
as List<String>,activeDraftId: freezed == activeDraftId ? _self.activeDraftId : activeDraftId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftIndex].
extension DraftIndexPatterns on DraftIndex {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftIndex value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftIndex() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftIndex value)  $default,){
final _that = this;
switch (_that) {
case _DraftIndex():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftIndex value)?  $default,){
final _that = this;
switch (_that) {
case _DraftIndex() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  List<String> draftIds,  String? activeDraftId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftIndex() when $default != null:
return $default(_that.schemaVersion,_that.draftIds,_that.activeDraftId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  List<String> draftIds,  String? activeDraftId)  $default,) {final _that = this;
switch (_that) {
case _DraftIndex():
return $default(_that.schemaVersion,_that.draftIds,_that.activeDraftId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  List<String> draftIds,  String? activeDraftId)?  $default,) {final _that = this;
switch (_that) {
case _DraftIndex() when $default != null:
return $default(_that.schemaVersion,_that.draftIds,_that.activeDraftId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftIndex implements DraftIndex {
  const _DraftIndex({required this.schemaVersion, final  List<String> draftIds = const <String>[], this.activeDraftId}): _draftIds = draftIds;
  factory _DraftIndex.fromJson(Map<String, dynamic> json) => _$DraftIndexFromJson(json);

@override final  int schemaVersion;
 final  List<String> _draftIds;
@override@JsonKey() List<String> get draftIds {
  if (_draftIds is EqualUnmodifiableListView) return _draftIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_draftIds);
}

@override final  String? activeDraftId;

/// Create a copy of DraftIndex
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftIndexCopyWith<_DraftIndex> get copyWith => __$DraftIndexCopyWithImpl<_DraftIndex>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftIndexToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftIndex&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&const DeepCollectionEquality().equals(other._draftIds, _draftIds)&&(identical(other.activeDraftId, activeDraftId) || other.activeDraftId == activeDraftId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,const DeepCollectionEquality().hash(_draftIds),activeDraftId);

@override
String toString() {
  return 'DraftIndex(schemaVersion: $schemaVersion, draftIds: $draftIds, activeDraftId: $activeDraftId)';
}


}

/// @nodoc
abstract mixin class _$DraftIndexCopyWith<$Res> implements $DraftIndexCopyWith<$Res> {
  factory _$DraftIndexCopyWith(_DraftIndex value, $Res Function(_DraftIndex) _then) = __$DraftIndexCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, List<String> draftIds, String? activeDraftId
});




}
/// @nodoc
class __$DraftIndexCopyWithImpl<$Res>
    implements _$DraftIndexCopyWith<$Res> {
  __$DraftIndexCopyWithImpl(this._self, this._then);

  final _DraftIndex _self;
  final $Res Function(_DraftIndex) _then;

/// Create a copy of DraftIndex
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? draftIds = null,Object? activeDraftId = freezed,}) {
  return _then(_DraftIndex(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,draftIds: null == draftIds ? _self._draftIds : draftIds // ignore: cast_nullable_to_non_nullable
as List<String>,activeDraftId: freezed == activeDraftId ? _self.activeDraftId : activeDraftId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
