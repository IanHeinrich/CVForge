import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/document/document_strings.dart';

part 'year_month.freezed.dart';
part 'year_month.g.dart';

/// Month-precision point in time. CVs never need day precision, and using
/// [DateTime] would drag in timezone/serialization noise plus a false
/// precision the UI would have to hide.
@freezed
abstract class YearMonth with _$YearMonth {
  const YearMonth._();

  @Assert('month >= 1 && month <= 12', 'month must be between 1 and 12')
  const factory YearMonth({required int year, required int month}) = _YearMonth;

  factory YearMonth.fromJson(Map<String, dynamic> json) =>
      _$YearMonthFromJson(json);

  /// "Mon YYYY" (e.g. "Aug 2022"), in [language] — matching every
  /// template's date format.
  ///
  /// [language] is required rather than defaulted on purpose. Exactly one
  /// caller must always pass English no matter what the document says —
  /// `AiAssistantVaultPayload`, because prompt text is English by policy —
  /// and a default would let that one start quietly following the draft
  /// the first time someone tidied up the call site.
  String toMonYyyy(DocumentLanguage language) =>
      '${monthName(language, month)} $year';
}

/// [monthNumber]'s abbreviation in [language] (1 = January … 12 =
/// December).
///
/// This used to promise that a Vault month picker and the printed date
/// could never disagree, by being the single owner of both. That promise
/// is gone, and could not be kept: once a CV carries its own language, a
/// Vault with an English default and a draft written in Spanish disagree
/// by construction, and no choice of picker language fixes it across
/// several drafts at once.
///
/// What replaced it is better. The picker stores a month *number* and
/// never a name, so its labels were only ever chrome — they now come from
/// the app's own translations like every other label in the Vault, and
/// this function has exactly one consumer left: the document.
String monthName(DocumentLanguage language, int monthNumber) =>
    language.strings.months[monthNumber - 1];
