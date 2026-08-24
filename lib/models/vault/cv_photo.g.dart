// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CvPhoto _$CvPhotoFromJson(Map<String, dynamic> json) => _CvPhoto(
  jpegBase64: json['jpegBase64'] as String,
  widthPx: (json['widthPx'] as num).toInt(),
  heightPx: (json['heightPx'] as num).toInt(),
);

Map<String, dynamic> _$CvPhotoToJson(_CvPhoto instance) => <String, dynamic>{
  'jpegBase64': instance.jpegBase64,
  'widthPx': instance.widthPx,
  'heightPx': instance.heightPx,
};
