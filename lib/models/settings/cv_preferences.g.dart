// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvPreferences _$CvPreferencesFromJson(Map<String, dynamic> json) =>
    _CvPreferences(
      aiAssistantProviderId: json['aiAssistantProviderId'] as String?,
      aiAssistantModelId: json['aiAssistantModelId'] as String?,
      aiAssistantConfiguredAt: json['aiAssistantConfiguredAt'] == null
          ? null
          : DateTime.parse(json['aiAssistantConfiguredAt'] as String),
      localeTag: json['localeTag'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CvPreferencesToJson(_CvPreferences instance) =>
    <String, dynamic>{
      'aiAssistantProviderId': instance.aiAssistantProviderId,
      'aiAssistantModelId': instance.aiAssistantModelId,
      'aiAssistantConfiguredAt': instance.aiAssistantConfiguredAt
          ?.toIso8601String(),
      'localeTag': instance.localeTag,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
