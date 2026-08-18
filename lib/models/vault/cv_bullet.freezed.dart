// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_bullet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvBullet {

 String get id; String? get label; String get text;
/// Create a copy of CvBullet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvBulletCopyWith<CvBullet> get copyWith => _$CvBulletCopyWithImpl<CvBullet>(this as CvBullet, _$identity);

  /// Serializes this CvBullet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvBullet&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,text);

@override
String toString() {
  return 'CvBullet(id: $id, label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class $CvBulletCopyWith<$Res>  {
  factory $CvBulletCopyWith(CvBullet value, $Res Function(CvBullet) _then) = _$CvBulletCopyWithImpl;
@useResult
$Res call({
 String id, String? label, String text
});




}
/// @nodoc
class _$CvBulletCopyWithImpl<$Res>
    implements $CvBulletCopyWith<$Res> {
  _$CvBulletCopyWithImpl(this._self, this._then);

  final CvBullet _self;
  final $Res Function(CvBullet) _then;

/// Create a copy of CvBullet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? text = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CvBullet].
extension CvBulletPatterns on CvBullet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvBullet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvBullet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvBullet value)  $default,){
final _that = this;
switch (_that) {
case _CvBullet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvBullet value)?  $default,){
final _that = this;
switch (_that) {
case _CvBullet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  String text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvBullet() when $default != null:
return $default(_that.id,_that.label,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  String text)  $default,) {final _that = this;
switch (_that) {
case _CvBullet():
return $default(_that.id,_that.label,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  String text)?  $default,) {final _that = this;
switch (_that) {
case _CvBullet() when $default != null:
return $default(_that.id,_that.label,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvBullet implements CvBullet {
  const _CvBullet({required this.id, this.label, required this.text});
  factory _CvBullet.fromJson(Map<String, dynamic> json) => _$CvBulletFromJson(json);

@override final  String id;
@override final  String? label;
@override final  String text;

/// Create a copy of CvBullet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvBulletCopyWith<_CvBullet> get copyWith => __$CvBulletCopyWithImpl<_CvBullet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvBulletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvBullet&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,text);

@override
String toString() {
  return 'CvBullet(id: $id, label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class _$CvBulletCopyWith<$Res> implements $CvBulletCopyWith<$Res> {
  factory _$CvBulletCopyWith(_CvBullet value, $Res Function(_CvBullet) _then) = __$CvBulletCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, String text
});




}
/// @nodoc
class __$CvBulletCopyWithImpl<$Res>
    implements _$CvBulletCopyWith<$Res> {
  __$CvBulletCopyWithImpl(this._self, this._then);

  final _CvBullet _self;
  final $Res Function(_CvBullet) _then;

/// Create a copy of CvBullet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? text = null,}) {
  return _then(_CvBullet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
