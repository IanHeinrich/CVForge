// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvDraft _$CvDraftFromJson(Map<String, dynamic> json) => _CvDraft(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  id: json['id'] as String,
  name: json['name'] as String,
  templateId: json['templateId'] as String,
  experienceIds:
      (json['experienceIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  bulletIds:
      (json['bulletIds'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const <String, List<String>>{},
  projectIds:
      (json['projectIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  projectBulletIds:
      (json['projectBulletIds'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const <String, List<String>>{},
  skillIds:
      (json['skillIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  educationIds:
      (json['educationIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  hobbyIds:
      (json['hobbyIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  hiddenSections:
      (json['hiddenSections'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toSet() ??
      const <CvSectionType>{},
  tailoredSummary: json['tailoredSummary'] as String?,
  bulletOverrides:
      (json['bulletOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CvDraftToJson(_CvDraft instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'id': instance.id,
  'name': instance.name,
  'templateId': instance.templateId,
  'experienceIds': instance.experienceIds,
  'bulletIds': instance.bulletIds,
  'projectIds': instance.projectIds,
  'projectBulletIds': instance.projectBulletIds,
  'skillIds': instance.skillIds,
  'educationIds': instance.educationIds,
  'hobbyIds': instance.hobbyIds,
  'hiddenSections': instance.hiddenSections
      .map((e) => _$CvSectionTypeEnumMap[e]!)
      .toList(),
  'tailoredSummary': instance.tailoredSummary,
  'bulletOverrides': instance.bulletOverrides,
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$CvSectionTypeEnumMap = {
  CvSectionType.summary: 'summary',
  CvSectionType.skills: 'skills',
  CvSectionType.experience: 'experience',
  CvSectionType.projects: 'projects',
  CvSectionType.education: 'education',
  CvSectionType.hobbies: 'hobbies',
  CvSectionType.references: 'references',
};
