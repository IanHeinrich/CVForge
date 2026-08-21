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
mixin _$AtsFindingEvidence {

 int get pageIndex; int get nodeIndex;
/// Create a copy of AtsFindingEvidence
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsFindingEvidenceCopyWith<AtsFindingEvidence> get copyWith => _$AtsFindingEvidenceCopyWithImpl<AtsFindingEvidence>(this as AtsFindingEvidence, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsFindingEvidence&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.nodeIndex, nodeIndex) || other.nodeIndex == nodeIndex));
}


@override
int get hashCode => Object.hash(runtimeType,pageIndex,nodeIndex);

@override
String toString() {
  return 'AtsFindingEvidence(pageIndex: $pageIndex, nodeIndex: $nodeIndex)';
}


}

/// @nodoc
abstract mixin class $AtsFindingEvidenceCopyWith<$Res>  {
  factory $AtsFindingEvidenceCopyWith(AtsFindingEvidence value, $Res Function(AtsFindingEvidence) _then) = _$AtsFindingEvidenceCopyWithImpl;
@useResult
$Res call({
 int pageIndex, int nodeIndex
});




}
/// @nodoc
class _$AtsFindingEvidenceCopyWithImpl<$Res>
    implements $AtsFindingEvidenceCopyWith<$Res> {
  _$AtsFindingEvidenceCopyWithImpl(this._self, this._then);

  final AtsFindingEvidence _self;
  final $Res Function(AtsFindingEvidence) _then;

/// Create a copy of AtsFindingEvidence
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pageIndex = null,Object? nodeIndex = null,}) {
  return _then(_self.copyWith(
pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,nodeIndex: null == nodeIndex ? _self.nodeIndex : nodeIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AtsFindingEvidence].
extension AtsFindingEvidencePatterns on AtsFindingEvidence {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AtsFindingEvidence value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AtsFindingEvidence() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AtsFindingEvidence value)  $default,){
final _that = this;
switch (_that) {
case _AtsFindingEvidence():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AtsFindingEvidence value)?  $default,){
final _that = this;
switch (_that) {
case _AtsFindingEvidence() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int pageIndex,  int nodeIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsFindingEvidence() when $default != null:
return $default(_that.pageIndex,_that.nodeIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int pageIndex,  int nodeIndex)  $default,) {final _that = this;
switch (_that) {
case _AtsFindingEvidence():
return $default(_that.pageIndex,_that.nodeIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int pageIndex,  int nodeIndex)?  $default,) {final _that = this;
switch (_that) {
case _AtsFindingEvidence() when $default != null:
return $default(_that.pageIndex,_that.nodeIndex);case _:
  return null;

}
}

}

/// @nodoc


class _AtsFindingEvidence implements AtsFindingEvidence {
  const _AtsFindingEvidence({required this.pageIndex, required this.nodeIndex});
  

@override final  int pageIndex;
@override final  int nodeIndex;

/// Create a copy of AtsFindingEvidence
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsFindingEvidenceCopyWith<_AtsFindingEvidence> get copyWith => __$AtsFindingEvidenceCopyWithImpl<_AtsFindingEvidence>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsFindingEvidence&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&(identical(other.nodeIndex, nodeIndex) || other.nodeIndex == nodeIndex));
}


@override
int get hashCode => Object.hash(runtimeType,pageIndex,nodeIndex);

@override
String toString() {
  return 'AtsFindingEvidence(pageIndex: $pageIndex, nodeIndex: $nodeIndex)';
}


}

