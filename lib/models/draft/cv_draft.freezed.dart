// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cv_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CvDraft {

 int get schemaVersion; String get id; String get name; String get templateId; RegionProfile get region;/// The language this CV is written in — the value that renders, where
/// `DocumentDefaults.language` only seeded it.
///
/// Per-draft because a draft is one application to one employer:
/// Munich and London from one career history need two languages at
/// once. Snapshot at creation and never re-resolved, like [region].
/// Independent of the UI locale — see [DocumentLanguage].
 DocumentLanguage get documentLanguage;/// Free-text for the user's own tracking — never rendered.
 String get notes; List<String> get experienceIds;/// experienceId -> ordered bulletIds included. A missing key means no
/// bullets are shown; the service layer populates this when an
/// experience is added, and nothing is inferred here.
 Map<String, List<String>> get bulletIds; List<String> get projectIds;/// Same shape and rationale as [bulletIds], one level over for
/// [Project] bullets instead of [Experience] bullets.
 Map<String, List<String>> get projectBulletIds; List<String> get skillIds; List<String> get educationIds; List<String> get hobbyIds; List<String> get publicationIds;/// Same shape and rationale as [bulletIds]/[projectBulletIds], one
/// entity type over for [Publication] bullets.
 Map<String, List<String>> get publicationBulletIds; Set<CvSectionType> get hiddenSections;/// This draft's own print order, reorderable in Studio. Distinct from
/// `CvTemplate.sectionOrder`, which only seeds a brand-new draft —
/// switching template afterwards never touches this. Read
/// [effectiveSectionOrder], never this field, wherever order is
/// consumed.
 List<CvSectionType> get sectionOrder;/// A draft-only rewrite of the Vault's professional summary — null
/// means "inherit the Vault's", never "omit" (the Summary section
/// checkbox is what omits it). `CvComposer` prefers this over the
/// Vault's own summary, so tailoring a draft never mutates the master
/// Vault, preserving the master/draft separation that is this
/// product's entire premise.
 String? get tailoredSummary;/// bulletId -> rewritten text. Same null-means-inherit rationale as
/// [tailoredSummary], one level down — lets a bullet be rewritten for
/// one draft without touching the Vault. Bullet ids are globally
/// unique (see `Skill.linkedBulletIds`'s doc comment), so this map
/// doesn't need to be scoped per experience/project.
 Map<String, String> get bulletOverrides;/// Same null-means-inherit rationale as [tailoredSummary], one field
/// over, for `ContactBasics.headline`.
 String? get headlineOverride;/// Drops the headline from this draft entirely, independently of
/// [headlineOverride] — which is preserved while hidden, so toggling
/// back restores the edit rather than losing it.
///
/// A bool rather than a ninth [CvSectionType]: [hiddenSections] drives
/// the reorderable section list and `CvComposer`'s section walk, but
/// the headline sits in the header block, has no heading of its own
/// and cannot be reordered. In that enum it would show up in Studio's
/// section nav as a draggable row that renders nothing.
 bool get hideHeadline;/// Same null-means-inherit rationale as [tailoredSummary], one field
/// over, for `CvVault.referencesNote`.
 String? get referencesOverride;/// educationId -> rewritten `Education.details` text. Same
/// null-means-inherit rationale as [bulletOverrides], one entity type
/// over.
 Map<String, String> get educationDetailsOverrides;/// experienceId -> rewritten `Experience.role`.
 Map<String, String> get roleOverrides;/// projectId -> rewritten `Project.title`.
 Map<String, String> get projectTitleOverrides;/// skillId -> rewritten `Skill.label`.
 Map<String, String> get skillLabelOverrides;/// skillCategoryId -> rewritten `SkillCategory.name`.
 Map<String, String> get skillCategoryNameOverrides;/// hobbyId -> rewritten `HobbyItem.text`.
 Map<String, String> get hobbyOverrides;/// educationId -> rewritten `Education.qualification`.
 Map<String, String> get educationQualificationOverrides;/// educationId -> rewritten `Education.grade`.
 Map<String, String> get educationGradeOverrides;/// The language this draft was last translated into, or null if it
/// never has been.
///
/// Pure provenance — a translation is stored as ordinary overrides
/// and is indistinguishable from a hand edit, so this changes nothing
/// about rendering. It exists so Studio can offer "remove translation"
/// and can say when one has gone stale.
 DocumentLanguage? get translatedTo;/// The job ad this draft is tailored for. Persisted rather than a
/// modal's transient text, so an AI pass can be re-run against the
/// same ad. Distinct from [notes], which is never sent anywhere.
 String? get targetJobDescription; DateTime get updatedAt;
