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
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'defaultRegion': _$RegionProfileEnumMap[instance.defaultRegion]!,
      'copilotProviderId': instance.copilotProviderId,
      'copilotModelId': instance.copilotModelId,
      'rememberApiKey': instance.rememberApiKey,
    };

const _$RegionProfileEnumMap = {RegionProfile.uk: 'uk', RegionProfile.us: 'us'};