/// @nodoc
abstract mixin class _$AtsFindingEvidenceCopyWith<$Res> implements $AtsFindingEvidenceCopyWith<$Res> {
  factory _$AtsFindingEvidenceCopyWith(_AtsFindingEvidence value, $Res Function(_AtsFindingEvidence) _then) = __$AtsFindingEvidenceCopyWithImpl;
@override @useResult
$Res call({
 int pageIndex, int nodeIndex
});




}
/// @nodoc
class __$AtsFindingEvidenceCopyWithImpl<$Res>
    implements _$AtsFindingEvidenceCopyWith<$Res> {
  __$AtsFindingEvidenceCopyWithImpl(this._self, this._then);

  final _AtsFindingEvidence _self;
  final $Res Function(_AtsFindingEvidence) _then;

/// Create a copy of AtsFindingEvidence
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pageIndex = null,Object? nodeIndex = null,}) {
  return _then(_AtsFindingEvidence(
pageIndex: null == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int,nodeIndex: null == nodeIndex ? _self.nodeIndex : nodeIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AtsFinding {

 AtsFindingCategory get category; AtsFindingSeverity get severity; String get title; String get message;/// `null` for a document-level finding (e.g. [AtsFindingCategory.
/// noTextLayer] across every page); set when a finding is anchored to
/// one page.
 int? get pageIndex;/// The text run(s) that produced this finding, for the X-Ray overlay
/// to draw evidence boxes on. Empty for a finding with no natural node
/// evidence ([AtsFindingCategory.noTextLayer], [missingHeadings],
/// [contactInfo]) — see `docs/ats-xray-overlay-handover.md` §7.
 List<AtsFindingEvidence> get evidence; AtsEvidenceShape get evidenceShape;
/// Create a copy of AtsFinding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AtsFindingCopyWith<AtsFinding> get copyWith => _$AtsFindingCopyWithImpl<AtsFinding>(this as AtsFinding, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AtsFinding&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&const DeepCollectionEquality().equals(other.evidence, evidence)&&(identical(other.evidenceShape, evidenceShape) || other.evidenceShape == evidenceShape));
}


@override
int get hashCode => Object.hash(runtimeType,category,severity,title,message,pageIndex,const DeepCollectionEquality().hash(evidence),evidenceShape);

@override
String toString() {
  return 'AtsFinding(category: $category, severity: $severity, title: $title, message: $message, pageIndex: $pageIndex, evidence: $evidence, evidenceShape: $evidenceShape)';
}


}

/// @nodoc
abstract mixin class $AtsFindingCopyWith<$Res>  {
  factory $AtsFindingCopyWith(AtsFinding value, $Res Function(AtsFinding) _then) = _$AtsFindingCopyWithImpl;
@useResult
$Res call({
 AtsFindingCategory category, AtsFindingSeverity severity, String title, String message, int? pageIndex, List<AtsFindingEvidence> evidence, AtsEvidenceShape evidenceShape
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
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,Object? severity = null,Object? title = null,Object? message = null,Object? pageIndex = freezed,Object? evidence = null,Object? evidenceShape = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AtsFindingCategory,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AtsFindingSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,pageIndex: freezed == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int?,evidence: null == evidence ? _self.evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<AtsFindingEvidence>,evidenceShape: null == evidenceShape ? _self.evidenceShape : evidenceShape // ignore: cast_nullable_to_non_nullable
as AtsEvidenceShape,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AtsFindingCategory category,  AtsFindingSeverity severity,  String title,  String message,  int? pageIndex,  List<AtsFindingEvidence> evidence,  AtsEvidenceShape evidenceShape)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AtsFinding() when $default != null:
return $default(_that.category,_that.severity,_that.title,_that.message,_that.pageIndex,_that.evidence,_that.evidenceShape);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AtsFindingCategory category,  AtsFindingSeverity severity,  String title,  String message,  int? pageIndex,  List<AtsFindingEvidence> evidence,  AtsEvidenceShape evidenceShape)  $default,) {final _that = this;
switch (_that) {
case _AtsFinding():
return $default(_that.category,_that.severity,_that.title,_that.message,_that.pageIndex,_that.evidence,_that.evidenceShape);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AtsFindingCategory category,  AtsFindingSeverity severity,  String title,  String message,  int? pageIndex,  List<AtsFindingEvidence> evidence,  AtsEvidenceShape evidenceShape)?  $default,) {final _that = this;
switch (_that) {
case _AtsFinding() when $default != null:
return $default(_that.category,_that.severity,_that.title,_that.message,_that.pageIndex,_that.evidence,_that.evidenceShape);case _:
  return null;

}
}

}

/// @nodoc


class _AtsFinding implements AtsFinding {
  const _AtsFinding({required this.category, required this.severity, required this.title, required this.message, this.pageIndex, final  List<AtsFindingEvidence> evidence = const <AtsFindingEvidence>[], this.evidenceShape = AtsEvidenceShape.scattered}): _evidence = evidence;
  

@override final  AtsFindingCategory category;
@override final  AtsFindingSeverity severity;
@override final  String title;
@override final  String message;
/// `null` for a document-level finding (e.g. [AtsFindingCategory.
/// noTextLayer] across every page); set when a finding is anchored to
/// one page.
@override final  int? pageIndex;
/// The text run(s) that produced this finding, for the X-Ray overlay
/// to draw evidence boxes on. Empty for a finding with no natural node
/// evidence ([AtsFindingCategory.noTextLayer], [missingHeadings],
/// [contactInfo]) — see `docs/ats-xray-overlay-handover.md` §7.
 final  List<AtsFindingEvidence> _evidence;
/// The text run(s) that produced this finding, for the X-Ray overlay
/// to draw evidence boxes on. Empty for a finding with no natural node
/// evidence ([AtsFindingCategory.noTextLayer], [missingHeadings],
/// [contactInfo]) — see `docs/ats-xray-overlay-handover.md` §7.
@override@JsonKey() List<AtsFindingEvidence> get evidence {
  if (_evidence is EqualUnmodifiableListView) return _evidence;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_evidence);
}

@override@JsonKey() final  AtsEvidenceShape evidenceShape;

/// Create a copy of AtsFinding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AtsFindingCopyWith<_AtsFinding> get copyWith => __$AtsFindingCopyWithImpl<_AtsFinding>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AtsFinding&&(identical(other.category, category) || other.category == category)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.pageIndex, pageIndex) || other.pageIndex == pageIndex)&&const DeepCollectionEquality().equals(other._evidence, _evidence)&&(identical(other.evidenceShape, evidenceShape) || other.evidenceShape == evidenceShape));
}


