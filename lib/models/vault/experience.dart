import 'package:freezed_annotation/freezed_annotation.dart';

import 'experience_bullet.dart';
import 'year_month.dart';

part 'experience.freezed.dart';
part 'experience.g.dart';

@freezed
abstract class Experience with _$Experience {
  const factory Experience({
    required String id,
    required String role,
    required String company,
    required String location,
    required YearMonth start,
    YearMonth? end,
    @Default(false) bool isCurrent,
    @Default(<ExperienceBullet>[]) List<ExperienceBullet> bullets,
  }) = _Experience;

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);
}
