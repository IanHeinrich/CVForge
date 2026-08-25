// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_translation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CvTranslationResult {

 String? get headline; String? get summary; String? get referencesNote; Map<String, String> get roles; Map<String, String> get projectTitles; Map<String, String> get skillCategoryNames; Map<String, String> get skillLabels; Map<String, String> get educationQualifications; Map<String, String> get educationGrades; Map<String, String> get educationDetails; Map<String, String> get hobbies; Map<String, String> get bullets;/// How many strings the request asked about, so a caller can report
/// "translated 3 of 61" rather than an unqualified "translated 3".
 int get requestedCount;/// How many came back saying something different from what was sent.
///
/// Not the size of the maps, which is now every field the request
/// asked about: the schema requires an answer for each one, and a term
/// that should keep its name is answered by returning it unchanged.
/// Counting those as translations would report "61 of 61" on a pass
/// that changed forty things.
 int get translatedCount;
/// Create a copy of CvTranslationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvTranslationResultCopyWith<CvTranslationResult> get copyWith => _$CvTranslationResultCopyWithImpl<CvTranslationResult>(this as CvTranslationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvTranslationResult&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.referencesNote, referencesNote) || other.referencesNote == referencesNote)&&const DeepCollectionEquality().equals(other.roles, roles)&&const DeepCollectionEquality().equals(other.projectTitles, projectTitles)&&const DeepCollectionEquality().equals(other.skillCategoryNames, skillCategoryNames)&&const DeepCollectionEquality().equals(other.skillLabels, skillLabels)&&const DeepCollectionEquality().equals(other.educationQualifications, educationQualifications)&&const DeepCollectionEquality().equals(other.educationGrades, educationGrades)&&const DeepCollectionEquality().equals(other.educationDetails, educationDetails)&&const DeepCollectionEquality().equals(other.hobbies, hobbies)&&const DeepCollectionEquality().equals(other.bullets, bullets)&&(identical(other.requestedCount, requestedCount) || other.requestedCount == requestedCount)&&(identical(other.translatedCount, translatedCount) || other.translatedCount == translatedCount));
}


@override
int get hashCode => Object.hash(runtimeType,headline,summary,referencesNote,const DeepCollectionEquality().hash(roles),const DeepCollectionEquality().hash(projectTitles),const DeepCollectionEquality().hash(skillCategoryNames),const DeepCollectionEquality().hash(skillLabels),const DeepCollectionEquality().hash(educationQualifications),const DeepCollectionEquality().hash(educationGrades),const DeepCollectionEquality().hash(educationDetails),const DeepCollectionEquality().hash(hobbies),const DeepCollectionEquality().hash(bullets),requestedCount,translatedCount);

@override
String toString() {
  return 'CvTranslationResult(headline: $headline, summary: $summary, referencesNote: $referencesNote, roles: $roles, projectTitles: $projectTitles, skillCategoryNames: $skillCategoryNames, skillLabels: $skillLabels, educationQualifications: $educationQualifications, educationGrades: $educationGrades, educationDetails: $educationDetails, hobbies: $hobbies, bullets: $bullets, requestedCount: $requestedCount, translatedCount: $translatedCount)';
}


}