/// Create a copy of CvDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CvDraftCopyWith<CvDraft> get copyWith => _$CvDraftCopyWithImpl<CvDraft>(this as CvDraft, _$identity);

  /// Serializes this CvDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CvDraft&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.region, region) || other.region == region)&&(identical(other.documentLanguage, documentLanguage) || other.documentLanguage == documentLanguage)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.experienceIds, experienceIds)&&const DeepCollectionEquality().equals(other.bulletIds, bulletIds)&&const DeepCollectionEquality().equals(other.projectIds, projectIds)&&const DeepCollectionEquality().equals(other.projectBulletIds, projectBulletIds)&&const DeepCollectionEquality().equals(other.skillIds, skillIds)&&const DeepCollectionEquality().equals(other.educationIds, educationIds)&&const DeepCollectionEquality().equals(other.hobbyIds, hobbyIds)&&const DeepCollectionEquality().equals(other.publicationIds, publicationIds)&&const DeepCollectionEquality().equals(other.publicationBulletIds, publicationBulletIds)&&const DeepCollectionEquality().equals(other.hiddenSections, hiddenSections)&&const DeepCollectionEquality().equals(other.sectionOrder, sectionOrder)&&(identical(other.tailoredSummary, tailoredSummary) || other.tailoredSummary == tailoredSummary)&&const DeepCollectionEquality().equals(other.bulletOverrides, bulletOverrides)&&(identical(other.headlineOverride, headlineOverride) || other.headlineOverride == headlineOverride)&&(identical(other.hideHeadline, hideHeadline) || other.hideHeadline == hideHeadline)&&(identical(other.referencesOverride, referencesOverride) || other.referencesOverride == referencesOverride)&&const DeepCollectionEquality().equals(other.educationDetailsOverrides, educationDetailsOverrides)&&const DeepCollectionEquality().equals(other.roleOverrides, roleOverrides)&&const DeepCollectionEquality().equals(other.projectTitleOverrides, projectTitleOverrides)&&const DeepCollectionEquality().equals(other.skillLabelOverrides, skillLabelOverrides)&&const DeepCollectionEquality().equals(other.skillCategoryNameOverrides, skillCategoryNameOverrides)&&const DeepCollectionEquality().equals(other.hobbyOverrides, hobbyOverrides)&&const DeepCollectionEquality().equals(other.educationQualificationOverrides, educationQualificationOverrides)&&const DeepCollectionEquality().equals(other.educationGradeOverrides, educationGradeOverrides)&&(identical(other.translatedTo, translatedTo) || other.translatedTo == translatedTo)&&(identical(other.targetJobDescription, targetJobDescription) || other.targetJobDescription == targetJobDescription)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,schemaVersion,id,name,templateId,region,documentLanguage,notes,const DeepCollectionEquality().hash(experienceIds),const DeepCollectionEquality().hash(bulletIds),const DeepCollectionEquality().hash(projectIds),const DeepCollectionEquality().hash(projectBulletIds),const DeepCollectionEquality().hash(skillIds),const DeepCollectionEquality().hash(educationIds),const DeepCollectionEquality().hash(hobbyIds),const DeepCollectionEquality().hash(publicationIds),const DeepCollectionEquality().hash(publicationBulletIds),const DeepCollectionEquality().hash(hiddenSections),const DeepCollectionEquality().hash(sectionOrder),tailoredSummary,const DeepCollectionEquality().hash(bulletOverrides),headlineOverride,hideHeadline,referencesOverride,const DeepCollectionEquality().hash(educationDetailsOverrides),const DeepCollectionEquality().hash(roleOverrides),const DeepCollectionEquality().hash(projectTitleOverrides),const DeepCollectionEquality().hash(skillLabelOverrides),const DeepCollectionEquality().hash(skillCategoryNameOverrides),const DeepCollectionEquality().hash(hobbyOverrides),const DeepCollectionEquality().hash(educationQualificationOverrides),const DeepCollectionEquality().hash(educationGradeOverrides),translatedTo,targetJobDescription,updatedAt]);

