// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LanguageItem _$LanguageItemFromJson(Map<String, dynamic> json) =>
    _LanguageItem(
      id: json['id'] as String,
      name: json['name'] as String,
      proficiency: $enumDecodeNullable(
        _$LanguageProficiencyEnumMap,
        json['proficiency'],
      ),
    );

Map<String, dynamic> _$LanguageItemToJson(_LanguageItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'proficiency': _$LanguageProficiencyEnumMap[instance.proficiency],
    };

const _$LanguageProficiencyEnumMap = {
  LanguageProficiency.native: 'native',
  LanguageProficiency.c2: 'c2',
  LanguageProficiency.c1: 'c1',
  LanguageProficiency.b2: 'b2',
  LanguageProficiency.b1: 'b1',
  LanguageProficiency.a2: 'a2',
  LanguageProficiency.a1: 'a1',
};
