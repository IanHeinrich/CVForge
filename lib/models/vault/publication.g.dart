// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Publication _$PublicationFromJson(Map<String, dynamic> json) => _Publication(
  id: json['id'] as String,
  title: json['title'] as String,
  citation: json['citation'] as String?,
  link: json['link'] as String?,
);

Map<String, dynamic> _$PublicationToJson(_Publication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'citation': instance.citation,
      'link': instance.link,
    };
