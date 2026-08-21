// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'copilot_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CopilotResult {

 String? get headline; String? get summary; List<String> get experienceIds;/// experienceId -> selected bullet ids, scoped to that experience's
/// own bullets only — see [fromLlmResponse]'s per-entry validation.
 Map<String, List<String>> get bulletIds; List<String> get projectIds; Map<String, List<String>> get projectBulletIds;/// bulletId -> rewritten text, flattened across experiences and
/// projects — legal because bullet ids are globally unique (the same
/// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
/// `DraftService.applyCopilotResult` needs to hand `CvDraft` directly.
 Map<String, String> get bulletOverrides; List<String> get skillIds; List<String> get educationIds; List<String> get hobbyIds; List<String> get publicationIds; Set<CvSectionType> get hiddenSections; String get rationale; List<String> get keywordGaps;
/// Create a copy of CopilotResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CopilotResultCopyWith<CopilotResult> get copyWith => _$CopilotResultCopyWithImpl<CopilotResult>(this as CopilotResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CopilotResult&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.experienceIds, experienceIds)&&const DeepCollectionEquality().equals(other.bulletIds, bulletIds)&&const DeepCollectionEquality().equals(other.projectIds, projectIds)&&const DeepCollectionEquality().equals(other.projectBulletIds, projectBulletIds)&&const DeepCollectionEquality().equals(other.bulletOverrides, bulletOverrides)&&const DeepCollectionEquality().equals(other.skillIds, skillIds)&&const DeepCollectionEquality().equals(other.educationIds, educationIds)&&const DeepCollectionEquality().equals(other.hobbyIds, hobbyIds)&&const DeepCollectionEquality().equals(other.publicationIds, publicationIds)&&const DeepCollectionEquality().equals(other.hiddenSections, hiddenSections)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&const DeepCollectionEquality().equals(other.keywordGaps, keywordGaps));
}


@override
int get hashCode => Object.hash(runtimeType,headline,summary,const DeepCollectionEquality().hash(experienceIds),const DeepCollectionEquality().hash(bulletIds),const DeepCollectionEquality().hash(projectIds),const DeepCollectionEquality().hash(projectBulletIds),const DeepCollectionEquality().hash(bulletOverrides),const DeepCollectionEquality().hash(skillIds),const DeepCollectionEquality().hash(educationIds),const DeepCollectionEquality().hash(hobbyIds),const DeepCollectionEquality().hash(publicationIds),const DeepCollectionEquality().hash(hiddenSections),rationale,const DeepCollectionEquality().hash(keywordGaps));

@override
String toString() {
  return 'CopilotResult(headline: $headline, summary: $summary, experienceIds: $experienceIds, bulletIds: $bulletIds, projectIds: $projectIds, projectBulletIds: $projectBulletIds, bulletOverrides: $bulletOverrides, skillIds: $skillIds, educationIds: $educationIds, hobbyIds: $hobbyIds, publicationIds: $publicationIds, hiddenSections: $hiddenSections, rationale: $rationale, keywordGaps: $keywordGaps)';
}


}

