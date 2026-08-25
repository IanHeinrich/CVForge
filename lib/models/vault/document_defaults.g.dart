// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_defaults.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentDefaults _$DocumentDefaultsFromJson(Map<String, dynamic> json) =>
    _DocumentDefaults(
      region:
          $enumDecodeNullable(_$RegionProfileEnumMap, json['region']) ??
          RegionProfile.uk,
      language:
          $enumDecodeNullable(_$DocumentLanguageEnumMap, json['language']) ??
          DocumentLanguage.enGb,
      templateId: json['templateId'] as String?,
      sectionOrder: (json['sectionOrder'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toList(),
      hiddenSections: (json['hiddenSections'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toSet(),
      hideHeadline: json['hideHeadline'] as bool? ?? false,
    );

Map<String, dynamic> _$DocumentDefaultsToJson(_DocumentDefaults instance) =>
    <String, dynamic>{
      'region': _$RegionProfileEnumMap[instance.region]!,
      'language': _$DocumentLanguageEnumMap[instance.language]!,
      'templateId': instance.templateId,
      'sectionOrder': instance.sectionOrder
          ?.map((e) => _$CvSectionTypeEnumMap[e]!)
          .toList(),
      'hiddenSections': instance.hiddenSections
          ?.map((e) => _$CvSectionTypeEnumMap[e]!)
          .toList(),
      'hideHeadline': instance.hideHeadline,
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
