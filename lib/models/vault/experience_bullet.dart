import 'package:freezed_annotation/freezed_annotation.dart';

part 'experience_bullet.freezed.dart';
part 'experience_bullet.g.dart';

/// A single achievement bullet under an [Experience].
///
/// [label] is structural, not baked into [text] — the reference template
/// renders it as an italic lead-in ("Proactive Mitigation: Collaborated
/// with..."). Keeping it a separate field lets a template style it
/// distinctly and lets a future tailoring feature rewrite the body without
/// clobbering the label. Nullable because some entries are unlabelled
/// lead paragraphs.
@freezed
abstract class ExperienceBullet with _$ExperienceBullet {
  const factory ExperienceBullet({
    required String id,
    String? label,
    required String text,
  }) = _ExperienceBullet;

  factory ExperienceBullet.fromJson(Map<String, dynamic> json) =>
      _$ExperienceBulletFromJson(json);
}
