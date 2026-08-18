// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SkillCategory _$SkillCategoryFromJson(Map<String, dynamic> json) =>
    _SkillCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      skills:
          (json['skills'] as List<dynamic>?)
              ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Skill>[],
    );

Map<String, dynamic> _$SkillCategoryToJson(_SkillCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skills': instance.skills.map((e) => e.toJson()).toList(),
    };
