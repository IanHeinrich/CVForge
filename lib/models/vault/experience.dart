import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_bullet.dart';
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
    @Default(<CvBullet>[]) List<CvBullet> bullets,

    /// Shared by every [Experience] that represents a promotion within the
    /// same company — `null` means "not grouped with anything". A group of
    /// one (a group id set on only one experience) renders identically to
    /// an ungrouped entry, so nothing needs to clear this when a group
    /// shrinks back down. See `CvComposer._buildExperience` for how this
    /// becomes a single company heading with multiple role/date lines.
    String? companyGroupId,
  }) = _Experience;

  factory Experience.fromJson(Map<String, dynamic> json) =>
      _$ExperienceFromJson(json);
}
