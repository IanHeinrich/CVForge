import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _Publication;

  factory Publication.fromJson(Map<String, dynamic> json) =>
      _$PublicationFromJson(json);
}
