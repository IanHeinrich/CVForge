// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_assistant_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AiAssistantResult {

 String? get headline; String? get summary; List<String> get experienceIds;/// experienceId -> selected bullet ids, scoped to that experience's
/// own bullets only — see [fromLlmResponse]'s per-entry validation.
 Map<String, List<String>> get bulletIds; List<String> get projectIds; Map<String, List<String>> get projectBulletIds; List<String> get publicationIds; Map<String, List<String>> get publicationBulletIds;/// bulletId -> rewritten text, flattened across experiences and
/// projects — legal because bullet ids are globally unique (the same
/// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
/// `DraftService.applyAiAssistantResult` needs to hand `CvDraft` directly.
 Map<String, String> get bulletOverrides; List<String> get skillIds; List<String> get educationIds; List<String> get hobbyIds; Set<CvSectionType> get hiddenSections; String get rationale; List<String> get keywordGaps;
/// Create a copy of AiAssistantResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiAssistantResultCopyWith<AiAssistantResult> get copyWith => _$AiAssistantResultCopyWithImpl<AiAssistantResult>(this as AiAssistantResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiAssistantResult&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.experienceIds, experienceIds)&&const DeepCollectionEquality().equals(other.bulletIds, bulletIds)&&const DeepCollectionEquality().equals(other.projectIds, projectIds)&&const DeepCollectionEquality().equals(other.projectBulletIds, projectBulletIds)&&const DeepCollectionEquality().equals(other.publicationIds, publicationIds)&&const DeepCollectionEquality().equals(other.publicationBulletIds, publicationBulletIds)&&const DeepCollectionEquality().equals(other.bulletOverrides, bulletOverrides)&&const DeepCollectionEquality().equals(other.skillIds, skillIds)&&const DeepCollectionEquality().equals(other.educationIds, educationIds)&&const DeepCollectionEquality().equals(other.hobbyIds, hobbyIds)&&const DeepCollectionEquality().equals(other.hiddenSections, hiddenSections)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&const DeepCollectionEquality().equals(other.keywordGaps, keywordGaps));
}


@override
int get hashCode => Object.hash(runtimeType,headline,summary,const DeepCollectionEquality().hash(experienceIds),const DeepCollectionEquality().hash(bulletIds),const DeepCollectionEquality().hash(projectIds),const DeepCollectionEquality().hash(projectBulletIds),const DeepCollectionEquality().hash(publicationIds),const DeepCollectionEquality().hash(publicationBulletIds),const DeepCollectionEquality().hash(bulletOverrides),const DeepCollectionEquality().hash(skillIds),const DeepCollectionEquality().hash(educationIds),const DeepCollectionEquality().hash(hobbyIds),const DeepCollectionEquality().hash(hiddenSections),rationale,const DeepCollectionEquality().hash(keywordGaps));

@override
String toString() {
  return 'AiAssistantResult(headline: $headline, summary: $summary, experienceIds: $experienceIds, bulletIds: $bulletIds, projectIds: $projectIds, projectBulletIds: $projectBulletIds, publicationIds: $publicationIds, publicationBulletIds: $publicationBulletIds, bulletOverrides: $bulletOverrides, skillIds: $skillIds, educationIds: $educationIds, hobbyIds: $hobbyIds, hiddenSections: $hiddenSections, rationale: $rationale, keywordGaps: $keywordGaps)';
}


}

