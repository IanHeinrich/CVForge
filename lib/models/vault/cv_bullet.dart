import 'package:freezed_annotation/freezed_annotation.dart';

part 'cv_bullet.freezed.dart';
part 'cv_bullet.g.dart';

/// A single achievement bullet — under any of the four bullet-owning
/// entity types; they render bullets identically, so they share this one
/// type rather than each having their own near-identical model.
///
/// Just an id and a sentence. There used to be a separate `label` a
/// template printed as a bold lead-in ("Performance: Cut latency 40%"),
/// and it was removed rather than extended: a category tag in front of an
/// achievement spends the few words a reader actually scans on a word
/// that is neither a keyword nor an outcome. The technique that does work
/// — emphasising the outcome clause — is emphasis *within* the sentence,
/// which a separate field cannot express anyway.
@freezed
abstract class CvBullet with _$CvBullet {
  const factory CvBullet({required String id, required String text}) =
      _CvBullet;

  factory CvBullet.fromJson(Map<String, dynamic> json) =>
      _$CvBulletFromJson(json);
}