@override
String toString() {
  return 'CvDraft(schemaVersion: $schemaVersion, id: $id, name: $name, templateId: $templateId, region: $region, documentLanguage: $documentLanguage, notes: $notes, experienceIds: $experienceIds, bulletIds: $bulletIds, projectIds: $projectIds, projectBulletIds: $projectBulletIds, skillIds: $skillIds, educationIds: $educationIds, hobbyIds: $hobbyIds, publicationIds: $publicationIds, publicationBulletIds: $publicationBulletIds, hiddenSections: $hiddenSections, sectionOrder: $sectionOrder, tailoredSummary: $tailoredSummary, bulletOverrides: $bulletOverrides, headlineOverride: $headlineOverride, hideHeadline: $hideHeadline, referencesOverride: $referencesOverride, educationDetailsOverrides: $educationDetailsOverrides, roleOverrides: $roleOverrides, projectTitleOverrides: $projectTitleOverrides, skillLabelOverrides: $skillLabelOverrides, skillCategoryNameOverrides: $skillCategoryNameOverrides, hobbyOverrides: $hobbyOverrides, educationQualificationOverrides: $educationQualificationOverrides, educationGradeOverrides: $educationGradeOverrides, translatedTo: $translatedTo, targetJobDescription: $targetJobDescription, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CvDraftCopyWith<$Res>  {
  factory $CvDraftCopyWith(CvDraft value, $Res Function(CvDraft) _then) = _$CvDraftCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String id, String name, String templateId, RegionProfile region, DocumentLanguage documentLanguage, String notes, List<String> experienceIds, Map<String, List<String>> bulletIds, List<String> projectIds, Map<String, List<String>> projectBulletIds, List<String> skillIds, List<String> educationIds, List<String> hobbyIds, List<String> publicationIds, Map<String, List<String>> publicationBulletIds, Set<CvSectionType> hiddenSections, List<CvSectionType> sectionOrder, String? tailoredSummary, Map<String, String> bulletOverrides, String? headlineOverride, bool hideHeadline, String? referencesOverride, Map<String, String> educationDetailsOverrides, Map<String, String> roleOverrides, Map<String, String> projectTitleOverrides, Map<String, String> skillLabelOverrides, Map<String, String> skillCategoryNameOverrides, Map<String, String> hobbyOverrides, Map<String, String> educationQualificationOverrides, Map<String, String> educationGradeOverrides, DocumentLanguage? translatedTo, String? targetJobDescription, DateTime updatedAt
});




}
/// @nodoc
class _$CvDraftCopyWithImpl<$Res>
    implements $CvDraftCopyWith<$Res> {
  _$CvDraftCopyWithImpl(this._self, this._then);

  final CvDraft _self;
  final $Res Function(CvDraft) _then;

/// Create a copy of CvDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? templateId = null,Object? region = null,Object? documentLanguage = null,Object? notes = null,Object? experienceIds = null,Object? bulletIds = null,Object? projectIds = null,Object? projectBulletIds = null,Object? skillIds = null,Object? educationIds = null,Object? hobbyIds = null,Object? publicationIds = null,Object? publicationBulletIds = null,Object? hiddenSections = null,Object? sectionOrder = null,Object? tailoredSummary = freezed,Object? bulletOverrides = null,Object? headlineOverride = freezed,Object? hideHeadline = null,Object? referencesOverride = freezed,Object? educationDetailsOverrides = null,Object? roleOverrides = null,Object? projectTitleOverrides = null,Object? skillLabelOverrides = null,Object? skillCategoryNameOverrides = null,Object? hobbyOverrides = null,Object? educationQualificationOverrides = null,Object? educationGradeOverrides = null,Object? translatedTo = freezed,Object? targetJobDescription = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionProfile,documentLanguage: null == documentLanguage ? _self.documentLanguage : documentLanguage // ignore: cast_nullable_to_non_nullable
as DocumentLanguage,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,experienceIds: null == experienceIds ? _self.experienceIds : experienceIds // ignore: cast_nullable_to_non_nullable
as List<String>,bulletIds: null == bulletIds ? _self.bulletIds : bulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,projectIds: null == projectIds ? _self.projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as List<String>,projectBulletIds: null == projectBulletIds ? _self.projectBulletIds : projectBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,skillIds: null == skillIds ? _self.skillIds : skillIds // ignore: cast_nullable_to_non_nullable
as List<String>,educationIds: null == educationIds ? _self.educationIds : educationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hobbyIds: null == hobbyIds ? _self.hobbyIds : hobbyIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationIds: null == publicationIds ? _self.publicationIds : publicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationBulletIds: null == publicationBulletIds ? _self.publicationBulletIds : publicationBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,hiddenSections: null == hiddenSections ? _self.hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>,sectionOrder: null == sectionOrder ? _self.sectionOrder : sectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>,tailoredSummary: freezed == tailoredSummary ? _self.tailoredSummary : tailoredSummary // ignore: cast_nullable_to_non_nullable
as String?,bulletOverrides: null == bulletOverrides ? _self.bulletOverrides : bulletOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,headlineOverride: freezed == headlineOverride ? _self.headlineOverride : headlineOverride // ignore: cast_nullable_to_non_nullable
as String?,hideHeadline: null == hideHeadline ? _self.hideHeadline : hideHeadline // ignore: cast_nullable_to_non_nullable
as bool,referencesOverride: freezed == referencesOverride ? _self.referencesOverride : referencesOverride // ignore: cast_nullable_to_non_nullable
as String?,educationDetailsOverrides: null == educationDetailsOverrides ? _self.educationDetailsOverrides : educationDetailsOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,roleOverrides: null == roleOverrides ? _self.roleOverrides : roleOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,projectTitleOverrides: null == projectTitleOverrides ? _self.projectTitleOverrides : projectTitleOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillLabelOverrides: null == skillLabelOverrides ? _self.skillLabelOverrides : skillLabelOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillCategoryNameOverrides: null == skillCategoryNameOverrides ? _self.skillCategoryNameOverrides : skillCategoryNameOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hobbyOverrides: null == hobbyOverrides ? _self.hobbyOverrides : hobbyOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationQualificationOverrides: null == educationQualificationOverrides ? _self.educationQualificationOverrides : educationQualificationOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationGradeOverrides: null == educationGradeOverrides ? _self.educationGradeOverrides : educationGradeOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translatedTo: freezed == translatedTo ? _self.translatedTo : translatedTo // ignore: cast_nullable_to_non_nullable
as DocumentLanguage?,targetJobDescription: freezed == targetJobDescription ? _self.targetJobDescription : targetJobDescription // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [CvDraft].
extension CvDraftPatterns on CvDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CvDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CvDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CvDraft value)  $default,){
final _that = this;
switch (_that) {
case _CvDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CvDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CvDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  String templateId,  RegionProfile region,  DocumentLanguage documentLanguage,  String notes,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  List<String> publicationIds,  Map<String, List<String>> publicationBulletIds,  Set<CvSectionType> hiddenSections,  List<CvSectionType> sectionOrder,  String? tailoredSummary,  Map<String, String> bulletOverrides,  String? headlineOverride,  bool hideHeadline,  String? referencesOverride,  Map<String, String> educationDetailsOverrides,  Map<String, String> roleOverrides,  Map<String, String> projectTitleOverrides,  Map<String, String> skillLabelOverrides,  Map<String, String> skillCategoryNameOverrides,  Map<String, String> hobbyOverrides,  Map<String, String> educationQualificationOverrides,  Map<String, String> educationGradeOverrides,  DocumentLanguage? translatedTo,  String? targetJobDescription,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CvDraft() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.templateId,_that.region,_that.documentLanguage,_that.notes,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.publicationIds,_that.publicationBulletIds,_that.hiddenSections,_that.sectionOrder,_that.tailoredSummary,_that.bulletOverrides,_that.headlineOverride,_that.hideHeadline,_that.referencesOverride,_that.educationDetailsOverrides,_that.roleOverrides,_that.projectTitleOverrides,_that.skillLabelOverrides,_that.skillCategoryNameOverrides,_that.hobbyOverrides,_that.educationQualificationOverrides,_that.educationGradeOverrides,_that.translatedTo,_that.targetJobDescription,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  String templateId,  RegionProfile region,  DocumentLanguage documentLanguage,  String notes,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  List<String> publicationIds,  Map<String, List<String>> publicationBulletIds,  Set<CvSectionType> hiddenSections,  List<CvSectionType> sectionOrder,  String? tailoredSummary,  Map<String, String> bulletOverrides,  String? headlineOverride,  bool hideHeadline,  String? referencesOverride,  Map<String, String> educationDetailsOverrides,  Map<String, String> roleOverrides,  Map<String, String> projectTitleOverrides,  Map<String, String> skillLabelOverrides,  Map<String, String> skillCategoryNameOverrides,  Map<String, String> hobbyOverrides,  Map<String, String> educationQualificationOverrides,  Map<String, String> educationGradeOverrides,  DocumentLanguage? translatedTo,  String? targetJobDescription,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _CvDraft():
return $default(_that.schemaVersion,_that.id,_that.name,_that.templateId,_that.region,_that.documentLanguage,_that.notes,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.publicationIds,_that.publicationBulletIds,_that.hiddenSections,_that.sectionOrder,_that.tailoredSummary,_that.bulletOverrides,_that.headlineOverride,_that.hideHeadline,_that.referencesOverride,_that.educationDetailsOverrides,_that.roleOverrides,_that.projectTitleOverrides,_that.skillLabelOverrides,_that.skillCategoryNameOverrides,_that.hobbyOverrides,_that.educationQualificationOverrides,_that.educationGradeOverrides,_that.translatedTo,_that.targetJobDescription,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String id,  String name,  String templateId,  RegionProfile region,  DocumentLanguage documentLanguage,  String notes,  List<String> experienceIds,  Map<String, List<String>> bulletIds,  List<String> projectIds,  Map<String, List<String>> projectBulletIds,  List<String> skillIds,  List<String> educationIds,  List<String> hobbyIds,  List<String> publicationIds,  Map<String, List<String>> publicationBulletIds,  Set<CvSectionType> hiddenSections,  List<CvSectionType> sectionOrder,  String? tailoredSummary,  Map<String, String> bulletOverrides,  String? headlineOverride,  bool hideHeadline,  String? referencesOverride,  Map<String, String> educationDetailsOverrides,  Map<String, String> roleOverrides,  Map<String, String> projectTitleOverrides,  Map<String, String> skillLabelOverrides,  Map<String, String> skillCategoryNameOverrides,  Map<String, String> hobbyOverrides,  Map<String, String> educationQualificationOverrides,  Map<String, String> educationGradeOverrides,  DocumentLanguage? translatedTo,  String? targetJobDescription,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _CvDraft() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.templateId,_that.region,_that.documentLanguage,_that.notes,_that.experienceIds,_that.bulletIds,_that.projectIds,_that.projectBulletIds,_that.skillIds,_that.educationIds,_that.hobbyIds,_that.publicationIds,_that.publicationBulletIds,_that.hiddenSections,_that.sectionOrder,_that.tailoredSummary,_that.bulletOverrides,_that.headlineOverride,_that.hideHeadline,_that.referencesOverride,_that.educationDetailsOverrides,_that.roleOverrides,_that.projectTitleOverrides,_that.skillLabelOverrides,_that.skillCategoryNameOverrides,_that.hobbyOverrides,_that.educationQualificationOverrides,_that.educationGradeOverrides,_that.translatedTo,_that.targetJobDescription,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CvDraft implements CvDraft {
  const _CvDraft({required this.schemaVersion, required this.id, required this.name, required this.templateId, this.region = RegionProfile.uk, this.documentLanguage = DocumentLanguage.enGb, this.notes = '', final  List<String> experienceIds = const <String>[], final  Map<String, List<String>> bulletIds = const <String, List<String>>{}, final  List<String> projectIds = const <String>[], final  Map<String, List<String>> projectBulletIds = const <String, List<String>>{}, final  List<String> skillIds = const <String>[], final  List<String> educationIds = const <String>[], final  List<String> hobbyIds = const <String>[], final  List<String> publicationIds = const <String>[], final  Map<String, List<String>> publicationBulletIds = const <String, List<String>>{}, final  Set<CvSectionType> hiddenSections = const <CvSectionType>{}, final  List<CvSectionType> sectionOrder = const <CvSectionType>[CvSectionType.summary, CvSectionType.skills, CvSectionType.experience, CvSectionType.projects, CvSectionType.education, CvSectionType.hobbies, CvSectionType.references, CvSectionType.publications], this.tailoredSummary, final  Map<String, String> bulletOverrides = const <String, String>{}, this.headlineOverride, this.hideHeadline = false, this.referencesOverride, final  Map<String, String> educationDetailsOverrides = const <String, String>{}, final  Map<String, String> roleOverrides = const <String, String>{}, final  Map<String, String> projectTitleOverrides = const <String, String>{}, final  Map<String, String> skillLabelOverrides = const <String, String>{}, final  Map<String, String> skillCategoryNameOverrides = const <String, String>{}, final  Map<String, String> hobbyOverrides = const <String, String>{}, final  Map<String, String> educationQualificationOverrides = const <String, String>{}, final  Map<String, String> educationGradeOverrides = const <String, String>{}, this.translatedTo, this.targetJobDescription, required this.updatedAt}): _experienceIds = experienceIds,_bulletIds = bulletIds,_projectIds = projectIds,_projectBulletIds = projectBulletIds,_skillIds = skillIds,_educationIds = educationIds,_hobbyIds = hobbyIds,_publicationIds = publicationIds,_publicationBulletIds = publicationBulletIds,_hiddenSections = hiddenSections,_sectionOrder = sectionOrder,_bulletOverrides = bulletOverrides,_educationDetailsOverrides = educationDetailsOverrides,_roleOverrides = roleOverrides,_projectTitleOverrides = projectTitleOverrides,_skillLabelOverrides = skillLabelOverrides,_skillCategoryNameOverrides = skillCategoryNameOverrides,_hobbyOverrides = hobbyOverrides,_educationQualificationOverrides = educationQualificationOverrides,_educationGradeOverrides = educationGradeOverrides;
  factory _CvDraft.fromJson(Map<String, dynamic> json) => _$CvDraftFromJson(json);

@override final  int schemaVersion;
@override final  String id;
@override final  String name;
@override final  String templateId;
@override@JsonKey() final  RegionProfile region;
/// The language this CV is written in — the value that renders, where
/// `DocumentDefaults.language` only seeded it.
///
/// Per-draft because a draft is one application to one employer:
/// Munich and London from one career history need two languages at
/// once. Snapshot at creation and never re-resolved, like [region].
/// Independent of the UI locale — see [DocumentLanguage].
@override@JsonKey() final  DocumentLanguage documentLanguage;
/// Free-text for the user's own tracking — never rendered.
@override@JsonKey() final  String notes;
 final  List<String> _experienceIds;
@override@JsonKey() List<String> get experienceIds {
  if (_experienceIds is EqualUnmodifiableListView) return _experienceIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_experienceIds);
}

/// experienceId -> ordered bulletIds included. A missing key means no
/// bullets are shown; the service layer populates this when an
/// experience is added, and nothing is inferred here.
 final  Map<String, List<String>> _bulletIds;
/// experienceId -> ordered bulletIds included. A missing key means no
/// bullets are shown; the service layer populates this when an
/// experience is added, and nothing is inferred here.
@override@JsonKey() Map<String, List<String>> get bulletIds {
  if (_bulletIds is EqualUnmodifiableMapView) return _bulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bulletIds);
}

 final  List<String> _projectIds;
@override@JsonKey() List<String> get projectIds {
  if (_projectIds is EqualUnmodifiableListView) return _projectIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_projectIds);
}

/// Same shape and rationale as [bulletIds], one level over for
/// [Project] bullets instead of [Experience] bullets.
 final  Map<String, List<String>> _projectBulletIds;
/// Same shape and rationale as [bulletIds], one level over for
/// [Project] bullets instead of [Experience] bullets.
@override@JsonKey() Map<String, List<String>> get projectBulletIds {
  if (_projectBulletIds is EqualUnmodifiableMapView) return _projectBulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_projectBulletIds);
}

 final  List<String> _skillIds;