/// @nodoc
abstract mixin class $AiAssistantResultCopyWith<$Res>  {
  factory $AiAssistantResultCopyWith(AiAssistantResult value, $Res Function(AiAssistantResult) _then) = _$AiAssistantResultCopyWithImpl;
@useResult
$Res call({
 String? headline, String? summary, List<String> experienceIds, Map<String, List<String>> bulletIds, List<String> projectIds, Map<String, List<String>> projectBulletIds, List<String> publicationIds, Map<String, List<String>> publicationBulletIds, Map<String, String> bulletOverrides, List<String> skillIds, List<String> educationIds, List<String> hobbyIds, Set<CvSectionType> hiddenSections, String rationale, List<String> keywordGaps
});




}
/// @nodoc
class _$AiAssistantResultCopyWithImpl<$Res>
    implements $AiAssistantResultCopyWith<$Res> {
  _$AiAssistantResultCopyWithImpl(this._self, this._then);

  final AiAssistantResult _self;
  final $Res Function(AiAssistantResult) _then;

/// Create a copy of AiAssistantResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = freezed,Object? summary = freezed,Object? experienceIds = null,Object? bulletIds = null,Object? projectIds = null,Object? projectBulletIds = null,Object? publicationIds = null,Object? publicationBulletIds = null,Object? bulletOverrides = null,Object? skillIds = null,Object? educationIds = null,Object? hobbyIds = null,Object? hiddenSections = null,Object? rationale = null,Object? keywordGaps = null,}) {
  return _then(_self.copyWith(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,experienceIds: null == experienceIds ? _self.experienceIds : experienceIds // ignore: cast_nullable_to_non_nullable
as List<String>,bulletIds: null == bulletIds ? _self.bulletIds : bulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,projectIds: null == projectIds ? _self.projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as List<String>,projectBulletIds: null == projectBulletIds ? _self.projectBulletIds : projectBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,publicationIds: null == publicationIds ? _self.publicationIds : publicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationBulletIds: null == publicationBulletIds ? _self.publicationBulletIds : publicationBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,bulletOverrides: null == bulletOverrides ? _self.bulletOverrides : bulletOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillIds: null == skillIds ? _self.skillIds : skillIds // ignore: cast_nullable_to_non_nullable
as List<String>,educationIds: null == educationIds ? _self.educationIds : educationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hobbyIds: null == hobbyIds ? _self.hobbyIds : hobbyIds // ignore: cast_nullable_to_non_nullable
as List<String>,hiddenSections: null == hiddenSections ? _self.hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,keywordGaps: null == keywordGaps ? _self.keywordGaps : keywordGaps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AiAssistantResult].
extension AiAssistantResultPatterns on AiAssistantResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AiAssistantResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AiAssistantResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AiAssistantResult value)  $default,){
final _that = this;
switch (_that) {
case _AiAssistantResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AiAssistantResult value)?  $default,){
final _that = this;
switch (_that) {
case _AiAssistantResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? headline,  String? summary,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  List<String> publicationIds,  Map<String, List<String>> publicationBulletIds,  Map<String, String> bulletOverrides,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  Set<CvSectionType> hiddenSections,  String rationale,  List<String> keywordGaps)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AiAssistantResult() when $default != null:
return $default(_that.headline,_that.summary,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.publicationIds,_that.publicationBulletIds,_that.bulletOverrides,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.hiddenSections,_that.rationale,_that.keywordGaps);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? headline,  String? summary,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  List<String> publicationIds,  Map<String, List<String>> publicationBulletIds,  Map<String, String> bulletOverrides,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  Set<CvSectionType> hiddenSections,  String rationale,  List<String> keywordGaps)  $default,) {final _that = this;
switch (_that) {
case _AiAssistantResult():
return $default(_that.headline,_that.summary,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.publicationIds,_that.publicationBulletIds,_that.bulletOverrides,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.hiddenSections,_that.rationale,_that.keywordGaps);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? headline,  String? summary,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  List<String> publicationIds,  Map<String, List<String>> publicationBulletIds,  Map<String, String> bulletOverrides,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  Set<CvSectionType> hiddenSections,  String rationale,  List<String> keywordGaps)?  $default,) {final _that = this;
switch (_that) {
case _AiAssistantResult() when $default != null:
return $default(_that.headline,_that.summary,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.publicationIds,_that.publicationBulletIds,_that.bulletOverrides,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.hiddenSections,_that.rationale,_that.keywordGaps);case _:
  return null;

}
}

}

/// @nodoc


class _AiAssistantResult implements AiAssistantResult {
  const _AiAssistantResult({this.headline, this.summary, required final  List<String> experienceIds, required final  Map<String, List<String>> bulletIds, required final  List<String> projectIds, required final  Map<String, List<String>> projectBulletIds, required final  List<String> publicationIds, required final  Map<String, List<String>> publicationBulletIds, required final  Map<String, String> bulletOverrides, required final  List<String> skillIds, required final  List<String> educationIds, required final  List<String> hobbyIds, required final  Set<CvSectionType> hiddenSections, required this.rationale, required final  List<String> keywordGaps}): _experienceIds = experienceIds,_bulletIds = bulletIds,_projectIds = projectIds,_projectBulletIds = projectBulletIds,_publicationIds = publicationIds,_publicationBulletIds = publicationBulletIds,_bulletOverrides = bulletOverrides,_skillIds = skillIds,_educationIds = educationIds,_hobbyIds = hobbyIds,_hiddenSections = hiddenSections,_keywordGaps = keywordGaps;
  

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

 final  List<String> _publicationIds;
@override List<String> get publicationIds {
  if (_publicationIds is EqualUnmodifiableListView) return _publicationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicationIds);
}

 final  Map<String, List<String>> _publicationBulletIds;
@override Map<String, List<String>> get publicationBulletIds {
  if (_publicationBulletIds is EqualUnmodifiableMapView) return _publicationBulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_publicationBulletIds);
}

/// bulletId -> rewritten text, flattened across experiences and
/// projects — legal because bullet ids are globally unique (the same
/// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
/// `DraftService.applyAiAssistantResult` needs to hand `CvDraft` directly.
 final  Map<String, String> _bulletOverrides;
/// bulletId -> rewritten text, flattened across experiences and
/// projects — legal because bullet ids are globally unique (the same
/// reasoning as `CvDraft.bulletOverrides`), and it's exactly the shape
/// `DraftService.applyAiAssistantResult` needs to hand `CvDraft` directly.
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


