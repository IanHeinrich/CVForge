// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_analysis_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsAnalysisResult {

 AtsDocumentInfo get info; int get totalNodeCount; List<AtsFinding> get findings;
/// Create a copy of AtsAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsAnalysisResultCopyWith<AtsAnalysisResult> get copyWith => _$AtsAnalysisResultCopyWithImpl<AtsAnalysisResult>(this as AtsAnalysisResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsAnalysisResult&&(identical(other.info, info) || other.info == info)&&(identical(other.totalNodeCount, totalNodeCount) || other.totalNodeCount == totalNodeCount)&&const DeepCollectionEquality().equals(other.findings, findings));
}


@override
int get hashCode => Object.hash(runtimeType,info,totalNodeCount,const DeepCollectionEquality().hash(findings));

@override
String toString() {
  return 'AtsAnalysisResult(info: $info, totalNodeCount: $totalNodeCount, findings: $findings)';
}


}

/// @nodoc
abstract mixin class $AtsAnalysisResultCopyWith<$Res>  {
  factory $AtsAnalysisResultCopyWith(AtsAnalysisResult value, $Res Function(AtsAnalysisResult) _then) = _$AtsAnalysisResultCopyWithImpl;
@useResult
$Res call({
 AtsDocumentInfo info, int totalNodeCount, List<AtsFinding> findings
});


$AtsDocumentInfoCopyWith<$Res> get info;

}
/// @nodoc
class _$AtsAnalysisResultCopyWithImpl<$Res>
    implements $AtsAnalysisResultCopyWith<$Res> {
  _$AtsAnalysisResultCopyWithImpl(this._self, this._then);

  final AtsAnalysisResult _self;
  final $Res Function(AtsAnalysisResult) _then;

/// Create a copy of AtsAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? info = null,Object? totalNodeCount = null,Object? findings = null,}) {
  return _then(_self.copyWith(
info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AtsDocumentInfo,totalNodeCount: null == totalNodeCount ? _self.totalNodeCount : totalNodeCount // ignore: cast_nullable_to_non_nullable
as int,findings: null == findings ? _self.findings : findings // ignore: cast_nullable_to_non_nullable
as List<AtsFinding>,
  ));
}
/// Create a copy of AtsAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AtsDocumentInfoCopyWith<$Res> get info {
  
  return $AtsDocumentInfoCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}


/// Adds pattern-matching-related methods to [AtsAnalysisResult].
extension AtsAnalysisResultPatterns on AtsAnalysisResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsAnalysisResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsAnalysisResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsAnalysisResult value)  $default,){
final _that = this;
switch (_that) {
case _AtsAnalysisResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsAnalysisResult value)?  $default,){
final _that = this;
switch (_that) {
case _AtsAnalysisResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AtsDocumentInfo info,  int totalNodeCount,  List<AtsFinding> findings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsAnalysisResult() when $default != null:
return $default(_that.info,_that.totalNodeCount,_that.findings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AtsDocumentInfo info,  int totalNodeCount,  List<AtsFinding> findings)  $default,) {final _that = this;
switch (_that) {
case _AtsAnalysisResult():
return $default(_that.info,_that.totalNodeCount,_that.findings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AtsDocumentInfo info,  int totalNodeCount,  List<AtsFinding> findings)?  $default,) {final _that = this;
switch (_that) {
case _AtsAnalysisResult() when $default != null:
return $default(_that.info,_that.totalNodeCount,_that.findings);case _:
  return null;

}
}

}

/// @nodoc


class _AtsAnalysisResult implements AtsAnalysisResult {
  const _AtsAnalysisResult({required this.info, required this.totalNodeCount, final  List<AtsFinding> findings = const <AtsFinding>[]}): _findings = findings;
  

@override final  AtsDocumentInfo info;
@override final  int totalNodeCount;
 final  List<AtsFinding> _findings;
@override@JsonKey() List<AtsFinding> get findings {
  if (_findings is EqualUnmodifiableListView) return _findings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_findings);
}


/// Create a copy of AtsAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsAnalysisResultCopyWith<_AtsAnalysisResult> get copyWith => __$AtsAnalysisResultCopyWithImpl<_AtsAnalysisResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsAnalysisResult&&(identical(other.info, info) || other.info == info)&&(identical(other.totalNodeCount, totalNodeCount) || other.totalNodeCount == totalNodeCount)&&const DeepCollectionEquality().equals(other._findings, _findings));
}


@override
int get hashCode => Object.hash(runtimeType,info,totalNodeCount,const DeepCollectionEquality().hash(_findings));

@override
String toString() {
  return 'AtsAnalysisResult(info: $info, totalNodeCount: $totalNodeCount, findings: $findings)';
}


}

/// @nodoc
abstract mixin class _$AtsAnalysisResultCopyWith<$Res> implements $AtsAnalysisResultCopyWith<$Res> {
  factory _$AtsAnalysisResultCopyWith(_AtsAnalysisResult value, $Res Function(_AtsAnalysisResult) _then) = __$AtsAnalysisResultCopyWithImpl;
@override @useResult
$Res call({
 AtsDocumentInfo info, int totalNodeCount, List<AtsFinding> findings
});


@override $AtsDocumentInfoCopyWith<$Res> get info;

}
/// @nodoc
class __$AtsAnalysisResultCopyWithImpl<$Res>
    implements _$AtsAnalysisResultCopyWith<$Res> {
  __$AtsAnalysisResultCopyWithImpl(this._self, this._then);

  final _AtsAnalysisResult _self;
  final $Res Function(_AtsAnalysisResult) _then;

/// Create a copy of AtsAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? info = null,Object? totalNodeCount = null,Object? findings = null,}) {
  return _then(_AtsAnalysisResult(
info: null == info ? _self.info : info // ignore: cast_nullable_to_non_nullable
as AtsDocumentInfo,totalNodeCount: null == totalNodeCount ? _self.totalNodeCount : totalNodeCount // ignore: cast_nullable_to_non_nullable
as int,findings: null == findings ? _self._findings : findings // ignore: cast_nullable_to_non_nullable
as List<AtsFinding>,
  ));
}

/// Create a copy of AtsAnalysisResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AtsDocumentInfoCopyWith<$Res> get info {
  
  return $AtsDocumentInfoCopyWith<$Res>(_self.info, (value) {
    return _then(_self.copyWith(info: value));
  });
}
}

// dart format on