/// @nodoc
abstract mixin class $CvTranslationResultCopyWith<$Res>  {
  factory $CvTranslationResultCopyWith(CvTranslationResult value, $Res Function(CvTranslationResult) _then) = _$CvTranslationResultCopyWithImpl;
@useResult
$Res call({
 String? headline, String? summary, String? referencesNote, Map<String, String> roles, Map<String, String> projectTitles, Map<String, String> skillCategoryNames, Map<String, String> skillLabels, Map<String, String> educationQualifications, Map<String, String> educationGrades, Map<String, String> educationDetails, Map<String, String> hobbies, Map<String, String> bullets, int requestedCount, int translatedCount
});




}
/// @nodoc
class _$CvTranslationResultCopyWithImpl<$Res>
    implements $CvTranslationResultCopyWith<$Res> {
  _$CvTranslationResultCopyWithImpl(this._self, this._then);

  final CvTranslationResult _self;
  final $Res Function(CvTranslationResult) _then;

/// Create a copy of CvTranslationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = freezed,Object? summary = freezed,Object? referencesNote = freezed,Object? roles = null,Object? projectTitles = null,Object? skillCategoryNames = null,Object? skillLabels = null,Object? educationQualifications = null,Object? educationGrades = null,Object? educationDetails = null,Object? hobbies = null,Object? bullets = null,Object? requestedCount = null,Object? translatedCount = null,}) {
  return _then(_self.copyWith(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,referencesNote: freezed == referencesNote ? _self.referencesNote : referencesNote // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,projectTitles: null == projectTitles ? _self.projectTitles : projectTitles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillCategoryNames: null == skillCategoryNames ? _self.skillCategoryNames : skillCategoryNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillLabels: null == skillLabels ? _self.skillLabels : skillLabels // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationQualifications: null == educationQualifications ? _self.educationQualifications : educationQualifications // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationGrades: null == educationGrades ? _self.educationGrades : educationGrades // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationDetails: null == educationDetails ? _self.educationDetails : educationDetails // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hobbies: null == hobbies ? _self.hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as Map<String, String>,bullets: null == bullets ? _self.bullets : bullets // ignore: cast_nullable_to_non_nullable
as Map<String, String>,requestedCount: null == requestedCount ? _self.requestedCount : requestedCount // ignore: cast_nullable_to_non_nullable
as int,translatedCount: null == translatedCount ? _self.translatedCount : translatedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CvTranslationResult].
extension CvTranslationResultPatterns on CvTranslationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvTranslationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvTranslationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvTranslationResult value)  $default,){
final _that = this;
switch (_that) {
case _CvTranslationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvTranslationResult value)?  $default,){
final _that = this;
switch (_that) {
case _CvTranslationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? headline,  String? summary,  String? referencesNote,  Map<String, String> roles,  Map<String, String> projectTitles,  Map<String, String> skillCategoryNames,  Map<String, String> skillLabels,  Map<String, String> educationQualifications,  Map<String, String> educationGrades,  Map<String, String> educationDetails,  Map<String, String> hobbies,  Map<String, String> bullets,  int requestedCount,  int translatedCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvTranslationResult() when $default != null:
return $default(_that.headline,_that.summary,_that.referencesNote,_that.roles,_that.projectTitles,_that.skillCategoryNames,_that.skillLabels,_that.educationQualifications,_that.educationGrades,_that.educationDetails,_that.hobbies,_that.bullets,_that.requestedCount,_that.translatedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? headline,  String? summary,  String? referencesNote,  Map<String, String> roles,  Map<String, String> projectTitles,  Map<String, String> skillCategoryNames,  Map<String, String> skillLabels,  Map<String, String> educationQualifications,  Map<String, String> educationGrades,  Map<String, String> educationDetails,  Map<String, String> hobbies,  Map<String, String> bullets,  int requestedCount,  int translatedCount)  $default,) {final _that = this;
switch (_that) {
case _CvTranslationResult():
return $default(_that.headline,_that.summary,_that.referencesNote,_that.roles,_that.projectTitles,_that.skillCategoryNames,_that.skillLabels,_that.educationQualifications,_that.educationGrades,_that.educationDetails,_that.hobbies,_that.bullets,_that.requestedCount,_that.translatedCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? headline,  String? summary,  String? referencesNote,  Map<String, String> roles,  Map<String, String> projectTitles,  Map<String, String> skillCategoryNames,  Map<String, String> skillLabels,  Map<String, String> educationQualifications,  Map<String, String> educationGrades,  Map<String, String> educationDetails,  Map<String, String> hobbies,  Map<String, String> bullets,  int requestedCount,  int translatedCount)?  $default,) {final _that = this;
switch (_that) {
case _CvTranslationResult() when $default != null:
return $default(_that.headline,_that.summary,_that.referencesNote,_that.roles,_that.projectTitles,_that.skillCategoryNames,_that.skillLabels,_that.educationQualifications,_that.educationGrades,_that.educationDetails,_that.hobbies,_that.bullets,_that.requestedCount,_that.translatedCount);case _:
  return null;

}
}

}

/// @nodoc


class _CvTranslationResult extends CvTranslationResult {
  const _CvTranslationResult({this.headline, this.summary, this.referencesNote, required final  Map<String, String> roles, required final  Map<String, String> projectTitles, required final  Map<String, String> skillCategoryNames, required final  Map<String, String> skillLabels, required final  Map<String, String> educationQualifications, required final  Map<String, String> educationGrades, required final  Map<String, String> educationDetails, required final  Map<String, String> hobbies, required final  Map<String, String> bullets, this.requestedCount = 0, this.translatedCount = 0}): _roles = roles,_projectTitles = projectTitles,_skillCategoryNames = skillCategoryNames,_skillLabels = skillLabels,_educationQualifications = educationQualifications,_educationGrades = educationGrades,_educationDetails = educationDetails,_hobbies = hobbies,_bullets = bullets,super._();
  

@override final  String? headline;
@override final  String? summary;
@override final  String? referencesNote;
 final  Map<String, String> _roles;
@override Map<String, String> get roles {
  if (_roles is EqualUnmodifiableMapView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_roles);
}

 final  Map<String, String> _projectTitles;
@override Map<String, String> get projectTitles {
  if (_projectTitles is EqualUnmodifiableMapView) return _projectTitles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_projectTitles);
}

 final  Map<String, String> _skillCategoryNames;
@override Map<String, String> get skillCategoryNames {
  if (_skillCategoryNames is EqualUnmodifiableMapView) return _skillCategoryNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_skillCategoryNames);
}

 final  Map<String, String> _skillLabels;
