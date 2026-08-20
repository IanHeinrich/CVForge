import 'package:freezed_annotation/freezed_annotation.dart';

part 'ats_link_annotation.freezed.dart';

/// A `mailto:`/`tel:`/`https:` Link annotation on a page — confirmed in
/// the spike to be a materially more reliable contact-info source than
/// regexing `AtsTextNode.str`, since cv-forge's own PDF export already
/// emits these for every header link.
@freezed
abstract class AtsLinkAnnotation with _$AtsLinkAnnotation {
  const factory AtsLinkAnnotation({
    required int pageIndex,
    required String url,
  }) = _AtsLinkAnnotation;
}
