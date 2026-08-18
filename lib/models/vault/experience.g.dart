// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experience.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Experience _$ExperienceFromJson(Map<String, dynamic> json) => _Experience(
  id: json['id'] as String,
  role: json['role'] as String,
  company: json['company'] as String,
  location: json['location'] as String,
  start: YearMonth.fromJson(json['start'] as Map<String, dynamic>),
  end: json['end'] == null
      ? null
      : YearMonth.fromJson(json['end'] as Map<String, dynamic>),
  isCurrent: json['isCurrent'] as bool? ?? false,
  bullets:
      (json['bullets'] as List<dynamic>?)
          ?.map((e) => CvBullet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvBullet>[],
  companyGroupId: json['companyGroupId'] as String?,
);

Map<String, dynamic> _$ExperienceToJson(_Experience instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'company': instance.company,
      'location': instance.location,
      'start': instance.start.toJson(),
      'end': instance.end?.toJson(),
      'isCurrent': instance.isCurrent,
      'bullets': instance.bullets.map((e) => e.toJson()).toList(),
      'companyGroupId': instance.companyGroupId,
    };
