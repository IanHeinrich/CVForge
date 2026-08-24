// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvPreferences _$CvPreferencesFromJson(Map<String, dynamic> json) =>
    _CvPreferences(
      defaultRegion:
          $enumDecodeNullable(_$RegionProfileEnumMap, json['defaultRegion']) ??
          RegionProfile.uk,
      aiAssistantProviderId: json['aiAssistantProviderId'] as String?,
      aiAssistantModelId: json['aiAssistantModelId'] as String?,
      aiAssistantConfiguredAt: json['aiAssistantConfiguredAt'] == null
          ? null
          : DateTime.parse(json['aiAssistantConfiguredAt'] as String),
      defaultSectionOrder: (json['defaultSectionOrder'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toList(),
      defaultHiddenSections: (json['defaultHiddenSections'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
          .toSet(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CvPreferencesToJson(_CvPreferences instance) =>
    <String, dynamic>{
      'defaultRegion': _$RegionProfileEnumMap[instance.defaultRegion]!,
      'aiAssistantProviderId': instance.aiAssistantProviderId,
      'aiAssistantModelId': instance.aiAssistantModelId,
      'aiAssistantConfiguredAt': instance.aiAssistantConfiguredAt
          ?.toIso8601String(),
      'defaultSectionOrder': instance.defaultSectionOrder
          ?.map((e) => _$CvSectionTypeEnumMap[e]!)
          .toList(),
      'defaultHiddenSections': instance.defaultHiddenSections
          ?.map((e) => _$CvSectionTypeEnumMap[e]!)
          .toList(),
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
