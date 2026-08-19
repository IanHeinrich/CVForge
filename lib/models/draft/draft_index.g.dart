// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_index.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftIndex _$DraftIndexFromJson(Map<String, dynamic> json) => _DraftIndex(
  schemaVersion: (json['schemaVersion'] as num).toInt(),
  draftIds:
      (json['draftIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  activeDraftId: json['activeDraftId'] as String?,
);

Map<String, dynamic> _$DraftIndexToJson(_DraftIndex instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'draftIds': instance.draftIds,
      'activeDraftId': instance.activeDraftId,
    };
