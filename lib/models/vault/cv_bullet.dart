import 'package:freezed_annotation/freezed_annotation.dart';

part 'cv_bullet.freezed.dart';
part 'cv_bullet.g.dart';

/// A single achievement bullet — under an [Experience] or a [Project];
/// both entity types render bullets identically, so they share this one
/// type rather than each having their own near-identical model.
///
/// [label] is structural, not baked into [text] — a template can render
/// it as a bold lead-in ("STAR: Led..."). Keeping it a separate field lets
/// a template style it distinctly and lets a future tailoring feature
/// rewrite the body without clobbering the label. Nullable because not
/// every bullet has one.
@freezed
abstract class CvBullet with _$CvBullet {
  const factory CvBullet({
    required String id,
    String? label,
    required String text,
  }) = _CvBullet;

  factory CvBullet.fromJson(Map<String, dynamic> json) =>
      _$CvBulletFromJson(json);
}