@override@JsonKey() List<String> get skillIds {
  if (_skillIds is EqualUnmodifiableListView) return _skillIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_skillIds);
}

 final  List<String> _educationIds;
@override@JsonKey() List<String> get educationIds {
  if (_educationIds is EqualUnmodifiableListView) return _educationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_educationIds);
}

 final  List<String> _hobbyIds;
@override@JsonKey() List<String> get hobbyIds {
  if (_hobbyIds is EqualUnmodifiableListView) return _hobbyIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hobbyIds);
}

 final  List<String> _publicationIds;
@override@JsonKey() List<String> get publicationIds {
  if (_publicationIds is EqualUnmodifiableListView) return _publicationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_publicationIds);
}

/// Same shape and rationale as [bulletIds]/[projectBulletIds], one
/// entity type over for [Publication] bullets.
 final  Map<String, List<String>> _publicationBulletIds;
/// Same shape and rationale as [bulletIds]/[projectBulletIds], one
/// entity type over for [Publication] bullets.
@override@JsonKey() Map<String, List<String>> get publicationBulletIds {
  if (_publicationBulletIds is EqualUnmodifiableMapView) return _publicationBulletIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_publicationBulletIds);
}

 final  Set<CvSectionType> _hiddenSections;
@override@JsonKey() Set<CvSectionType> get hiddenSections {
  if (_hiddenSections is EqualUnmodifiableSetView) return _hiddenSections;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_hiddenSections);
}

