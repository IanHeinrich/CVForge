import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_link.freezed.dart';
part 'profile_link.g.dart';

/// A single profile link, e.g. label "LinkedIn", url "linkedin.com/in/...".
@freezed
abstract class ProfileLink with _$ProfileLink {
  const factory ProfileLink({
    required String id,
    required String label,
    required String url,
  }) = _ProfileLink;

  factory ProfileLink.fromJson(Map<String, dynamic> json) =>
      _$ProfileLinkFromJson(json);
}