/// @nodoc
abstract mixin class $CopilotResultCopyWith<$Res>  {
  factory $CopilotResultCopyWith(CopilotResult value, $Res Function(CopilotResult) _then) = _$CopilotResultCopyWithImpl;
@useResult
$Res call({
 String? headline, String? summary, List<String> experienceIds, Map<String, List<String>> bulletIds, List<String> projectIds, Map<String, List<String>> projectBulletIds, Map<String, String> bulletOverrides, List<String> skillIds, List<String> educationIds, List<String> hobbyIds, List<String> publicationIds, Set<CvSectionType> hiddenSections, String rationale, List<String> keywordGaps
});




}
/// @nodoc
class _$CopilotResultCopyWithImpl<$Res>
    implements $CopilotResultCopyWith<$Res> {
  _$CopilotResultCopyWithImpl(this._self, this._then);

  final CopilotResult _self;
  final $Res Function(CopilotResult) _then;

/// Create a copy of CopilotResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = freezed,Object? summary = freezed,Object? experienceIds = null,Object? bulletIds = null,Object? projectIds = null,Object? projectBulletIds = null,Object? bulletOverrides = null,Object? skillIds = null,Object? educationIds = null,Object? hobbyIds = null,Object? publicationIds = null,Object? hiddenSections = null,Object? rationale = null,Object? keywordGaps = null,}) {
  return _then(_self.copyWith(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,experienceIds: null == experienceIds ? _self.experienceIds : experienceIds // ignore: cast_nullable_to_non_nullable
as List<String>,bulletIds: null == bulletIds ? _self.bulletIds : bulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,projectIds: null == projectIds ? _self.projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as List<String>,projectBulletIds: null == projectBulletIds ? _self.projectBulletIds : projectBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,bulletOverrides: null == bulletOverrides ? _self.bulletOverrides : bulletOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillIds: null == skillIds ? _self.skillIds : skillIds // ignore: cast_nullable_to_non_nullable
as List<String>,educationIds: null == educationIds ? _self.educationIds : educationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hobbyIds: null == hobbyIds ? _self.hobbyIds : hobbyIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationIds: null == publicationIds ? _self.publicationIds : publicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hiddenSections: null == hiddenSections ? _self.hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,keywordGaps: null == keywordGaps ? _self.keywordGaps : keywordGaps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [CopilotResult].
extension CopilotResultPatterns on CopilotResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CopilotResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CopilotResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CopilotResult value)  $default,){
final _that = this;
switch (_that) {
case _CopilotResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CopilotResult value)?  $default,){
final _that = this;
switch (_that) {
case _CopilotResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? headline,  String? summary,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  Map<String, String> bulletOverrides,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  List<String> publicationIds,  Set<CvSectionType> hiddenSections,  String rationale,  List<String> keywordGaps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CopilotResult() when $default != null:
return $default(_that.headline,_that.summary,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.bulletOverrides,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.publicationIds,_that.hiddenSections,_that.rationale,_that.keywordGaps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? headline,  String? summary,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  Map<String, String> bulletOverrides,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  List<String> publicationIds,  Set<CvSectionType> hiddenSections,  String rationale,  List<String> keywordGaps)  $default,) {final _that = this;
switch (_that) {
case _CopilotResult():
return $default(_that.headline,_that.summary,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.bulletOverrides,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.publicationIds,_that.hiddenSections,_that.rationale,_that.keywordGaps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? headline,  String? summary,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  Map<String, String> bulletOverrides,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  List<String> publicationIds,  Set<CvSectionType> hiddenSections,  String rationale,  List<String> keywordGaps)?  $default,) {final _that = this;
switch (_that) {
case _CopilotResult() when $default != null:
return $default(_that.headline,_that.summary,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.bulletOverrides,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.publicationIds,_that.hiddenSections,_that.rationale,_that.keywordGaps);case _:
  return null;

}
}

}

/// @nodoc


class _CopilotResult implements CopilotResult {
  const _CopilotResult({this.headline, this.summary, required final  List<String> experienceIds, required final  Map<String, List<String>> bulletIds, required final  List<String> projectIds, required final  Map<String, List<String>> projectBulletIds, required final  Map<String, String> bulletOverrides, required final  List<String> skillIds, required final  List<String> educationIds, required final  List<String> hobbyIds, required final  List<String> publicationIds, required final  Set<CvSectionType> hiddenSections, required this.rationale, required final  List<String> keywordGaps}): _experienceIds = experienceIds,_bulletIds = bulletIds,_projectIds = projectIds,_projectBulletIds = projectBulletIds,_bulletOverrides = bulletOverrides,_skillIds = skillIds,_educationIds = educationIds,_hobbyIds = hobbyIds,_publicationIds = publicationIds,_hiddenSections = hiddenSections,_keywordGaps = keywordGaps;
  

@override final  String? headline;
@override final  String? summary;
 final  List<String> _experienceIds;
@override List<String> get experienceIds {
  if (_experienceIds is EqualUnmodifiableListView) return _experienceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_experienceIds);
}

/// experienceId -> selected bullet ids, scoped to that experience's
/// own bullets only — see [fromLlmResponse]'s per-entry validation.
 final  Map<String, List<String>> _bulletIds;
/// experienceId -> selected bullet ids, scoped to that experience's
/// own bullets only — see [fromLlmResponse]'s per-entry validation.
@override Map<String, List<String>> get bulletIds {
  if (_bulletIds is EqualUnmodifiableMapView) return _bulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bulletIds);
}

 final  List<String> _projectIds;
@override List<String> get projectIds {
  if (_projectIds is EqualUnmodifiableListView) return _projectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projectIds);
}

 final  Map<String, List<String>> _projectBulletIds;
@override Map<String, List<String>> get projectBulletIds {
  if (_projectBulletIds is EqualUnmodifiableMapView) return _projectBulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_projectBulletIds);
}

/// bulletId -> rewritten text, flattened across experiences and
/// projects — legal because bullet ids are globally unique (the same
/// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
/// `DraftService.applyCopilotResult` needs to hand `CvDraft` directly.
 final  Map<String, String> _bulletOverrides;
/// bulletId -> rewritten text, flattened across experiences and
/// projects — legal because bullet ids are globally unique (the same
/// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
/// `DraftService.applyCopilotResult` needs to hand `CvDraft` directly.
@override Map<String, String> get bulletOverrides {
  if (_bulletOverrides is EqualUnmodifiableMapView) return _bulletOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bulletOverrides);
}

 final  List<String> _skillIds;
@override List<String> get skillIds {
  if (_skillIds is EqualUnmodifiableListView) return _skillIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillIds);
}

 final  List<String> _educationIds;
@override List<String> get educationIds {
  if (_educationIds is EqualUnmodifiableListView) return _educationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_educationIds);
}

 final  List<String> _hobbyIds;
@override List<String> get hobbyIds {
  if (_hobbyIds is EqualUnmodifiableListView) return _hobbyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hobbyIds);
}

 final  List<String> _publicationIds;
@override List<String> get publicationIds {
  if (_publicationIds is EqualUnmodifiableListView) return _publicationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicationIds);
}

 final  Set<CvSectionType> _hiddenSections;
