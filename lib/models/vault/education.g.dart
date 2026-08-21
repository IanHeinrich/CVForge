// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Education _$EducationFromJson(Map<String, dynamic> json) => _Education(
  id: json['id'] as String,
  qualification: json['qualification'] as String,
  institution: json['institution'] as String,
  location: json['location'] as String?,
  year: (json['year'] as num?)?.toInt(),
  grade: json['grade'] as String?,
  details: json['details'] as String?,
  bullets:
      (json['bullets'] as List<dynamic>?)
          ?.map((e) => CvBullet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvBullet>[],
);

Map<String, dynamic> _$EducationToJson(_Education instance) =>
    <String, dynamic>{
      'id': instance.id,
      'qualification': instance.qualification,
      'institution': instance.institution,
      'location': instance.location,
      'year': instance.year,
      'grade': instance.grade,
      'details': instance.details,
      'bullets': instance.bullets.map((e) => e.toJson()).toList(),
    };
