// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  defaultRegion:
      $enumDecodeNullable(_$RegionProfileEnumMap, json['defaultRegion']) ??
      RegionProfile.uk,
  copilotProviderId: json['copilotProviderId'] as String?,
  copilotModelId: json['copilotModelId'] as String?,
  rememberApiKey: json['rememberApiKey'] as bool? ?? false,
  defaultSectionOrder: (json['defaultSectionOrder'] as List<dynamic>?)
      ?.map((e) => $enumDecode(_$CvSectionTypeEnumMap, e))
      .toList(),
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'defaultRegion': _$RegionProfileEnumMap[instance.defaultRegion]!,
      'copilotProviderId': instance.copilotProviderId,
      'copilotModelId': instance.copilotModelId,
      'rememberApiKey': instance.rememberApiKey,
      'defaultSectionOrder': instance.defaultSectionOrder
          ?.map((e) => _$CvSectionTypeEnumMap[e]!)
          .toList(),
    };

const _$RegionProfileEnumMap = {RegionProfile.uk: 'uk', RegionProfile.us: 'us'};

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
