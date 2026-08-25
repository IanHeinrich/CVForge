import 'package:freezed_annotation/freezed_annotation.dart';

import 'language_proficiency.dart';

part 'language_item.freezed.dart';
part 'language_item.g.dart';

/// One language the person speaks, and how well.
///
/// **Not one of the app's three language axes.** Those are the UI locale,
/// the document's own `DocumentLanguage`, and the region — see
/// `DocumentLanguage`'s doc comment, which is where that distinction is
/// stated. This is a fourth thing and the only one that is *content*: a
/// fact about the person, printed in a section of their CV, entered by
/// hand like a skill or a hobby. A CV written in English can perfectly
/// well list German at C1.
///
/// [name] is free text rather than a picked locale for that reason. It is
/// printed verbatim, so it has to be written in whatever language the
/// document is — "German" on an English CV, "Deutsch" on a German one —
/// and a locale list would either force one spelling or need a
/// seventeen-language name table for something the user can simply type.
@freezed
abstract class LanguageItem with _$LanguageItem {
  const factory LanguageItem({
    required String id,
    required String name,

    /// Null prints the language on its own, with no level beside it —
    /// which is what someone listing a language they don't want to grade
    /// actually wants.
    LanguageProficiency? proficiency,
  }) = _LanguageItem;

  factory LanguageItem.fromJson(Map<String, dynamic> json) =>
      _$LanguageItemFromJson(json);
}
