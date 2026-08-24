import 'package:freezed_annotation/freezed_annotation.dart';

import 'cv_photo.dart';
import 'profile_link.dart';

part 'contact_basics.freezed.dart';
part 'contact_basics.g.dart';

@freezed
abstract class ContactBasics with _$ContactBasics {
  const factory ContactBasics({
    required String fullName,
    required String headline,
    required String email,
    required String phone,
    required String location,
    String? summary,
    @Default(<ProfileLink>[]) List<ProfileLink> links,

    /// Uploaded once here and pulled by whichever template renders one —
    /// never per draft. A template that declares `TemplateTag.photo` prints
    /// it; the others ignore it entirely, so switching template is how a
    /// user chooses whether a given document carries a photograph. See
    /// `RegionPhotoStance` for which markets expect one.
    CvPhoto? photo,
  }) = _ContactBasics;

  factory ContactBasics.fromJson(Map<String, dynamic> json) =>
      _$ContactBasicsFromJson(json);

  factory ContactBasics.empty() => const ContactBasics(
    fullName: '',
    headline: '',
    email: '',
    phone: '',
    location: '',
  );
}
