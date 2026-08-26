// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_vault.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvVault _$CvVaultFromJson(Map<String, dynamic> json) => _CvVault(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  basics: ContactBasics.fromJson(json['basics'] as Map<String, dynamic>),
  experiences:
      (json['experiences'] as List<dynamic>?)
          ?.map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Experience>[],
  skillCategories:
      (json['skillCategories'] as List<dynamic>?)
          ?.map((e) => SkillCategory.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SkillCategory>[],
  projects:
      (json['projects'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Project>[],
  education:
      (json['education'] as List<dynamic>?)
          ?.map((e) => Education.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Education>[],
  hobbies:
      (json['hobbies'] as List<dynamic>?)
          ?.map((e) => HobbyItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <HobbyItem>[],
  languages:
      (json['languages'] as List<dynamic>?)
          ?.map((e) => LanguageItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LanguageItem>[],
  publications:
      (json['publications'] as List<dynamic>?)
          ?.map((e) => Publication.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Publication>[],
  referencesNote: json['referencesNote'] as String?,
  documentDefaults: json['documentDefaults'] == null
      ? const DocumentDefaults()
      : DocumentDefaults.fromJson(
          json['documentDefaults'] as Map<String, dynamic>,
        ),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CvVaultToJson(_CvVault instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'basics': instance.basics.toJson(),
  'experiences': instance.experiences.map((e) => e.toJson()).toList(),
  'skillCategories': instance.skillCategories.map((e) => e.toJson()).toList(),
  'projects': instance.projects.map((e) => e.toJson()).toList(),
  'education': instance.education.map((e) => e.toJson()).toList(),
  'hobbies': instance.hobbies.map((e) => e.toJson()).toList(),
  'languages': instance.languages.map((e) => e.toJson()).toList(),
  'publications': instance.publications.map((e) => e.toJson()).toList(),
  'referencesNote': instance.referencesNote,
  'documentDefaults': instance.documentDefaults.toJson(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