@override Map<String, String> get skillLabels {
  if (_skillLabels is EqualUnmodifiableMapView) return _skillLabels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_skillLabels);
}

 final  Map<String, String> _educationQualifications;
@override Map<String, String> get educationQualifications {
  if (_educationQualifications is EqualUnmodifiableMapView) return _educationQualifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_educationQualifications);
}

 final  Map<String, String> _educationGrades;
@override Map<String, String> get educationGrades {
  if (_educationGrades is EqualUnmodifiableMapView) return _educationGrades;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_educationGrades);
}

 final  Map<String, String> _educationDetails;
@override Map<String, String> get educationDetails {
  if (_educationDetails is EqualUnmodifiableMapView) return _educationDetails;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_educationDetails);
}

 final  Map<String, String> _hobbies;
@override Map<String, String> get hobbies {
  if (_hobbies is EqualUnmodifiableMapView) return _hobbies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hobbies);
}

 final  Map<String, String> _bullets;
@override Map<String, String> get bullets {
  if (_bullets is EqualUnmodifiableMapView) return _bullets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bullets);
}

/// How many strings the request asked about, so a caller can report
/// "translated 3 of 61" rather than an unqualified "translated 3".
@override@JsonKey() final  int requestedCount;
/// How many came back saying something different from what was sent.
///
/// Not the size of the maps, which is now every field the request
/// asked about: the schema requires an answer for each one, and a term
/// that should keep its name is answered by returning it unchanged.
/// Counting those as translations would report "61 of 61" on a pass
/// that changed forty things.
@override@JsonKey() final  int translatedCount;

/// Create a copy of CvTranslationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvTranslationResultCopyWith<_CvTranslationResult> get copyWith => __$CvTranslationResultCopyWithImpl<_CvTranslationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvTranslationResult&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.referencesNote, referencesNote) || other.referencesNote == referencesNote)&&const DeepCollectionEquality().equals(other._roles, _roles)&&const DeepCollectionEquality().equals(other._projectTitles, _projectTitles)&&const DeepCollectionEquality().equals(other._skillCategoryNames, _skillCategoryNames)&&const DeepCollectionEquality().equals(other._skillLabels, _skillLabels)&&const DeepCollectionEquality().equals(other._educationQualifications, _educationQualifications)&&const DeepCollectionEquality().equals(other._educationGrades, _educationGrades)&&const DeepCollectionEquality().equals(other._educationDetails, _educationDetails)&&const DeepCollectionEquality().equals(other._hobbies, _hobbies)&&const DeepCollectionEquality().equals(other._bullets, _bullets)&&(identical(other.requestedCount, requestedCount) || other.requestedCount == requestedCount)&&(identical(other.translatedCount, translatedCount) || other.translatedCount == translatedCount));
}


