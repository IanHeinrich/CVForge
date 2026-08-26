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
  languageIds:
      (json['languageIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
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
  publicationTitleOverrides:
      (json['publicationTitleOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  publicationCitationOverrides:
      (json['publicationCitationOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  educationBulletIds:
      (json['educationBulletIds'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ) ??
      const <String, List<String>>{},
  omittedFields:
      (json['omittedFields'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          $enumDecode(_$DraftOmittableFieldEnumMap, k),
          (e as List<dynamic>).map((e) => e as String).toList(),
        ),
      ) ??
      const <DraftOmittableField, List<String>>{},
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
        CvSectionType.languages,
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
  hideHeadline: json['hideHeadline'] as bool? ?? false,
  referencesOverride: json['referencesOverride'] as String?,
  workAuthorizationOverride: json['workAuthorizationOverride'] as String?,
  hideWorkAuthorization: json['hideWorkAuthorization'] as bool? ?? false,
  educationDetailsOverrides:
      (json['educationDetailsOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  roleOverrides:
      (json['roleOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  projectTitleOverrides:
      (json['projectTitleOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  experienceLocationOverrides:
      (json['experienceLocationOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  educationLocationOverrides:
      (json['educationLocationOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  skillLabelOverrides:
      (json['skillLabelOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  skillCategoryNameOverrides:
      (json['skillCategoryNameOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  hobbyOverrides:
      (json['hobbyOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  languageOverrides:
      (json['languageOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  educationQualificationOverrides:
      (json['educationQualificationOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  educationGradeOverrides:
      (json['educationGradeOverrides'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  translatedTo: $enumDecodeNullable(
    _$DocumentLanguageEnumMap,
    json['translatedTo'],
  ),
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
  'languageIds': instance.languageIds,
  'publicationIds': instance.publicationIds,
  'publicationBulletIds': instance.publicationBulletIds,
  'publicationTitleOverrides': instance.publicationTitleOverrides,
  'publicationCitationOverrides': instance.publicationCitationOverrides,
  'educationBulletIds': instance.educationBulletIds,
  'omittedFields': instance.omittedFields.map(
    (k, e) => MapEntry(_$DraftOmittableFieldEnumMap[k]!, e),
  ),
  'hiddenSections': instance.hiddenSections
      .map((e) => _$CvSectionTypeEnumMap[e]!)
      .toList(),
  'sectionOrder': instance.sectionOrder
      .map((e) => _$CvSectionTypeEnumMap[e]!)
      .toList(),
  'tailoredSummary': instance.tailoredSummary,
  'bulletOverrides': instance.bulletOverrides,
  'headlineOverride': instance.headlineOverride,
  'hideHeadline': instance.hideHeadline,
  'referencesOverride': instance.referencesOverride,
  'workAuthorizationOverride': instance.workAuthorizationOverride,
  'hideWorkAuthorization': instance.hideWorkAuthorization,
  'educationDetailsOverrides': instance.educationDetailsOverrides,
  'roleOverrides': instance.roleOverrides,
  'projectTitleOverrides': instance.projectTitleOverrides,
  'experienceLocationOverrides': instance.experienceLocationOverrides,
  'educationLocationOverrides': instance.educationLocationOverrides,
  'skillLabelOverrides': instance.skillLabelOverrides,
  'skillCategoryNameOverrides': instance.skillCategoryNameOverrides,
  'hobbyOverrides': instance.hobbyOverrides,
  'languageOverrides': instance.languageOverrides,
  'educationQualificationOverrides': instance.educationQualificationOverrides,
  'educationGradeOverrides': instance.educationGradeOverrides,
  'translatedTo': _$DocumentLanguageEnumMap[instance.translatedTo],
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

const _$DraftOmittableFieldEnumMap = {
  DraftOmittableField.projectLink: 'projectLink',
  DraftOmittableField.publicationLink: 'publicationLink',
  DraftOmittableField.educationYear: 'educationYear',
};

const _$CvSectionTypeEnumMap = {
  CvSectionType.summary: 'summary',
  CvSectionType.skills: 'skills',
  CvSectionType.languages: 'languages',
  CvSectionType.experience: 'experience',
  CvSectionType.projects: 'projects',
  CvSectionType.education: 'education',
  CvSectionType.hobbies: 'hobbies',
  CvSectionType.references: 'references',
  CvSectionType.publications: 'publications',
};
