import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_bullet.dart';

part 'project.freezed.dart';
part 'project.g.dart';

/// A side/portfolio project — distinct from [Experience] because it isn't
/// tied to an employer or a date range, just a title, an optional link
/// (a demo, a repo, a write-up), and achievement bullets.
@freezed
abstract class Project with _$Project {
  const factory Project({
    required String id,
    required String title,
    String? link,
    @Default(<CvBullet>[]) List<CvBullet> bullets,
  }) = _Project;

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);
}
