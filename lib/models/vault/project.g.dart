// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Project _$ProjectFromJson(Map<String, dynamic> json) => _Project(
  id: json['id'] as String,
  title: json['title'] as String,
  link: json['link'] as String?,
  bullets:
      (json['bullets'] as List<dynamic>?)
          ?.map((e) => CvBullet.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CvBullet>[],
);

Map<String, dynamic> _$ProjectToJson(_Project instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'link': instance.link,
  'bullets': instance.bullets.map((e) => e.toJson()).toList(),
};
