// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_model_option.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LlmModelOption {

 String get id; String get label; double get inputPricePerMTok; double get outputPricePerMTok;
/// Create a copy of LlmModelOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LlmModelOptionCopyWith<LlmModelOption> get copyWith => _$LlmModelOptionCopyWithImpl<LlmModelOption>(this as LlmModelOption, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LlmModelOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.inputPricePerMTok, inputPricePerMTok) || other.inputPricePerMTok == inputPricePerMTok)&&(identical(other.outputPricePerMTok, outputPricePerMTok) || other.outputPricePerMTok == outputPricePerMTok));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,inputPricePerMTok,outputPricePerMTok);

@override
String toString() {
  return 'LlmModelOption(id: $id, label: $label, inputPricePerMTok: $inputPricePerMTok, outputPricePerMTok: $outputPricePerMTok)';
}


}

/// @nodoc
abstract mixin class $LlmModelOptionCopyWith<$Res>  {
  factory $LlmModelOptionCopyWith(LlmModelOption value, $Res Function(LlmModelOption) _then) = _$LlmModelOptionCopyWithImpl;
@useResult
$Res call({
 String id, String label, double inputPricePerMTok, double outputPricePerMTok
});




}
/// @nodoc
class _$LlmModelOptionCopyWithImpl<$Res>
    implements $LlmModelOptionCopyWith<$Res> {
  _$LlmModelOptionCopyWithImpl(this._self, this._then);

  final LlmModelOption _self;
  final $Res Function(LlmModelOption) _then;

/// Create a copy of LlmModelOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,Object? inputPricePerMTok = null,Object? outputPricePerMTok = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,inputPricePerMTok: null == inputPricePerMTok ? _self.inputPricePerMTok : inputPricePerMTok // ignore: cast_nullable_to_non_nullable
as double,outputPricePerMTok: null == outputPricePerMTok ? _self.outputPricePerMTok : outputPricePerMTok // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LlmModelOption].
extension LlmModelOptionPatterns on LlmModelOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LlmModelOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LlmModelOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LlmModelOption value)  $default,){
final _that = this;
switch (_that) {
case _LlmModelOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LlmModelOption value)?  $default,){
final _that = this;
switch (_that) {
case _LlmModelOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String label,  double inputPricePerMTok,  double outputPricePerMTok)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LlmModelOption() when $default != null:
return $default(_that.id,_that.label,_that.inputPricePerMTok,_that.outputPricePerMTok);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String label,  double inputPricePerMTok,  double outputPricePerMTok)  $default,) {final _that = this;
switch (_that) {
case _LlmModelOption():
return $default(_that.id,_that.label,_that.inputPricePerMTok,_that.outputPricePerMTok);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String label,  double inputPricePerMTok,  double outputPricePerMTok)?  $default,) {final _that = this;
switch (_that) {
case _LlmModelOption() when $default != null:
return $default(_that.id,_that.label,_that.inputPricePerMTok,_that.outputPricePerMTok);case _:
  return null;

}
}

}

/// @nodoc


class _LlmModelOption implements LlmModelOption {
  const _LlmModelOption({required this.id, required this.label, required this.inputPricePerMTok, required this.outputPricePerMTok});
  

@override final  String id;
@override final  String label;
@override final  double inputPricePerMTok;
@override final  double outputPricePerMTok;

/// Create a copy of LlmModelOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LlmModelOptionCopyWith<_LlmModelOption> get copyWith => __$LlmModelOptionCopyWithImpl<_LlmModelOption>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LlmModelOption&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.inputPricePerMTok, inputPricePerMTok) || other.inputPricePerMTok == inputPricePerMTok)&&(identical(other.outputPricePerMTok, outputPricePerMTok) || other.outputPricePerMTok == outputPricePerMTok));
}


@override
int get hashCode => Object.hash(runtimeType,id,label,inputPricePerMTok,outputPricePerMTok);

@override
String toString() {
  return 'LlmModelOption(id: $id, label: $label, inputPricePerMTok: $inputPricePerMTok, outputPricePerMTok: $outputPricePerMTok)';
}


}

/// @nodoc
abstract mixin class _$LlmModelOptionCopyWith<$Res> implements $LlmModelOptionCopyWith<$Res> {
  factory _$LlmModelOptionCopyWith(_LlmModelOption value, $Res Function(_LlmModelOption) _then) = __$LlmModelOptionCopyWithImpl;
@override @useResult
$Res call({
 String id, String label, double inputPricePerMTok, double outputPricePerMTok
});




}
/// @nodoc
class __$LlmModelOptionCopyWithImpl<$Res>
    implements _$LlmModelOptionCopyWith<$Res> {
  __$LlmModelOptionCopyWithImpl(this._self, this._then);

  final _LlmModelOption _self;
  final $Res Function(_LlmModelOption) _then;

/// Create a copy of LlmModelOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,Object? inputPricePerMTok = null,Object? outputPricePerMTok = null,}) {
  return _then(_LlmModelOption(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,inputPricePerMTok: null == inputPricePerMTok ? _self.inputPricePerMTok : inputPricePerMTok // ignore: cast_nullable_to_non_nullable
as double,outputPricePerMTok: null == outputPricePerMTok ? _self.outputPricePerMTok : outputPricePerMTok // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
