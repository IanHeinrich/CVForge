// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ats_finding.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AtsFinding {

 AtsFindingCategory get category; AtsFindingSeverity get severity; String get title; String get message;/// `null` for a document-level finding (e.g. [AtsFindingCategory.
/// noTextLayer] across every page); set when a finding is anchored to
/// one page.
 int? get pageIndex;
/// Create a copy of AtsFinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsFindingCopyWith<AtsFinding> get copyWith => _$AtsFindingCopyWithImpl<AtsFinding>(this as AtsFinding, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsFinding&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode => Object.hash(runtimeType,category,severity,title,message,pageIndex);

@override
String toString() {
  return 'AtsFinding(category: $category, severity: $severity, title: $title, message: $message, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class $AtsFindingCopyWith<$Res>  {
  factory $AtsFindingCopyWith(AtsFinding value, $Res Function(AtsFinding) _then) = _$AtsFindingCopyWithImpl;
@useResult
$Res call({
 AtsFindingCategory category, AtsFindingSeverity severity, String title, String message, int? pageIndex
});




}
/// @nodoc
class _$AtsFindingCopyWithImpl<$Res>
    implements $AtsFindingCopyWith<$Res> {
  _$AtsFindingCopyWithImpl(this._self, this._then);

  final AtsFinding _self;
  final $Res Function(AtsFinding) _then;

/// Create a copy of AtsFinding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? severity = null,Object? title = null,Object? message = null,Object? pageIndex = freezed,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AtsFindingCategory,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AtsFindingSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,pageIndex: freezed == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [AtsFinding].
extension AtsFindingPatterns on AtsFinding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsFinding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsFinding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsFinding value)  $default,){
final _that = this;
switch (_that) {
case _AtsFinding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsFinding value)?  $default,){
final _that = this;
switch (_that) {
case _AtsFinding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AtsFindingCategory category,  AtsFindingSeverity severity,  String title,  String message,  int? pageIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsFinding() when $default != null:
return $default(_that.category,_that.severity,_that.title,_that.message,_that.pageIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AtsFindingCategory category,  AtsFindingSeverity severity,  String title,  String message,  int? pageIndex)  $default,) {final _that = this;
switch (_that) {
case _AtsFinding():
return $default(_that.category,_that.severity,_that.title,_that.message,_that.pageIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AtsFindingCategory category,  AtsFindingSeverity severity,  String title,  String message,  int? pageIndex)?  $default,) {final _that = this;
switch (_that) {
case _AtsFinding() when $default != null:
return $default(_that.category,_that.severity,_that.title,_that.message,_that.pageIndex);case _:
  return null;

}
}

}

/// @nodoc


class _AtsFinding implements AtsFinding {
  const _AtsFinding({required this.category, required this.severity, required this.title, required this.message, this.pageIndex});
  

@override final  AtsFindingCategory category;
@override final  AtsFindingSeverity severity;
@override final  String title;
@override final  String message;
/// `null` for a document-level finding (e.g. [AtsFindingCategory.
/// noTextLayer] across every page); set when a finding is anchored to
/// one page.
@override final  int? pageIndex;

/// Create a copy of AtsFinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsFindingCopyWith<_AtsFinding> get copyWith => __$AtsFindingCopyWithImpl<_AtsFinding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsFinding&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex));
}


@override
int get hashCode => Object.hash(runtimeType,category,severity,title,message,pageIndex);

@override
String toString() {
  return 'AtsFinding(category: $category, severity: $severity, title: $title, message: $message, pageIndex: $pageIndex)';
}


}

/// @nodoc
abstract mixin class _$AtsFindingCopyWith<$Res> implements $AtsFindingCopyWith<$Res> {
  factory _$AtsFindingCopyWith(_AtsFinding value, $Res Function(_AtsFinding) _then) = __$AtsFindingCopyWithImpl;
@override @useResult
$Res call({
 AtsFindingCategory category, AtsFindingSeverity severity, String title, String message, int? pageIndex
});




}
/// @nodoc
class __$AtsFindingCopyWithImpl<$Res>
    implements _$AtsFindingCopyWith<$Res> {
  __$AtsFindingCopyWithImpl(this._self, this._then);

  final _AtsFinding _self;
  final $Res Function(_AtsFinding) _then;

/// Create a copy of AtsFinding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? severity = null,Object? title = null,Object? message = null,Object? pageIndex = freezed,}) {
  return _then(_AtsFinding(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AtsFindingCategory,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AtsFindingSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,pageIndex: freezed == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