@override Set<CvSectionType> get hiddenSections {
  if (_hiddenSections is EqualUnmodifiableSetView) return _hiddenSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_hiddenSections);
}

@override final  String rationale;
 final  List<String> _keywordGaps;
@override List<String> get keywordGaps {
  if (_keywordGaps is EqualUnmodifiableListView) return _keywordGaps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywordGaps);
}


/// Create a copy of CopilotResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CopilotResultCopyWith<_CopilotResult> get copyWith => __$CopilotResultCopyWithImpl<_CopilotResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CopilotResult&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._experienceIds, _experienceIds)&&const DeepCollectionEquality().equals(other._bulletIds, _bulletIds)&&const DeepCollectionEquality().equals(other._projectIds, _projectIds)&&const DeepCollectionEquality().equals(other._projectBulletIds, _projectBulletIds)&&const DeepCollectionEquality().equals(other._bulletOverrides, _bulletOverrides)&&const DeepCollectionEquality().equals(other._skillIds, _skillIds)&&const DeepCollectionEquality().equals(other._educationIds, _educationIds)&&const DeepCollectionEquality().equals(other._hobbyIds, _hobbyIds)&&const DeepCollectionEquality().equals(other._publicationIds, _publicationIds)&&const DeepCollectionEquality().equals(other._hiddenSections, _hiddenSections)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&const DeepCollectionEquality().equals(other._keywordGaps, _keywordGaps));
}


@override
int get hashCode => Object.hash(runtimeType,headline,summary,const DeepCollectionEquality().hash(_experienceIds),const DeepCollectionEquality().hash(_bulletIds),const DeepCollectionEquality().hash(_projectIds),const DeepCollectionEquality().hash(_projectBulletIds),const DeepCollectionEquality().hash(_bulletOverrides),const DeepCollectionEquality().hash(_skillIds),const DeepCollectionEquality().hash(_educationIds),const DeepCollectionEquality().hash(_hobbyIds),const DeepCollectionEquality().hash(_publicationIds),const DeepCollectionEquality().hash(_hiddenSections),rationale,const DeepCollectionEquality().hash(_keywordGaps));

@override
String toString() {
  return 'CopilotResult(headline: $headline, summary: $summary, experienceIds: $experienceIds, bulletIds: $bulletIds, projectIds: $projectIds, projectBulletIds: $projectBulletIds, bulletOverrides: $bulletOverrides, skillIds: $skillIds, educationIds: $educationIds, hobbyIds: $hobbyIds, publicationIds: $publicationIds, hiddenSections: $hiddenSections, rationale: $rationale, keywordGaps: $keywordGaps)';
}


}

/// @nodoc
abstract mixin class _$CopilotResultCopyWith<$Res> implements $CopilotResultCopyWith<$Res> {
  factory _$CopilotResultCopyWith(_CopilotResult value, $Res Function(_CopilotResult) _then) = __$CopilotResultCopyWithImpl;
@override @useResult
$Res call({
 String? headline, String? summary, List<String> experienceIds, Map<String, List<String>> bulletIds, List<String> projectIds, Map<String, List<String>> projectBulletIds, Map<String, String> bulletOverrides, List<String> skillIds, List<String> educationIds, List<String> hobbyIds, List<String> publicationIds, Set<CvSectionType> hiddenSections, String rationale, List<String> keywordGaps
});




}
/// @nodoc
class __$CopilotResultCopyWithImpl<$Res>
    implements _$CopilotResultCopyWith<$Res> {
  __$CopilotResultCopyWithImpl(this._self, this._then);

  final _CopilotResult _self;
  final $Res Function(_CopilotResult) _then;

/// Create a copy of CopilotResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = freezed,Object? summary = freezed,Object? experienceIds = null,Object? bulletIds = null,Object? projectIds = null,Object? projectBulletIds = null,Object? bulletOverrides = null,Object? skillIds = null,Object? educationIds = null,Object? hobbyIds = null,Object? publicationIds = null,Object? hiddenSections = null,Object? rationale = null,Object? keywordGaps = null,}) {
  return _then(_CopilotResult(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,experienceIds: null == experienceIds ? _self._experienceIds : experienceIds // ignore: cast_nullable_to_non_nullable
as List<String>,bulletIds: null == bulletIds ? _self._bulletIds : bulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,projectIds: null == projectIds ? _self._projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as List<String>,projectBulletIds: null == projectBulletIds ? _self._projectBulletIds : projectBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,bulletOverrides: null == bulletOverrides ? _self._bulletOverrides : bulletOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillIds: null == skillIds ? _self._skillIds : skillIds // ignore: cast_nullable_to_non_nullable
as List<String>,educationIds: null == educationIds ? _self._educationIds : educationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hobbyIds: null == hobbyIds ? _self._hobbyIds : hobbyIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationIds: null == publicationIds ? _self._publicationIds : publicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hiddenSections: null == hiddenSections ? _self._hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,keywordGaps: null == keywordGaps ? _self._keywordGaps : keywordGaps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
