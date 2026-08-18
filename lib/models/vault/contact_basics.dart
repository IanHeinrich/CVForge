import 'package:freezed_annotation/freezed_annotation.dart';

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
