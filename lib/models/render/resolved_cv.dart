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

    /// The Vault's [ContactBasics.workAuthorization], already resolved
    /// through the draft's override and hide flag. Null or blank prints
    /// nothing.
    ///
    /// Printed on its own line under the contact details rather than as
    /// one of them: it is a sentence the user wrote ("Right to work in the
    /// UK, no sponsorship required"), and set among the location and the
    /// email it reads as one more datum. It also cannot wrap while it is
    /// one cell of a wrapped run, so a long one ran off the page.
    String? workAuthorization,
    @Default(<ResolvedLink>[]) List<ResolvedLink> links,

    /// What this document's language calls each contact detail, for the
    /// one template that labels them. Required rather than defaulted to
    /// English: a header that can be built without deciding is how a
    /// German CV came to print "Location".
    required ResolvedContactLabels contactLabels,

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

/// The contact-block labels in the document's language, resolved from
/// `DocumentStrings` by the composer.
///
/// Carried on [ResolvedHeader] rather than looked up in the renderer
/// because a template must never see a [DocumentLanguage] — the composer
/// resolves every app-supplied word, exactly as it already does for
/// [ResolvedSection.title]. Only `photo_header` reads these; the other two
/// run their contact details together unlabelled.
@freezed
abstract class ResolvedContactLabels with _$ResolvedContactLabels {
  const factory ResolvedContactLabels({
    required String location,
    required String phone,
    required String email,

    /// Used only when a profile link carries no label of its own.
    required String link,
  }) = _ResolvedContactLabels;
}