/// This draft's own print order, reorderable in Studio. Distinct from
/// `CvTemplate.sectionOrder`, which only seeds a brand-new draft —
/// switching template afterwards never touches this. Read
/// [effectiveSectionOrder], never this field, wherever order is
/// consumed.
 final  List<CvSectionType> _sectionOrder;
/// This draft's own print order, reorderable in Studio. Distinct from
/// `CvTemplate.sectionOrder`, which only seeds a brand-new draft —
/// switching template afterwards never touches this. Read
/// [effectiveSectionOrder], never this field, wherever order is
/// consumed.
@override@JsonKey() List<CvSectionType> get sectionOrder {
  if (_sectionOrder is EqualUnmodifiableListView) return _sectionOrder;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sectionOrder);
}

/// A draft-only rewrite of the Vault's professional summary — null
/// means "inherit the Vault's", never "omit" (the Summary section
/// checkbox is what omits it). `CvComposer` prefers this over the
/// Vault's own summary, so tailoring a draft never mutates the master
/// Vault, preserving the master/draft separation that is this
/// product's entire premise.
@override final  String? tailoredSummary;
/// bulletId -> rewritten text. Same null-means-inherit rationale as
/// [tailoredSummary], one level down — lets a bullet be rewritten for
/// one draft without touching the Vault. Bullet ids are globally
/// unique (see `Skill.linkedBulletIds`'s doc comment), so this map
/// doesn't need to be scoped per experience/project.
 final  Map<String, String> _bulletOverrides;
