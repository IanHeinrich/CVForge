// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_vault.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvVault {

 int get schemaVersion; ContactBasics get basics; List<Experience> get experiences; List<SkillCategory> get skillCategories; List<Project> get projects; List<Education> get education; List<HobbyItem> get hobbies; List<Publication> get publications; String? get referencesNote; DateTime get updatedAt;
/// Create a copy of CvVault
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvVaultCopyWith<CvVault> get copyWith => _$CvVaultCopyWithImpl<CvVault>(this as CvVault, _$identity);

  /// Serializes this CvVault to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvVault&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.basics, basics) || other.basics == basics)&&const DeepCollectionEquality().equals(other.experiences, experiences)&&const DeepCollectionEquality().equals(other.skillCategories, skillCategories)&&const DeepCollectionEquality().equals(other.projects, projects)&&const DeepCollectionEquality().equals(other.education, education)&&const DeepCollectionEquality().equals(other.hobbies, hobbies)&&const DeepCollectionEquality().equals(other.publications, publications)&&(identical(other.referencesNote, referencesNote) || other.referencesNote == referencesNote)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,basics,const DeepCollectionEquality().hash(experiences),const DeepCollectionEquality().hash(skillCategories),const DeepCollectionEquality().hash(projects),const DeepCollectionEquality().hash(education),const DeepCollectionEquality().hash(hobbies),const DeepCollectionEquality().hash(publications),referencesNote,updatedAt);

@override
String toString() {
  return 'CvVault(schemaVersion: $schemaVersion, basics: $basics, experiences: $experiences, skillCategories: $skillCategories, projects: $projects, education: $education, hobbies: $hobbies, publications: $publications, referencesNote: $referencesNote, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CvVaultCopyWith<$Res>  {
  factory $CvVaultCopyWith(CvVault value, $Res Function(CvVault) _then) = _$CvVaultCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, ContactBasics basics, List<Experience> experiences, List<SkillCategory> skillCategories, List<Project> projects, List<Education> education, List<HobbyItem> hobbies, List<Publication> publications, String? referencesNote, DateTime updatedAt
});


$ContactBasicsCopyWith<$Res> get basics;

}
/// @nodoc
class _$CvVaultCopyWithImpl<$Res>
    implements $CvVaultCopyWith<$Res> {
  _$CvVaultCopyWithImpl(this._self, this._then);

  final CvVault _self;
  final $Res Function(CvVault) _then;

/// Create a copy of CvVault
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? basics = null,Object? experiences = null,Object? skillCategories = null,Object? projects = null,Object? education = null,Object? hobbies = null,Object? publications = null,Object? referencesNote = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,basics: null == basics ? _self.basics : basics // ignore: cast_nullable_to_non_nullable
as ContactBasics,experiences: null == experiences ? _self.experiences : experiences // ignore: cast_nullable_to_non_nullable
as List<Experience>,skillCategories: null == skillCategories ? _self.skillCategories : skillCategories // ignore: cast_nullable_to_non_nullable
as List<SkillCategory>,projects: null == projects ? _self.projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,education: null == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as List<Education>,hobbies: null == hobbies ? _self.hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as List<HobbyItem>,publications: null == publications ? _self.publications : publications // ignore: cast_nullable_to_non_nullable
as List<Publication>,referencesNote: freezed == referencesNote ? _self.referencesNote : referencesNote // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of CvVault
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactBasicsCopyWith<$Res> get basics {
  
  return $ContactBasicsCopyWith<$Res>(_self.basics, (value) {
    return _then(_self.copyWith(basics: value));
  });
}
}


/// Adds pattern-matching-related methods to [CvVault].
extension CvVaultPatterns on CvVault {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvVault value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvVault() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvVault value)  $default,){
final _that = this;
switch (_that) {
case _CvVault():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvVault value)?  $default,){
final _that = this;
switch (_that) {
case _CvVault() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  ContactBasics basics,  List<Experience> experiences,  List<SkillCategory> skillCategories,  List<Project> projects,  List<Education> education,  List<HobbyItem> hobbies,  List<Publication> publications,  String? referencesNote,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvVault() when $default != null:
return $default(_that.schemaVersion,_that.basics,_that.experiences,_that.skillCategories,_that.projects,_that.education,_that.hobbies,_that.publications,_that.referencesNote,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  ContactBasics basics,  List<Experience> experiences,  List<SkillCategory> skillCategories,  List<Project> projects,  List<Education> education,  List<HobbyItem> hobbies,  List<Publication> publications,  String? referencesNote,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CvVault():
return $default(_that.schemaVersion,_that.basics,_that.experiences,_that.skillCategories,_that.projects,_that.education,_that.hobbies,_that.publications,_that.referencesNote,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  ContactBasics basics,  List<Experience> experiences,  List<SkillCategory> skillCategories,  List<Project> projects,  List<Education> education,  List<HobbyItem> hobbies,  List<Publication> publications,  String? referencesNote,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CvVault() when $default != null:
return $default(_that.schemaVersion,_that.basics,_that.experiences,_that.skillCategories,_that.projects,_that.education,_that.hobbies,_that.publications,_that.referencesNote,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvVault implements CvVault {
  const _CvVault({required this.schemaVersion, required this.basics, final  List<Experience> experiences = const <Experience>[], final  List<SkillCategory> skillCategories = const <SkillCategory>[], final  List<Project> projects = const <Project>[], final  List<Education> education = const <Education>[], final  List<HobbyItem> hobbies = const <HobbyItem>[], final  List<Publication> publications = const <Publication>[], this.referencesNote, required this.updatedAt}): _experiences = experiences,_skillCategories = skillCategories,_projects = projects,_education = education,_hobbies = hobbies,_publications = publications;
  factory _CvVault.fromJson(Map<String, dynamic> json) => _$CvVaultFromJson(json);

@override final  int schemaVersion;
@override final  ContactBasics basics;
 final  List<Experience> _experiences;
@override@JsonKey() List<Experience> get experiences {
  if (_experiences is EqualUnmodifiableListView) return _experiences;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_experiences);
}

 final  List<SkillCategory> _skillCategories;
@override@JsonKey() List<SkillCategory> get skillCategories {
  if (_skillCategories is EqualUnmodifiableListView) return _skillCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillCategories);
}

 final  List<Project> _projects;
@override@JsonKey() List<Project> get projects {
  if (_projects is EqualUnmodifiableListView) return _projects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projects);
}

 final  List<Education> _education;
@override@JsonKey() List<Education> get education {
  if (_education is EqualUnmodifiableListView) return _education;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_education);
}

 final  List<HobbyItem> _hobbies;
@override@JsonKey() List<HobbyItem> get hobbies {
  if (_hobbies is EqualUnmodifiableListView) return _hobbies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hobbies);
}

 final  List<Publication> _publications;
@override@JsonKey() List<Publication> get publications {
  if (_publications is EqualUnmodifiableListView) return _publications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publications);
}

