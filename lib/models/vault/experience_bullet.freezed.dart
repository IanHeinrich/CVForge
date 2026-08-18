// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experience_bullet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ExperienceBullet {

 String get id; String? get label; String get text;
/// Create a copy of ExperienceBullet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExperienceBulletCopyWith<ExperienceBullet> get copyWith => _$ExperienceBulletCopyWithImpl<ExperienceBullet>(this as ExperienceBullet, _$identity);

  /// Serializes this ExperienceBullet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExperienceBullet&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,text);

@override
String toString() {
  return 'ExperienceBullet(id: $id, label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class $ExperienceBulletCopyWith<$Res>  {
  factory $ExperienceBulletCopyWith(ExperienceBullet value, $Res Function(ExperienceBullet) _then) = _$ExperienceBulletCopyWithImpl;
@useResult
$Res call({
 String id, String? label, String text
});




}
/// @nodoc
class _$ExperienceBulletCopyWithImpl<$Res>
    implements $ExperienceBulletCopyWith<$Res> {
  _$ExperienceBulletCopyWithImpl(this._self, this._then);

  final ExperienceBullet _self;
  final $Res Function(ExperienceBullet) _then;

/// Create a copy of ExperienceBullet
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


/// Adds pattern-matching-related methods to [ExperienceBullet].
extension ExperienceBulletPatterns on ExperienceBullet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExperienceBullet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExperienceBullet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExperienceBullet value)  $default,){
final _that = this;
switch (_that) {
case _ExperienceBullet():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExperienceBullet value)?  $default,){
final _that = this;
switch (_that) {
case _ExperienceBullet() when $default != null:
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
case _ExperienceBullet() when $default != null:
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
case _ExperienceBullet():
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
case _ExperienceBullet() when $default != null:
return $default(_that.id,_that.label,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExperienceBullet implements ExperienceBullet {
  const _ExperienceBullet({required this.id, this.label, required this.text});
  factory _ExperienceBullet.fromJson(Map<String, dynamic> json) => _$ExperienceBulletFromJson(json);

@override final  String id;
@override final  String? label;
@override final  String text;

/// Create a copy of ExperienceBullet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExperienceBulletCopyWith<_ExperienceBullet> get copyWith => __$ExperienceBulletCopyWithImpl<_ExperienceBullet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExperienceBulletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExperienceBullet&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,text);

@override
String toString() {
  return 'ExperienceBullet(id: $id, label: $label, text: $text)';
}


}

/// @nodoc
abstract mixin class _$ExperienceBulletCopyWith<$Res> implements $ExperienceBulletCopyWith<$Res> {
  factory _$ExperienceBulletCopyWith(_ExperienceBullet value, $Res Function(_ExperienceBullet) _then) = __$ExperienceBulletCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, String text
});




}
/// @nodoc
class __$ExperienceBulletCopyWithImpl<$Res>
    implements _$ExperienceBulletCopyWith<$Res> {
  __$ExperienceBulletCopyWithImpl(this._self, this._then);

  final _ExperienceBullet _self;
  final $Res Function(_ExperienceBullet) _then;

/// Create a copy of ExperienceBullet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? text = null,}) {
  return _then(_ExperienceBullet(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
