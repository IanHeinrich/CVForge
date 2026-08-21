// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_usage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LlmUsage {

 int get inputTokens; int get outputTokens;
/// Create a copy of LlmUsage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmUsageCopyWith<LlmUsage> get copyWith => _$LlmUsageCopyWithImpl<LlmUsage>(this as LlmUsage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmUsage&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,outputTokens);

@override
String toString() {
  return 'LlmUsage(inputTokens: $inputTokens, outputTokens: $outputTokens)';
}


}

/// @nodoc
abstract mixin class $LlmUsageCopyWith<$Res>  {
  factory $LlmUsageCopyWith(LlmUsage value, $Res Function(LlmUsage) _then) = _$LlmUsageCopyWithImpl;
@useResult
$Res call({
 int inputTokens, int outputTokens
});




}
/// @nodoc
class _$LlmUsageCopyWithImpl<$Res>
    implements $LlmUsageCopyWith<$Res> {
  _$LlmUsageCopyWithImpl(this._self, this._then);

  final LlmUsage _self;
  final $Res Function(LlmUsage) _then;

/// Create a copy of LlmUsage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? inputTokens = null,Object? outputTokens = null,}) {
  return _then(_self.copyWith(
inputTokens: null == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int,outputTokens: null == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LlmUsage].
extension LlmUsagePatterns on LlmUsage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LlmUsage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LlmUsage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LlmUsage value)  $default,){
final _that = this;
switch (_that) {
case _LlmUsage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LlmUsage value)?  $default,){
final _that = this;
switch (_that) {
case _LlmUsage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int inputTokens,  int outputTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LlmUsage() when $default != null:
return $default(_that.inputTokens,_that.outputTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int inputTokens,  int outputTokens)  $default,) {final _that = this;
switch (_that) {
case _LlmUsage():
return $default(_that.inputTokens,_that.outputTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int inputTokens,  int outputTokens)?  $default,) {final _that = this;
switch (_that) {
case _LlmUsage() when $default != null:
return $default(_that.inputTokens,_that.outputTokens);case _:
  return null;

}
}

}

/// @nodoc


class _LlmUsage implements LlmUsage {
  const _LlmUsage({required this.inputTokens, required this.outputTokens});
  

@override final  int inputTokens;
@override final  int outputTokens;

/// Create a copy of LlmUsage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LlmUsageCopyWith<_LlmUsage> get copyWith => __$LlmUsageCopyWithImpl<_LlmUsage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LlmUsage&&(identical(other.inputTokens, inputTokens) || other.inputTokens == inputTokens)&&(identical(other.outputTokens, outputTokens) || other.outputTokens == outputTokens));
}


@override
int get hashCode => Object.hash(runtimeType,inputTokens,outputTokens);

@override
String toString() {
  return 'LlmUsage(inputTokens: $inputTokens, outputTokens: $outputTokens)';
}


}

/// @nodoc
abstract mixin class _$LlmUsageCopyWith<$Res> implements $LlmUsageCopyWith<$Res> {
  factory _$LlmUsageCopyWith(_LlmUsage value, $Res Function(_LlmUsage) _then) = __$LlmUsageCopyWithImpl;
@override @useResult
$Res call({
 int inputTokens, int outputTokens
});




}
/// @nodoc
class __$LlmUsageCopyWithImpl<$Res>
    implements _$LlmUsageCopyWith<$Res> {
  __$LlmUsageCopyWithImpl(this._self, this._then);

  final _LlmUsage _self;
  final $Res Function(_LlmUsage) _then;

/// Create a copy of LlmUsage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? inputTokens = null,Object? outputTokens = null,}) {
  return _then(_LlmUsage(
inputTokens: null == inputTokens ? _self.inputTokens : inputTokens // ignore: cast_nullable_to_non_nullable
as int,outputTokens: null == outputTokens ? _self.outputTokens : outputTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
