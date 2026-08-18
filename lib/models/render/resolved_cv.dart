import 'package:freezed_annotation/freezed_annotation.dart';

import 'resolved_section.dart';

part 'resolved_cv.freezed.dart';

/// The output of [CvComposer.compose] — pure data containing ONLY what
/// will be printed, already filtered, ordered, and date-formatted. Never
/// persisted (hence no fromJson/toJson), so it carries no [schemaVersion].
///
/// Templates see only this, never [CvVault] or [CvDraft] directly — the
/// join/filter/order logic lives in exactly one place (the composer), so
/// the screen and PDF render trees cannot drift on *content*, only pixels.
@freezed
abstract class ResolvedCv with _$ResolvedCv {
  const factory ResolvedCv({
    required ResolvedHeader header,
    required List<ResolvedSection> sections,
  }) = _ResolvedCv;
}

@freezed
abstract class ResolvedHeader with _$ResolvedHeader {
  const factory ResolvedHeader({
    required String fullName,
    required String headline,
    required String email,
    required String phone,
    required String location,
    @Default(<ResolvedLink>[]) List<ResolvedLink> links,
  }) = _ResolvedHeader;
}

@freezed
abstract class ResolvedLink with _$ResolvedLink {
  const factory ResolvedLink({required String label, required String url}) =
      _ResolvedLink;
}