/// bulletId -> rewritten text. Same null-means-inherit rationale as
/// [tailoredSummary], one level down — lets a bullet be rewritten for
/// one draft without touching the Vault. Bullet ids are globally
/// unique (see `Skill.linkedBulletIds`'s doc comment), so this map
/// doesn't need to be scoped per experience/project.
@override@JsonKey() Map<String, String> get bulletOverrides {
  if (_bulletOverrides is EqualUnmodifiableMapView) return _bulletOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_bulletOverrides);
}

/// Same null-means-inherit rationale as [tailoredSummary], one field
/// over, for `ContactBasics.headline`.
@override final  String? headlineOverride;
/// Drops the headline from this draft entirely, independently of
/// [headlineOverride] — which is preserved while hidden, so toggling
/// back restores the edit rather than losing it.
///
/// A bool rather than a ninth [CvSectionType]: [hiddenSections] drives
/// the reorderable section list and `CvComposer`'s section walk, but
/// the headline sits in the header block, has no heading of its own
/// and cannot be reordered. In that enum it would show up in Studio's
/// section nav as a draggable row that renders nothing.
@override@JsonKey() final  bool hideHeadline;
/// Same null-means-inherit rationale as [tailoredSummary], one field
/// over, for `CvVault.referencesNote`.
@override final  String? referencesOverride;
/// educationId -> rewritten `Education.details` text. Same
/// null-means-inherit rationale as [bulletOverrides], one entity type
/// over.
 final  Map<String, String> _educationDetailsOverrides;
/// educationId -> rewritten `Education.details` text. Same
/// null-means-inherit rationale as [bulletOverrides], one entity type
/// over.
@override@JsonKey() Map<String, String> get educationDetailsOverrides {
  if (_educationDetailsOverrides is EqualUnmodifiableMapView) return _educationDetailsOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_educationDetailsOverrides);
}

/// experienceId -> rewritten `Experience.role`.
 final  Map<String, String> _roleOverrides;
/// experienceId -> rewritten `Experience.role`.
@override@JsonKey() Map<String, String> get roleOverrides {
  if (_roleOverrides is EqualUnmodifiableMapView) return _roleOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_roleOverrides);
}

/// projectId -> rewritten `Project.title`.
 final  Map<String, String> _projectTitleOverrides;
/// projectId -> rewritten `Project.title`.
@override@JsonKey() Map<String, String> get projectTitleOverrides {
  if (_projectTitleOverrides is EqualUnmodifiableMapView) return _projectTitleOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_projectTitleOverrides);
}

/// skillId -> rewritten `Skill.label`.
 final  Map<String, String> _skillLabelOverrides;
/// skillId -> rewritten `Skill.label`.
@override@JsonKey() Map<String, String> get skillLabelOverrides {
  if (_skillLabelOverrides is EqualUnmodifiableMapView) return _skillLabelOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_skillLabelOverrides);
}

/// skillCategoryId -> rewritten `SkillCategory.name`.
 final  Map<String, String> _skillCategoryNameOverrides;
/// skillCategoryId -> rewritten `SkillCategory.name`.
@override@JsonKey() Map<String, String> get skillCategoryNameOverrides {
  if (_skillCategoryNameOverrides is EqualUnmodifiableMapView) return _skillCategoryNameOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_skillCategoryNameOverrides);
}

/// hobbyId -> rewritten `HobbyItem.text`.
 final  Map<String, String> _hobbyOverrides;
/// hobbyId -> rewritten `HobbyItem.text`.
@override@JsonKey() Map<String, String> get hobbyOverrides {
  if (_hobbyOverrides is EqualUnmodifiableMapView) return _hobbyOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_hobbyOverrides);
}

/// educationId -> rewritten `Education.qualification`.
 final  Map<String, String> _educationQualificationOverrides;
/// educationId -> rewritten `Education.qualification`.
@override@JsonKey() Map<String, String> get educationQualificationOverrides {
  if (_educationQualificationOverrides is EqualUnmodifiableMapView) return _educationQualificationOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_educationQualificationOverrides);
}

/// educationId -> rewritten `Education.grade`.
 final  Map<String, String> _educationGradeOverrides;
/// educationId -> rewritten `Education.grade`.
@override@JsonKey() Map<String, String> get educationGradeOverrides {
  if (_educationGradeOverrides is EqualUnmodifiableMapView) return _educationGradeOverrides;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_educationGradeOverrides);
}

/// The language this draft was last translated into, or null if it
/// never has been.
///
/// Pure provenance — a translation is stored as ordinary overrides
/// and is indistinguishable from a hand edit, so this changes nothing
/// about rendering. It exists so Studio can offer "remove translation"
/// and can say when one has gone stale.
@override final  DocumentLanguage? translatedTo;
/// The job ad this draft is tailored for. Persisted rather than a
/// modal's transient text, so an AI pass can be re-run against the
/// same ad. Distinct from [notes], which is never sent anywhere.
@override final  String? targetJobDescription;
@override final  DateTime updatedAt;