/// Create a copy of AiAssistantResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AiAssistantResultCopyWith<_AiAssistantResult> get copyWith => __$AiAssistantResultCopyWithImpl<_AiAssistantResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AiAssistantResult&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._experienceIds, _experienceIds)&&const DeepCollectionEquality().equals(other._bulletIds, _bulletIds)&&const DeepCollectionEquality().equals(other._projectIds, _projectIds)&&const DeepCollectionEquality().equals(other._projectBulletIds, _projectBulletIds)&&const DeepCollectionEquality().equals(other._publicationIds, _publicationIds)&&const DeepCollectionEquality().equals(other._publicationBulletIds, _publicationBulletIds)&&const DeepCollectionEquality().equals(other._bulletOverrides, _bulletOverrides)&&const DeepCollectionEquality().equals(other._skillIds, _skillIds)&&const DeepCollectionEquality().equals(other._educationIds, _educationIds)&&const DeepCollectionEquality().equals(other._hobbyIds, _hobbyIds)&&const DeepCollectionEquality().equals(other._hiddenSections, _hiddenSections)&&(identical(other.rationale, rationale) || other.rationale == rationale)&&const DeepCollectionEquality().equals(other._keywordGaps, _keywordGaps));
}


@override
int get hashCode => Object.hash(runtimeType,headline,summary,const DeepCollectionEquality().hash(_experienceIds),const DeepCollectionEquality().hash(_bulletIds),const DeepCollectionEquality().hash(_projectIds),const DeepCollectionEquality().hash(_projectBulletIds),const DeepCollectionEquality().hash(_publicationIds),const DeepCollectionEquality().hash(_publicationBulletIds),const DeepCollectionEquality().hash(_bulletOverrides),const DeepCollectionEquality().hash(_skillIds),const DeepCollectionEquality().hash(_educationIds),const DeepCollectionEquality().hash(_hobbyIds),const DeepCollectionEquality().hash(_hiddenSections),rationale,const DeepCollectionEquality().hash(_keywordGaps));

@override
String toString() {
  return 'AiAssistantResult(headline: $headline, summary: $summary, experienceIds: $experienceIds, bulletIds: $bulletIds, projectIds: $projectIds, projectBulletIds: $projectBulletIds, publicationIds: $publicationIds, publicationBulletIds: $publicationBulletIds, bulletOverrides: $bulletOverrides, skillIds: $skillIds, educationIds: $educationIds, hobbyIds: $hobbyIds, hiddenSections: $hiddenSections, rationale: $rationale, keywordGaps: $keywordGaps)';
}


}

/// @nodoc
abstract mixin class _$AiAssistantResultCopyWith<$Res> implements $AiAssistantResultCopyWith<$Res> {
  factory _$AiAssistantResultCopyWith(_AiAssistantResult value, $Res Function(_AiAssistantResult) _then) = __$AiAssistantResultCopyWithImpl;
@override @useResult
$Res call({
 String? headline, String? summary, List<String> experienceIds, Map<String, List<String>> bulletIds, List<String> projectIds, Map<String, List<String>> projectBulletIds, List<String> publicationIds, Map<String, List<String>> publicationBulletIds, Map<String, String> bulletOverrides, List<String> skillIds, List<String> educationIds, List<String> hobbyIds, Set<CvSectionType> hiddenSections, String rationale, List<String> keywordGaps
});




}
/// @nodoc
class __$AiAssistantResultCopyWithImpl<$Res>
    implements _$AiAssistantResultCopyWith<$Res> {
  __$AiAssistantResultCopyWithImpl(this._self, this._then);

  final _AiAssistantResult _self;
  final $Res Function(_AiAssistantResult) _then;

/// Create a copy of AiAssistantResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = freezed,Object? summary = freezed,Object? experienceIds = null,Object? bulletIds = null,Object? projectIds = null,Object? projectBulletIds = null,Object? publicationIds = null,Object? publicationBulletIds = null,Object? bulletOverrides = null,Object? skillIds = null,Object? educationIds = null,Object? hobbyIds = null,Object? hiddenSections = null,Object? rationale = null,Object? keywordGaps = null,}) {
  return _then(_AiAssistantResult(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,experienceIds: null == experienceIds ? _self._experienceIds : experienceIds // ignore: cast_nullable_to_non_nullable
as List<String>,bulletIds: null == bulletIds ? _self._bulletIds : bulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,projectIds: null == projectIds ? _self._projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as List<String>,projectBulletIds: null == projectBulletIds ? _self._projectBulletIds : projectBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,publicationIds: null == publicationIds ? _self._publicationIds : publicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationBulletIds: null == publicationBulletIds ? _self._publicationBulletIds : publicationBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,bulletOverrides: null == bulletOverrides ? _self._bulletOverrides : bulletOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillIds: null == skillIds ? _self._skillIds : skillIds // ignore: cast_nullable_to_non_nullable
as List<String>,educationIds: null == educationIds ? _self._educationIds : educationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hobbyIds: null == hobbyIds ? _self._hobbyIds : hobbyIds // ignore: cast_nullable_to_non_nullable
as List<String>,hiddenSections: null == hiddenSections ? _self._hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>,rationale: null == rationale ? _self.rationale : rationale // ignore: cast_nullable_to_non_nullable
as String,keywordGaps: null == keywordGaps ? _self._keywordGaps : keywordGaps // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
