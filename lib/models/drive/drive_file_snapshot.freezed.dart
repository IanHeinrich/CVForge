// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drive_file_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DriveFileSnapshot {

 String get fileId; int get version; DateTime get modifiedTime;
/// Create a copy of DriveFileSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriveFileSnapshotCopyWith<DriveFileSnapshot> get copyWith => _$DriveFileSnapshotCopyWithImpl<DriveFileSnapshot>(this as DriveFileSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriveFileSnapshot&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.version, version) || other.version == version)&&(identical(other.modifiedTime, modifiedTime) || other.modifiedTime == modifiedTime));
}


@override
int get hashCode => Object.hash(runtimeType,fileId,version,modifiedTime);

@override
String toString() {
  return 'DriveFileSnapshot(fileId: $fileId, version: $version, modifiedTime: $modifiedTime)';
}


}

/// @nodoc
abstract mixin class $DriveFileSnapshotCopyWith<$Res>  {
  factory $DriveFileSnapshotCopyWith(DriveFileSnapshot value, $Res Function(DriveFileSnapshot) _then) = _$DriveFileSnapshotCopyWithImpl;
@useResult
$Res call({
 String fileId, int version, DateTime modifiedTime
});




}
/// @nodoc
class _$DriveFileSnapshotCopyWithImpl<$Res>
    implements $DriveFileSnapshotCopyWith<$Res> {
  _$DriveFileSnapshotCopyWithImpl(this._self, this._then);

  final DriveFileSnapshot _self;
  final $Res Function(DriveFileSnapshot) _then;

/// Create a copy of DriveFileSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fileId = null,Object? version = null,Object? modifiedTime = null,}) {
  return _then(_self.copyWith(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,modifiedTime: null == modifiedTime ? _self.modifiedTime : modifiedTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DriveFileSnapshot].
extension DriveFileSnapshotPatterns on DriveFileSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriveFileSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriveFileSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriveFileSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _DriveFileSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriveFileSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _DriveFileSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String fileId,  int version,  DateTime modifiedTime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriveFileSnapshot() when $default != null:
return $default(_that.fileId,_that.version,_that.modifiedTime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String fileId,  int version,  DateTime modifiedTime)  $default,) {final _that = this;
switch (_that) {
case _DriveFileSnapshot():
return $default(_that.fileId,_that.version,_that.modifiedTime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String fileId,  int version,  DateTime modifiedTime)?  $default,) {final _that = this;
switch (_that) {
case _DriveFileSnapshot() when $default != null:
return $default(_that.fileId,_that.version,_that.modifiedTime);case _:
  return null;

}
}

}

/// @nodoc


class _DriveFileSnapshot implements DriveFileSnapshot {
  const _DriveFileSnapshot({required this.fileId, required this.version, required this.modifiedTime});
  

@override final  String fileId;
@override final  int version;
@override final  DateTime modifiedTime;

/// Create a copy of DriveFileSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriveFileSnapshotCopyWith<_DriveFileSnapshot> get copyWith => __$DriveFileSnapshotCopyWithImpl<_DriveFileSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriveFileSnapshot&&(identical(other.fileId, fileId) || other.fileId == fileId)&&(identical(other.version, version) || other.version == version)&&(identical(other.modifiedTime, modifiedTime) || other.modifiedTime == modifiedTime));
}


@override
int get hashCode => Object.hash(runtimeType,fileId,version,modifiedTime);

@override
String toString() {
  return 'DriveFileSnapshot(fileId: $fileId, version: $version, modifiedTime: $modifiedTime)';
}


}

/// @nodoc
abstract mixin class _$DriveFileSnapshotCopyWith<$Res> implements $DriveFileSnapshotCopyWith<$Res> {
  factory _$DriveFileSnapshotCopyWith(_DriveFileSnapshot value, $Res Function(_DriveFileSnapshot) _then) = __$DriveFileSnapshotCopyWithImpl;
@override @useResult
$Res call({
 String fileId, int version, DateTime modifiedTime
});




}
/// @nodoc
class __$DriveFileSnapshotCopyWithImpl<$Res>
    implements _$DriveFileSnapshotCopyWith<$Res> {
  __$DriveFileSnapshotCopyWithImpl(this._self, this._then);

  final _DriveFileSnapshot _self;
  final $Res Function(_DriveFileSnapshot) _then;

/// Create a copy of DriveFileSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fileId = null,Object? version = null,Object? modifiedTime = null,}) {
  return _then(_DriveFileSnapshot(
fileId: null == fileId ? _self.fileId : fileId // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,modifiedTime: null == modifiedTime ? _self.modifiedTime : modifiedTime // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