/// Create a copy of CvDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CvDraftCopyWith<_CvDraft> get copyWith => __$CvDraftCopyWithImpl<_CvDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CvDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CvDraft&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.templateId, templateId) || other.templateId == templateId)&&(identical(other.region, region) || other.region == region)&&(identical(other.documentLanguage, documentLanguage) || other.documentLanguage == documentLanguage)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._experienceIds, _experienceIds)&&const DeepCollectionEquality().equals(other._bulletIds, _bulletIds)&&const DeepCollectionEquality().equals(other._projectIds, _projectIds)&&const DeepCollectionEquality().equals(other._projectBulletIds, _projectBulletIds)&&const DeepCollectionEquality().equals(other._skillIds, _skillIds)&&const DeepCollectionEquality().equals(other._educationIds, _educationIds)&&const DeepCollectionEquality().equals(other._hobbyIds, _hobbyIds)&&const DeepCollectionEquality().equals(other._publicationIds, _publicationIds)&&const DeepCollectionEquality().equals(other._publicationBulletIds, _publicationBulletIds)&&const DeepCollectionEquality().equals(other._hiddenSections, _hiddenSections)&&const DeepCollectionEquality().equals(other._sectionOrder, _sectionOrder)&&(identical(other.tailoredSummary, tailoredSummary) || other.tailoredSummary == tailoredSummary)&&const DeepCollectionEquality().equals(other._bulletOverrides, _bulletOverrides)&&(identical(other.headlineOverride, headlineOverride) || other.headlineOverride == headlineOverride)&&(identical(other.hideHeadline, hideHeadline) || other.hideHeadline == hideHeadline)&&(identical(other.referencesOverride, referencesOverride) || other.referencesOverride == referencesOverride)&&const DeepCollectionEquality().equals(other._educationDetailsOverrides, _educationDetailsOverrides)&&const DeepCollectionEquality().equals(other._roleOverrides, _roleOverrides)&&const DeepCollectionEquality().equals(other._projectTitleOverrides, _projectTitleOverrides)&&const DeepCollectionEquality().equals(other._skillLabelOverrides, _skillLabelOverrides)&&const DeepCollectionEquality().equals(other._skillCategoryNameOverrides, _skillCategoryNameOverrides)&&const DeepCollectionEquality().equals(other._hobbyOverrides, _hobbyOverrides)&&const DeepCollectionEquality().equals(other._educationQualificationOverrides, _educationQualificationOverrides)&&const DeepCollectionEquality().equals(other._educationGradeOverrides, _educationGradeOverrides)&&(identical(other.translatedTo, translatedTo) || other.translatedTo == translatedTo)&&(identical(other.targetJobDescription, targetJobDescription) || other.targetJobDescription == targetJobDescription)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,schemaVersion,id,name,templateId,region,documentLanguage,notes,const DeepCollectionEquality().hash(_experienceIds),const DeepCollectionEquality().hash(_bulletIds),const DeepCollectionEquality().hash(_projectIds),const DeepCollectionEquality().hash(_projectBulletIds),const DeepCollectionEquality().hash(_skillIds),const DeepCollectionEquality().hash(_educationIds),const DeepCollectionEquality().hash(_hobbyIds),const DeepCollectionEquality().hash(_publicationIds),const DeepCollectionEquality().hash(_publicationBulletIds),const DeepCollectionEquality().hash(_hiddenSections),const DeepCollectionEquality().hash(_sectionOrder),tailoredSummary,const DeepCollectionEquality().hash(_bulletOverrides),headlineOverride,hideHeadline,referencesOverride,const DeepCollectionEquality().hash(_educationDetailsOverrides),const DeepCollectionEquality().hash(_roleOverrides),const DeepCollectionEquality().hash(_projectTitleOverrides),const DeepCollectionEquality().hash(_skillLabelOverrides),const DeepCollectionEquality().hash(_skillCategoryNameOverrides),const DeepCollectionEquality().hash(_hobbyOverrides),const DeepCollectionEquality().hash(_educationQualificationOverrides),const DeepCollectionEquality().hash(_educationGradeOverrides),translatedTo,targetJobDescription,updatedAt]);

