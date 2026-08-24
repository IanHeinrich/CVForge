// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_backup_bundle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvBackupBundle _$CvBackupBundleFromJson(Map<String, dynamic> json) =>
    _CvBackupBundle(
      app: json['app'] as String,
      bundleVersion: (json['bundleVersion'] as num).toInt(),
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      appVersion: json['appVersion'] as String,
      vault: json['vault'] == null
          ? null
          : CvVault.fromJson(json['vault'] as Map<String, dynamic>),
      drafts:
          (json['drafts'] as List<dynamic>?)
              ?.map((e) => CvDraft.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CvDraft>[],
      activeDraftId: json['activeDraftId'] as String?,
      preferences: json['preferences'] == null
          ? null
          : CvPreferences.fromJson(json['preferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CvBackupBundleToJson(_CvBackupBundle instance) =>
    <String, dynamic>{
      'app': instance.app,
      'bundleVersion': instance.bundleVersion,
      'exportedAt': instance.exportedAt.toIso8601String(),
      'appVersion': instance.appVersion,
      'vault': instance.vault?.toJson(),
      'drafts': instance.drafts.map((e) => e.toJson()).toList(),
      'activeDraftId': instance.activeDraftId,
      'preferences': instance.preferences?.toJson(),
    };
