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
  region:
      $enumDecodeNullable(_$RegionProfileEnumMap, json['region']) ??
      RegionProfile.uk,
  documentLanguage:
      $enumDecodeNullable(
        _$DocumentLanguageEnumMap,
        json['documentLanguage'],
      ) ??
      DocumentLanguage.enGb,
  notes: json['notes'] as String? ?? '',
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
  publicationIds:
      (json['publicationIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  publicationBulletIds:
      (json['publicationBulletIds'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const <String, List<String>>{},
  hiddenSections:
      (json['hiddenSections'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toSet() ??
      const <CvSectionType>{},
  sectionOrder:
      (json['sectionOrder'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toList() ??
      const <CvSectionType>[
        CvSectionType.summary,
        CvSectionType.skills,
        CvSectionType.experience,
        CvSectionType.projects,
        CvSectionType.education,
        CvSectionType.hobbies,
        CvSectionType.references,
        CvSectionType.publications,
      ],
  tailoredSummary: json['tailoredSummary'] as String?,
  bulletOverrides:
      (json['bulletOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  headlineOverride: json['headlineOverride'] as String?,
  referencesOverride: json['referencesOverride'] as String?,
  educationDetailsOverrides:
      (json['educationDetailsOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  targetJobDescription: json['targetJobDescription'] as String?,
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CvDraftToJson(_CvDraft instance) => <String, dynamic>{
  'schemaVersion': instance.schemaVersion,
  'id': instance.id,
  'name': instance.name,
  'templateId': instance.templateId,
  'region': _$RegionProfileEnumMap[instance.region]!,
  'documentLanguage': _$DocumentLanguageEnumMap[instance.documentLanguage]!,
  'notes': instance.notes,
  'experienceIds': instance.experienceIds,
  'bulletIds': instance.bulletIds,
  'projectIds': instance.projectIds,
  'projectBulletIds': instance.projectBulletIds,
  'skillIds': instance.skillIds,
  'educationIds': instance.educationIds,
  'hobbyIds': instance.hobbyIds,
  'publicationIds': instance.publicationIds,
  'publicationBulletIds': instance.publicationBulletIds,
  'hiddenSections': instance.hiddenSections
      .map((e) => _$CvSectionTypeEnumMap[e]!)
      .toList(),
  'sectionOrder': instance.sectionOrder
      .map((e) => _$CvSectionTypeEnumMap[e]!)
      .toList(),
  'tailoredSummary': instance.tailoredSummary,
  'bulletOverrides': instance.bulletOverrides,
  'headlineOverride': instance.headlineOverride,
  'referencesOverride': instance.referencesOverride,
  'educationDetailsOverrides': instance.educationDetailsOverrides,
  'targetJobDescription': instance.targetJobDescription,
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$RegionProfileEnumMap = {
  RegionProfile.uk: 'uk',
  RegionProfile.us: 'us',
  RegionProfile.anz: 'anz',
  RegionProfile.dach: 'dach',
  RegionProfile.nordics: 'nordics',
  RegionProfile.europe: 'europe',
  RegionProfile.latamLetter: 'latamLetter',
  RegionProfile.latamA4: 'latamA4',
};

const _$DocumentLanguageEnumMap = {
  DocumentLanguage.enGb: 'enGb',
  DocumentLanguage.enUs: 'enUs',
  DocumentLanguage.enAu: 'enAu',
  DocumentLanguage.de: 'de',
  DocumentLanguage.deAt: 'deAt',
  DocumentLanguage.fr: 'fr',
  DocumentLanguage.frCa: 'frCa',
  DocumentLanguage.nl: 'nl',
  DocumentLanguage.it: 'it',
  DocumentLanguage.es: 'es',
  DocumentLanguage.es419: 'es419',
  DocumentLanguage.ptPt: 'ptPt',
  DocumentLanguage.ptBr: 'ptBr',
  DocumentLanguage.sv: 'sv',
  DocumentLanguage.nb: 'nb',
  DocumentLanguage.da: 'da',
  DocumentLanguage.fi: 'fi',
};

const _$CvSectionTypeEnumMap = {
  CvSectionType.summary: 'summary',
  CvSectionType.skills: 'skills',
  CvSectionType.experience: 'experience',
  CvSectionType.projects: 'projects',
  CvSectionType.education: 'education',
  CvSectionType.hobbies: 'hobbies',
  CvSectionType.references: 'references',
  CvSectionType.publications: 'publications',
};