@override
String toString() {
  return 'CvDraft(schemaVersion: $schemaVersion, id: $id, name: $name, templateId: $templateId, region: $region, documentLanguage: $documentLanguage, notes: $notes, experienceIds: $experienceIds, bulletIds: $bulletIds, projectIds: $projectIds, projectBulletIds: $projectBulletIds, skillIds: $skillIds, educationIds: $educationIds, hobbyIds: $hobbyIds, publicationIds: $publicationIds, publicationBulletIds: $publicationBulletIds, hiddenSections: $hiddenSections, sectionOrder: $sectionOrder, tailoredSummary: $tailoredSummary, bulletOverrides: $bulletOverrides, headlineOverride: $headlineOverride, hideHeadline: $hideHeadline, referencesOverride: $referencesOverride, educationDetailsOverrides: $educationDetailsOverrides, roleOverrides: $roleOverrides, projectTitleOverrides: $projectTitleOverrides, skillLabelOverrides: $skillLabelOverrides, skillCategoryNameOverrides: $skillCategoryNameOverrides, hobbyOverrides: $hobbyOverrides, educationQualificationOverrides: $educationQualificationOverrides, educationGradeOverrides: $educationGradeOverrides, translatedTo: $translatedTo, targetJobDescription: $targetJobDescription, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CvDraftCopyWith<$Res> implements $CvDraftCopyWith<$Res> {
  factory _$CvDraftCopyWith(_CvDraft value, $Res Function(_CvDraft) _then) = __$CvDraftCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String id, String name, String templateId, RegionProfile region, DocumentLanguage documentLanguage, String notes, List<String> experienceIds, Map<String, List<String>> bulletIds, List<String> projectIds, Map<String, List<String>> projectBulletIds, List<String> skillIds, List<String> educationIds, List<String> hobbyIds, List<String> publicationIds, Map<String, List<String>> publicationBulletIds, Set<CvSectionType> hiddenSections, List<CvSectionType> sectionOrder, String? tailoredSummary, Map<String, String> bulletOverrides, String? headlineOverride, bool hideHeadline, String? referencesOverride, Map<String, String> educationDetailsOverrides, Map<String, String> roleOverrides, Map<String, String> projectTitleOverrides, Map<String, String> skillLabelOverrides, Map<String, String> skillCategoryNameOverrides, Map<String, String> hobbyOverrides, Map<String, String> educationQualificationOverrides, Map<String, String> educationGradeOverrides, DocumentLanguage? translatedTo, String? targetJobDescription, DateTime updatedAt
});




}
/// @nodoc
class __$CvDraftCopyWithImpl<$Res>
    implements _$CvDraftCopyWith<$Res> {
  __$CvDraftCopyWithImpl(this._self, this._then);

  final _CvDraft _self;
  final $Res Function(_CvDraft) _then;

/// Create a copy of CvDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? templateId = null,Object? region = null,Object? documentLanguage = null,Object? notes = null,Object? experienceIds = null,Object? bulletIds = null,Object? projectIds = null,Object? projectBulletIds = null,Object? skillIds = null,Object? educationIds = null,Object? hobbyIds = null,Object? publicationIds = null,Object? publicationBulletIds = null,Object? hiddenSections = null,Object? sectionOrder = null,Object? tailoredSummary = freezed,Object? bulletOverrides = null,Object? headlineOverride = freezed,Object? hideHeadline = null,Object? referencesOverride = freezed,Object? educationDetailsOverrides = null,Object? roleOverrides = null,Object? projectTitleOverrides = null,Object? skillLabelOverrides = null,Object? skillCategoryNameOverrides = null,Object? hobbyOverrides = null,Object? educationQualificationOverrides = null,Object? educationGradeOverrides = null,Object? translatedTo = freezed,Object? targetJobDescription = freezed,Object? updatedAt = null,}) {
  return _then(_CvDraft(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,templateId: null == templateId ? _self.templateId : templateId // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as RegionProfile,documentLanguage: null == documentLanguage ? _self.documentLanguage : documentLanguage // ignore: cast_nullable_to_non_nullable
as DocumentLanguage,notes: null == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String,experienceIds: null == experienceIds ? _self._experienceIds : experienceIds // ignore: cast_nullable_to_non_nullable
as List<String>,bulletIds: null == bulletIds ? _self._bulletIds : bulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,projectIds: null == projectIds ? _self._projectIds : projectIds // ignore: cast_nullable_to_non_nullable
as List<String>,projectBulletIds: null == projectBulletIds ? _self._projectBulletIds : projectBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,skillIds: null == skillIds ? _self._skillIds : skillIds // ignore: cast_nullable_to_non_nullable
as List<String>,educationIds: null == educationIds ? _self._educationIds : educationIds // ignore: cast_nullable_to_non_nullable
as List<String>,hobbyIds: null == hobbyIds ? _self._hobbyIds : hobbyIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationIds: null == publicationIds ? _self._publicationIds : publicationIds // ignore: cast_nullable_to_non_nullable
as List<String>,publicationBulletIds: null == publicationBulletIds ? _self._publicationBulletIds : publicationBulletIds // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,hiddenSections: null == hiddenSections ? _self._hiddenSections : hiddenSections // ignore: cast_nullable_to_non_nullable
as Set<CvSectionType>,sectionOrder: null == sectionOrder ? _self._sectionOrder : sectionOrder // ignore: cast_nullable_to_non_nullable
as List<CvSectionType>,tailoredSummary: freezed == tailoredSummary ? _self.tailoredSummary : tailoredSummary // ignore: cast_nullable_to_non_nullable
as String?,bulletOverrides: null == bulletOverrides ? _self._bulletOverrides : bulletOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,headlineOverride: freezed == headlineOverride ? _self.headlineOverride : headlineOverride // ignore: cast_nullable_to_non_nullable
as String?,hideHeadline: null == hideHeadline ? _self.hideHeadline : hideHeadline // ignore: cast_nullable_to_non_nullable
as bool,referencesOverride: freezed == referencesOverride ? _self.referencesOverride : referencesOverride // ignore: cast_nullable_to_non_nullable
as String?,educationDetailsOverrides: null == educationDetailsOverrides ? _self._educationDetailsOverrides : educationDetailsOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,roleOverrides: null == roleOverrides ? _self._roleOverrides : roleOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,projectTitleOverrides: null == projectTitleOverrides ? _self._projectTitleOverrides : projectTitleOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillLabelOverrides: null == skillLabelOverrides ? _self._skillLabelOverrides : skillLabelOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,skillCategoryNameOverrides: null == skillCategoryNameOverrides ? _self._skillCategoryNameOverrides : skillCategoryNameOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hobbyOverrides: null == hobbyOverrides ? _self._hobbyOverrides : hobbyOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationQualificationOverrides: null == educationQualificationOverrides ? _self._educationQualificationOverrides : educationQualificationOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,educationGradeOverrides: null == educationGradeOverrides ? _self._educationGradeOverrides : educationGradeOverrides // ignore: cast_nullable_to_non_nullable
as Map<String, String>,translatedTo: freezed == translatedTo ? _self.translatedTo : translatedTo // ignore: cast_nullable_to_non_nullable
as DocumentLanguage?,targetJobDescription: freezed == targetJobDescription ? _self.targetJobDescription : targetJobDescription // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