@override final  String? referencesNote;
@override final  DateTime updatedAt;

/// Create a copy of CvVault
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvVaultCopyWith<_CvVault> get copyWith => __$CvVaultCopyWithImpl<_CvVault>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvVaultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvVault&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.basics, basics) || other.basics == basics)&&const DeepCollectionEquality().equals(other._experiences, _experiences)&&const DeepCollectionEquality().equals(other._skillCategories, _skillCategories)&&const DeepCollectionEquality().equals(other._projects, _projects)&&const DeepCollectionEquality().equals(other._education, _education)&&const DeepCollectionEquality().equals(other._hobbies, _hobbies)&&const DeepCollectionEquality().equals(other._publications, _publications)&&(identical(other.referencesNote, referencesNote) || other.referencesNote == referencesNote)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,schemaVersion,basics,const DeepCollectionEquality().hash(_experiences),const DeepCollectionEquality().hash(_skillCategories),const DeepCollectionEquality().hash(_projects),const DeepCollectionEquality().hash(_education),const DeepCollectionEquality().hash(_hobbies),const DeepCollectionEquality().hash(_publications),referencesNote,updatedAt);

@override
String toString() {
  return 'CvVault(schemaVersion: $schemaVersion, basics: $basics, experiences: $experiences, skillCategories: $skillCategories, projects: $projects, education: $education, hobbies: $hobbies, publications: $publications, referencesNote: $referencesNote, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CvVaultCopyWith<$Res> implements $CvVaultCopyWith<$Res> {
  factory _$CvVaultCopyWith(_CvVault value, $Res Function(_CvVault) _then) = __$CvVaultCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, ContactBasics basics, List<Experience> experiences, List<SkillCategory> skillCategories, List<Project> projects, List<Education> education, List<HobbyItem> hobbies, List<Publication> publications, String? referencesNote, DateTime updatedAt
});


@override $ContactBasicsCopyWith<$Res> get basics;

}
/// @nodoc
class __$CvVaultCopyWithImpl<$Res>
    implements _$CvVaultCopyWith<$Res> {
  __$CvVaultCopyWithImpl(this._self, this._then);

  final _CvVault _self;
  final $Res Function(_CvVault) _then;

/// Create a copy of CvVault
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? basics = null,Object? experiences = null,Object? skillCategories = null,Object? projects = null,Object? education = null,Object? hobbies = null,Object? publications = null,Object? referencesNote = freezed,Object? updatedAt = null,}) {
  return _then(_CvVault(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,basics: null == basics ? _self.basics : basics // ignore: cast_nullable_to_non_nullable
as ContactBasics,experiences: null == experiences ? _self._experiences : experiences // ignore: cast_nullable_to_non_nullable
as List<Experience>,skillCategories: null == skillCategories ? _self._skillCategories : skillCategories // ignore: cast_nullable_to_non_nullable
as List<SkillCategory>,projects: null == projects ? _self._projects : projects // ignore: cast_nullable_to_non_nullable
as List<Project>,education: null == education ? _self._education : education // ignore: cast_nullable_to_non_nullable
as List<Education>,hobbies: null == hobbies ? _self._hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as List<HobbyItem>,publications: null == publications ? _self._publications : publications // ignore: cast_nullable_to_non_nullable
as List<Publication>,referencesNote: freezed == referencesNote ? _self.referencesNote : referencesNote // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of CvVault
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactBasicsCopyWith<$Res> get basics {
  
  return $ContactBasicsCopyWith<$Res>(_self.basics, (value) {
    return _then(_self.copyWith(basics: value));
  });
}
}

// dart format on