@override
int get hashCode => Object.hash(runtimeType,headline,summary,referencesNote,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(_projectTitles),const DeepCollectionEquality().hash(_skillCategoryNames),const DeepCollectionEquality().hash(_skillLabels),const DeepCollectionEquality().hash(_educationQualifications),const DeepCollectionEquality().hash(_educationGrades),const DeepCollectionEquality().hash(_educationDetails),const DeepCollectionEquality().hash(_hobbies),const DeepCollectionEquality().hash(_bullets),requestedCount,translatedCount);

@override
String toString() {
  return 'CvTranslationResult(headline: $headline, summary: $summary, referencesNote: $referencesNote, roles: $roles, projectTitles: $projectTitles, skillCategoryNames: $skillCategoryNames, skillLabels: $skillLabels, educationQualifications: $educationQualifications, educationGrades: $educationGrades, educationDetails: $educationDetails, hobbies: $hobbies, bullets: $bullets, requestedCount: $requestedCount, translatedCount: $translatedCount)';
}


}

/// @nodoc
abstract mixin class _$CvTranslationResultCopyWith<$Res> implements $CvTranslationResultCopyWith<$Res> {
  factory _$CvTranslationResultCopyWith(_CvTranslationResult value, $Res Function(_CvTranslationResult) _then) = __$CvTranslationResultCopyWithImpl;
@override @useResult
$Res call({
 String? headline, String? summary, String? referencesNote, Map<String, String> roles, Map<String, String> projectTitles, Map<String, String> skillCategoryNames, Map<String, String> skillLabels, Map<String, String> educationQualifications, Map<String, String> educationGrades, Map<String, String> educationDetails, Map<String, String> hobbies, Map<String, String> bullets, int requestedCount, int translatedCount
});




}
/// @nodoc
class __$CvTranslationResultCopyWithImpl<$Res>
    implements _$CvTranslationResultCopyWith<$Res> {
  __$CvTranslationResultCopyWithImpl(this._self, this._then);

  final _CvTranslationResult _self;
  final $Res Function(_CvTranslationResult) _then;

/// Create a copy of CvTranslationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = freezed,Object? summary = freezed,Object? referencesNote = freezed,Object? roles = null,Object? projectTitles = null,Object? skillCategoryNames = null,Object? skillLabels = null,Object? educationQualifications = null,Object? educationGrades = null,Object? educationDetails = null,Object? hobbies = null,Object? bullets = null,Object? requestedCount = null,Object? translatedCount = null,}) {
  return _then(_CvTranslationResult(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,referencesNote: freezed == referencesNote ? _self.referencesNote : referencesNote // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,projectTitles: null == projectTitles ? _self._projectTitles : projectTitles // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillCategoryNames: null == skillCategoryNames ? _self._skillCategoryNames : skillCategoryNames // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillLabels: null == skillLabels ? _self._skillLabels : skillLabels // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationQualifications: null == educationQualifications ? _self._educationQualifications : educationQualifications // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationGrades: null == educationGrades ? _self._educationGrades : educationGrades // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationDetails: null == educationDetails ? _self._educationDetails : educationDetails // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hobbies: null == hobbies ? _self._hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as Map<String, String>,bullets: null == bullets ? _self._bullets : bullets // ignore: cast_nullable_to_non_nullable
as Map<String, String>,requestedCount: null == requestedCount ? _self.requestedCount : requestedCount // ignore: cast_nullable_to_non_nullable
as int,translatedCount: null == translatedCount ? _self.translatedCount : translatedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
