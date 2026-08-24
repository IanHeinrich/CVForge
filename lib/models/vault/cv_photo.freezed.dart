// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvPhoto {

 String get jpegBase64; int get widthPx; int get heightPx;
/// Create a copy of CvPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvPhotoCopyWith<CvPhoto> get copyWith => _$CvPhotoCopyWithImpl<CvPhoto>(this as CvPhoto, _$identity);

  /// Serializes this CvPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvPhoto&&(identical(other.jpegBase64, jpegBase64) || other.jpegBase64 == jpegBase64)&&(identical(other.widthPx, widthPx) || other.widthPx == widthPx)&&(identical(other.heightPx, heightPx) || other.heightPx == heightPx));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jpegBase64,widthPx,heightPx);

@override
String toString() {
  return 'CvPhoto(jpegBase64: $jpegBase64, widthPx: $widthPx, heightPx: $heightPx)';
}


}

/// @nodoc
abstract mixin class $CvPhotoCopyWith<$Res>  {
  factory $CvPhotoCopyWith(CvPhoto value, $Res Function(CvPhoto) _then) = _$CvPhotoCopyWithImpl;
@useResult
$Res call({
 String jpegBase64, int widthPx, int heightPx
});




}
/// @nodoc
class _$CvPhotoCopyWithImpl<$Res>
    implements $CvPhotoCopyWith<$Res> {
  _$CvPhotoCopyWithImpl(this._self, this._then);

  final CvPhoto _self;
  final $Res Function(CvPhoto) _then;

/// Create a copy of CvPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? jpegBase64 = null,Object? widthPx = null,Object? heightPx = null,}) {
  return _then(_self.copyWith(
jpegBase64: null == jpegBase64 ? _self.jpegBase64 : jpegBase64 // ignore: cast_nullable_to_non_nullable
as String,widthPx: null == widthPx ? _self.widthPx : widthPx // ignore: cast_nullable_to_non_nullable
as int,heightPx: null == heightPx ? _self.heightPx : heightPx // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CvPhoto].
extension CvPhotoPatterns on CvPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvPhoto value)  $default,){
final _that = this;
switch (_that) {
case _CvPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _CvPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String jpegBase64,  int widthPx,  int heightPx)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvPhoto() when $default != null:
return $default(_that.jpegBase64,_that.widthPx,_that.heightPx);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String jpegBase64,  int widthPx,  int heightPx)  $default,) {final _that = this;
switch (_that) {
case _CvPhoto():
return $default(_that.jpegBase64,_that.widthPx,_that.heightPx);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String jpegBase64,  int widthPx,  int heightPx)?  $default,) {final _that = this;
switch (_that) {
case _CvPhoto() when $default != null:
return $default(_that.jpegBase64,_that.widthPx,_that.heightPx);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvPhoto implements CvPhoto {
  const _CvPhoto({required this.jpegBase64, required this.widthPx, required this.heightPx});
  factory _CvPhoto.fromJson(Map<String, dynamic> json) => _$CvPhotoFromJson(json);

@override final  String jpegBase64;
@override final  int widthPx;
@override final  int heightPx;

/// Create a copy of CvPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvPhotoCopyWith<_CvPhoto> get copyWith => __$CvPhotoCopyWithImpl<_CvPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvPhoto&&(identical(other.jpegBase64, jpegBase64) || other.jpegBase64 == jpegBase64)&&(identical(other.widthPx, widthPx) || other.widthPx == widthPx)&&(identical(other.heightPx, heightPx) || other.heightPx == heightPx));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,jpegBase64,widthPx,heightPx);

@override
String toString() {
  return 'CvPhoto(jpegBase64: $jpegBase64, widthPx: $widthPx, heightPx: $heightPx)';
}


}

/// @nodoc
abstract mixin class _$CvPhotoCopyWith<$Res> implements $CvPhotoCopyWith<$Res> {
  factory _$CvPhotoCopyWith(_CvPhoto value, $Res Function(_CvPhoto) _then) = __$CvPhotoCopyWithImpl;
@override @useResult
$Res call({
 String jpegBase64, int widthPx, int heightPx
});




}
/// @nodoc
class __$CvPhotoCopyWithImpl<$Res>
    implements _$CvPhotoCopyWith<$Res> {
  __$CvPhotoCopyWithImpl(this._self, this._then);

  final _CvPhoto _self;
  final $Res Function(_CvPhoto) _then;

/// Create a copy of CvPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? jpegBase64 = null,Object? widthPx = null,Object? heightPx = null,}) {
  return _then(_CvPhoto(
jpegBase64: null == jpegBase64 ? _self.jpegBase64 : jpegBase64 // ignore: cast_nullable_to_non_nullable
as String,widthPx: null == widthPx ? _self.widthPx : widthPx // ignore: cast_nullable_to_non_nullable
as int,heightPx: null == heightPx ? _self.heightPx : heightPx // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
