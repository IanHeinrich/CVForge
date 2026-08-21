import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_bullet.dart';

part 'publication.freezed.dart';
part 'publication.g.dart';

/// A published work — a paper, article, or report. [link] is kept as its
/// own field, never folded into [citation], so a long DOI/URL can be
/// rendered (or omitted) independently of the citation text, and so the
/// Vault editor never asks a user to hand-splice a URL into a prose blob.
@freezed
abstract class Publication with _$Publication {
  const factory Publication({
    required String id,
    required String title,

    /// Author/venue/year detail, e.g. "Trujillo, L. (2021). AUC
    /// Interpretationes, 11(2), 194–206." Free text, optional — a
    /// publication with just a title is still valid.
    String? citation,
    String? link,

    /// Same role as [Project.bullets] — supporting detail a candidate
    /// might want to surface under a publication (e.g. "Cited by 40+
    /// subsequent papers", "Led the fieldwork component"), selected and
    /// reordered per-draft exactly like project bullets are.
    @Default(<CvBullet>[]) List<CvBullet> bullets,
  }) = _Publication;

  factory Publication.fromJson(Map<String, dynamic> json) =>
      _$PublicationFromJson(json);
}
