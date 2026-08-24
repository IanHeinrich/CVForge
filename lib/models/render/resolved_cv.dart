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

    /// The Vault photo's JPEG bytes, base64-encoded — carried as the raw
    /// scalar rather than as `CvPhoto` so this file keeps its "templates
    /// never see a Vault type" boundary, and as a `String` rather than
    /// `Uint8List` so [ResolvedHeader] keeps value equality (see
    /// [CvPhoto]'s doc comment for what depends on that).
    ///
    /// Always populated when the Vault holds a photo, whatever the draft's
    /// template — deciding whether to print it is the template's job, not
    /// the composer's.
    String? photoJpegBase64,
  }) = _ResolvedHeader;
}

@freezed
abstract class ResolvedLink with _$ResolvedLink {
  const factory ResolvedLink({required String label, required String url}) =
      _ResolvedLink;
}
