// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_link_annotation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsLinkAnnotation {

 int get pageIndex; String get url;
/// Create a copy of AtsLinkAnnotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsLinkAnnotationCopyWith<AtsLinkAnnotation> get copyWith => _$AtsLinkAnnotationCopyWithImpl<AtsLinkAnnotation>(this as AtsLinkAnnotation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsLinkAnnotation&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,pageIndex,url);

@override
String toString() {
  return 'AtsLinkAnnotation(pageIndex: $pageIndex, url: $url)';
}


}

/// @nodoc
abstract mixin class $AtsLinkAnnotationCopyWith<$Res>  {
  factory $AtsLinkAnnotationCopyWith(AtsLinkAnnotation value, $Res Function(AtsLinkAnnotation) _then) = _$AtsLinkAnnotationCopyWithImpl;
@useResult
$Res call({
 int pageIndex, String url
});




}
/// @nodoc
class _$AtsLinkAnnotationCopyWithImpl<$Res>
    implements $AtsLinkAnnotationCopyWith<$Res> {
  _$AtsLinkAnnotationCopyWithImpl(this._self, this._then);

  final AtsLinkAnnotation _self;
  final $Res Function(AtsLinkAnnotation) _then;

/// Create a copy of AtsLinkAnnotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageIndex = null,Object? url = null,}) {
  return _then(_self.copyWith(
pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AtsLinkAnnotation].
extension AtsLinkAnnotationPatterns on AtsLinkAnnotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsLinkAnnotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsLinkAnnotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsLinkAnnotation value)  $default,){
final _that = this;
switch (_that) {
case _AtsLinkAnnotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsLinkAnnotation value)?  $default,){
final _that = this;
switch (_that) {
case _AtsLinkAnnotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pageIndex,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsLinkAnnotation() when $default != null:
return $default(_that.pageIndex,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pageIndex,  String url)  $default,) {final _that = this;
switch (_that) {
case _AtsLinkAnnotation():
return $default(_that.pageIndex,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pageIndex,  String url)?  $default,) {final _that = this;
switch (_that) {
case _AtsLinkAnnotation() when $default != null:
return $default(_that.pageIndex,_that.url);case _:
  return null;

}
}

}

/// @nodoc


class _AtsLinkAnnotation implements AtsLinkAnnotation {
  const _AtsLinkAnnotation({required this.pageIndex, required this.url});
  

@override final  int pageIndex;
@override final  String url;

/// Create a copy of AtsLinkAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsLinkAnnotationCopyWith<_AtsLinkAnnotation> get copyWith => __$AtsLinkAnnotationCopyWithImpl<_AtsLinkAnnotation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsLinkAnnotation&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.url, url) || other.url == url));
}


@override
int get hashCode => Object.hash(runtimeType,pageIndex,url);

@override
String toString() {
  return 'AtsLinkAnnotation(pageIndex: $pageIndex, url: $url)';
}


}

/// @nodoc
abstract mixin class _$AtsLinkAnnotationCopyWith<$Res> implements $AtsLinkAnnotationCopyWith<$Res> {
  factory _$AtsLinkAnnotationCopyWith(_AtsLinkAnnotation value, $Res Function(_AtsLinkAnnotation) _then) = __$AtsLinkAnnotationCopyWithImpl;
@override @useResult
$Res call({
 int pageIndex, String url
});




}
/// @nodoc
class __$AtsLinkAnnotationCopyWithImpl<$Res>
    implements _$AtsLinkAnnotationCopyWith<$Res> {
  __$AtsLinkAnnotationCopyWithImpl(this._self, this._then);

  final _AtsLinkAnnotation _self;
  final $Res Function(_AtsLinkAnnotation) _then;

/// Create a copy of AtsLinkAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageIndex = null,Object? url = null,}) {
  return _then(_AtsLinkAnnotation(
pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
