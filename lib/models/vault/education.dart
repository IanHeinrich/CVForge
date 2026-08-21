import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_bullet.dart';

part 'education.freezed.dart';
part 'education.g.dart';

/// A single qualification. Year-only precision (not [YearMonth]) — the
/// reference CV shows only a graduation year ("Computing Science, 2021").
@freezed
abstract class Education with _$Education {
  const factory Education({
    required String id,
    required String qualification,
    required String institution,
    String? location,
    int? year,
    String? grade,
    String? details,
    @Default(<CvBullet>[]) List<CvBullet> bullets,
  }) = _Education;

  factory Education.fromJson(Map<String, dynamic> json) =>
      _$EducationFromJson(json);
}
