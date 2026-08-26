// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_basics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactBasics _$ContactBasicsFromJson(Map<String, dynamic> json) =>
    _ContactBasics(
      fullName: json['fullName'] as String,
      headline: json['headline'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      location: json['location'] as String,
      summary: json['summary'] as String?,
      workAuthorization: json['workAuthorization'] as String?,
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => ProfileLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ProfileLink>[],
      photo: json['photo'] == null
          ? null
          : CvPhoto.fromJson(json['photo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ContactBasicsToJson(_ContactBasics instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'headline': instance.headline,
      'email': instance.email,
      'phone': instance.phone,
      'location': instance.location,
      'summary': instance.summary,
      'workAuthorization': instance.workAuthorization,
      'links': instance.links.map((e) => e.toJson()).toList(),
      'photo': instance.photo?.toJson(),
    };
