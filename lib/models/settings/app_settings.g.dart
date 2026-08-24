// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  preferences: CvPreferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
  rememberApiKey: json['rememberApiKey'] as bool? ?? false,
  lastBackupAt: json['lastBackupAt'] == null
      ? null
      : DateTime.parse(json['lastBackupAt'] as String),
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'preferences': instance.preferences.toJson(),
      'rememberApiKey': instance.rememberApiKey,
      'lastBackupAt': instance.lastBackupAt?.toIso8601String(),
    };