@override
int get hashCode => Object.hash(runtimeType,category,severity,title,message,pageIndex,const DeepCollectionEquality().hash(_evidence),evidenceShape);

@override
String toString() {
  return 'AtsFinding(category: $category, severity: $severity, title: $title, message: $message, pageIndex: $pageIndex, evidence: $evidence, evidenceShape: $evidenceShape)';
}


}

/// @nodoc
abstract mixin class _$AtsFindingCopyWith<$Res> implements $AtsFindingCopyWith<$Res> {
  factory _$AtsFindingCopyWith(_AtsFinding value, $Res Function(_AtsFinding) _then) = __$AtsFindingCopyWithImpl;
@override @useResult
$Res call({
 AtsFindingCategory category, AtsFindingSeverity severity, String title, String message, int? pageIndex, List<AtsFindingEvidence> evidence, AtsEvidenceShape evidenceShape
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
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? severity = null,Object? title = null,Object? message = null,Object? pageIndex = freezed,Object? evidence = null,Object? evidenceShape = null,}) {
  return _then(_AtsFinding(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as AtsFindingCategory,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as AtsFindingSeverity,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,pageIndex: freezed == pageIndex ? _self.pageIndex : pageIndex // ignore: cast_nullable_to_non_nullable
as int?,evidence: null == evidence ? _self._evidence : evidence // ignore: cast_nullable_to_non_nullable
as List<AtsFindingEvidence>,evidenceShape: null == evidenceShape ? _self.evidenceShape : evidenceShape // ignore: cast_nullable_to_non_nullable
as AtsEvidenceShape,
  ));
}


}

// dart format on
