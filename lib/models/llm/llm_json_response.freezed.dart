// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_json_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LlmJsonResponse {

 Map<String, dynamic> get data; LlmUsage get usage;
/// Create a copy of LlmJsonResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmJsonResponseCopyWith<LlmJsonResponse> get copyWith => _$LlmJsonResponseCopyWithImpl<LlmJsonResponse>(this as LlmJsonResponse, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmJsonResponse&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.usage, usage) || other.usage == usage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),usage);

@override
String toString() {
  return 'LlmJsonResponse(data: $data, usage: $usage)';
}


}

/// @nodoc
abstract mixin class $LlmJsonResponseCopyWith<$Res>  {
  factory $LlmJsonResponseCopyWith(LlmJsonResponse value, $Res Function(LlmJsonResponse) _then) = _$LlmJsonResponseCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> data, LlmUsage usage
});


$LlmUsageCopyWith<$Res> get usage;

}
/// @nodoc
class _$LlmJsonResponseCopyWithImpl<$Res>
    implements $LlmJsonResponseCopyWith<$Res> {
  _$LlmJsonResponseCopyWithImpl(this._self, this._then);

  final LlmJsonResponse _self;
  final $Res Function(LlmJsonResponse) _then;

/// Create a copy of LlmJsonResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = null,Object? usage = null,}) {
  return _then(_self.copyWith(
data: null == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as LlmUsage,
  ));
}
/// Create a copy of LlmJsonResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LlmUsageCopyWith<$Res> get usage {
  
  return $LlmUsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}


/// Adds pattern-matching-related methods to [LlmJsonResponse].
extension LlmJsonResponsePatterns on LlmJsonResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LlmJsonResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LlmJsonResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LlmJsonResponse value)  $default,){
final _that = this;
switch (_that) {
case _LlmJsonResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LlmJsonResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LlmJsonResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> data,  LlmUsage usage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LlmJsonResponse() when $default != null:
return $default(_that.data,_that.usage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> data,  LlmUsage usage)  $default,) {final _that = this;
switch (_that) {
case _LlmJsonResponse():
return $default(_that.data,_that.usage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> data,  LlmUsage usage)?  $default,) {final _that = this;
switch (_that) {
case _LlmJsonResponse() when $default != null:
return $default(_that.data,_that.usage);case _:
  return null;

}
}

}

/// @nodoc


class _LlmJsonResponse implements LlmJsonResponse {
  const _LlmJsonResponse({required final  Map<String, dynamic> data, required this.usage}): _data = data;
  

 final  Map<String, dynamic> _data;
@override Map<String, dynamic> get data {
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_data);
}

@override final  LlmUsage usage;

/// Create a copy of LlmJsonResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LlmJsonResponseCopyWith<_LlmJsonResponse> get copyWith => __$LlmJsonResponseCopyWithImpl<_LlmJsonResponse>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LlmJsonResponse&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.usage, usage) || other.usage == usage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_data),usage);

@override
String toString() {
  return 'LlmJsonResponse(data: $data, usage: $usage)';
}


}

/// @nodoc
abstract mixin class _$LlmJsonResponseCopyWith<$Res> implements $LlmJsonResponseCopyWith<$Res> {
  factory _$LlmJsonResponseCopyWith(_LlmJsonResponse value, $Res Function(_LlmJsonResponse) _then) = __$LlmJsonResponseCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> data, LlmUsage usage
});


@override $LlmUsageCopyWith<$Res> get usage;

}
/// @nodoc
class __$LlmJsonResponseCopyWithImpl<$Res>
    implements _$LlmJsonResponseCopyWith<$Res> {
  __$LlmJsonResponseCopyWithImpl(this._self, this._then);

  final _LlmJsonResponse _self;
  final $Res Function(_LlmJsonResponse) _then;

/// Create a copy of LlmJsonResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = null,Object? usage = null,}) {
  return _then(_LlmJsonResponse(
data: null == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,usage: null == usage ? _self.usage : usage // ignore: cast_nullable_to_non_nullable
as LlmUsage,
  ));
}

/// Create a copy of LlmJsonResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LlmUsageCopyWith<$Res> get usage {
  
  return $LlmUsageCopyWith<$Res>(_self.usage, (value) {
    return _then(_self.copyWith(usage: value));
  });
}
}

// dart format on
