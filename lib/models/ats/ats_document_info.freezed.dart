// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_document_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsDocumentInfo {

 int get pageCount; String? get producer; String? get creator; String? get language;/// Whether `page.getStructTree()` returned non-null for at least one
/// page — a tagged/accessible PDF. `null` across the entire spike
/// corpus (no genuinely tagged sample was available), so no check
/// depends on this in v1; kept for a later calibration pass.
 bool get hasStructTree;
/// Create a copy of AtsDocumentInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsDocumentInfoCopyWith<AtsDocumentInfo> get copyWith => _$AtsDocumentInfoCopyWithImpl<AtsDocumentInfo>(this as AtsDocumentInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsDocumentInfo&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.producer, producer) || other.producer == producer)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.language, language) || other.language == language)&&(identical(other.hasStructTree, hasStructTree) || other.hasStructTree == hasStructTree));
}


@override
int get hashCode => Object.hash(runtimeType,pageCount,producer,creator,language,hasStructTree);

@override
String toString() {
  return 'AtsDocumentInfo(pageCount: $pageCount, producer: $producer, creator: $creator, language: $language, hasStructTree: $hasStructTree)';
}


}

/// @nodoc
abstract mixin class $AtsDocumentInfoCopyWith<$Res>  {
  factory $AtsDocumentInfoCopyWith(AtsDocumentInfo value, $Res Function(AtsDocumentInfo) _then) = _$AtsDocumentInfoCopyWithImpl;
@useResult
$Res call({
 int pageCount, String? producer, String? creator, String? language, bool hasStructTree
});




}
/// @nodoc
class _$AtsDocumentInfoCopyWithImpl<$Res>
    implements $AtsDocumentInfoCopyWith<$Res> {
  _$AtsDocumentInfoCopyWithImpl(this._self, this._then);

  final AtsDocumentInfo _self;
  final $Res Function(AtsDocumentInfo) _then;

/// Create a copy of AtsDocumentInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageCount = null,Object? producer = freezed,Object? creator = freezed,Object? language = freezed,Object? hasStructTree = null,}) {
  return _then(_self.copyWith(
pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,producer: freezed == producer ? _self.producer : producer // ignore: cast_nullable_to_non_nullable
as String?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,hasStructTree: null == hasStructTree ? _self.hasStructTree : hasStructTree // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AtsDocumentInfo].
extension AtsDocumentInfoPatterns on AtsDocumentInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsDocumentInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsDocumentInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsDocumentInfo value)  $default,){
final _that = this;
switch (_that) {
case _AtsDocumentInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsDocumentInfo value)?  $default,){
final _that = this;
switch (_that) {
case _AtsDocumentInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pageCount,  String? producer,  String? creator,  String? language,  bool hasStructTree)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsDocumentInfo() when $default != null:
return $default(_that.pageCount,_that.producer,_that.creator,_that.language,_that.hasStructTree);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pageCount,  String? producer,  String? creator,  String? language,  bool hasStructTree)  $default,) {final _that = this;
switch (_that) {
case _AtsDocumentInfo():
return $default(_that.pageCount,_that.producer,_that.creator,_that.language,_that.hasStructTree);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pageCount,  String? producer,  String? creator,  String? language,  bool hasStructTree)?  $default,) {final _that = this;
switch (_that) {
case _AtsDocumentInfo() when $default != null:
return $default(_that.pageCount,_that.producer,_that.creator,_that.language,_that.hasStructTree);case _:
  return null;

}
}

}

/// @nodoc


class _AtsDocumentInfo implements AtsDocumentInfo {
  const _AtsDocumentInfo({required this.pageCount, this.producer, this.creator, this.language, this.hasStructTree = false});
  

@override final  int pageCount;
@override final  String? producer;
@override final  String? creator;
@override final  String? language;
/// Whether `page.getStructTree()` returned non-null for at least one
/// page — a tagged/accessible PDF. `null` across the entire spike
/// corpus (no genuinely tagged sample was available), so no check
/// depends on this in v1; kept for a later calibration pass.
@override@JsonKey() final  bool hasStructTree;

/// Create a copy of AtsDocumentInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsDocumentInfoCopyWith<_AtsDocumentInfo> get copyWith => __$AtsDocumentInfoCopyWithImpl<_AtsDocumentInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsDocumentInfo&&(identical(other.pageCount, pageCount) || other.pageCount == pageCount)&&(identical(other.producer, producer) || other.producer == producer)&&(identical(other.creator, creator) || other.creator == creator)&&(identical(other.language, language) || other.language == language)&&(identical(other.hasStructTree, hasStructTree) || other.hasStructTree == hasStructTree));
}


@override
int get hashCode => Object.hash(runtimeType,pageCount,producer,creator,language,hasStructTree);

@override
String toString() {
  return 'AtsDocumentInfo(pageCount: $pageCount, producer: $producer, creator: $creator, language: $language, hasStructTree: $hasStructTree)';
}


}

/// @nodoc
abstract mixin class _$AtsDocumentInfoCopyWith<$Res> implements $AtsDocumentInfoCopyWith<$Res> {
  factory _$AtsDocumentInfoCopyWith(_AtsDocumentInfo value, $Res Function(_AtsDocumentInfo) _then) = __$AtsDocumentInfoCopyWithImpl;
@override @useResult
$Res call({
 int pageCount, String? producer, String? creator, String? language, bool hasStructTree
});




}
/// @nodoc
class __$AtsDocumentInfoCopyWithImpl<$Res>
    implements _$AtsDocumentInfoCopyWith<$Res> {
  __$AtsDocumentInfoCopyWithImpl(this._self, this._then);

  final _AtsDocumentInfo _self;
  final $Res Function(_AtsDocumentInfo) _then;

/// Create a copy of AtsDocumentInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageCount = null,Object? producer = freezed,Object? creator = freezed,Object? language = freezed,Object? hasStructTree = null,}) {
  return _then(_AtsDocumentInfo(
pageCount: null == pageCount ? _self.pageCount : pageCount // ignore: cast_nullable_to_non_nullable
as int,producer: freezed == producer ? _self.producer : producer // ignore: cast_nullable_to_non_nullable
as String?,creator: freezed == creator ? _self.creator : creator // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,hasStructTree: null == hasStructTree ? _self.hasStructTree : hasStructTree // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
