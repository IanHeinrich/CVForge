import 'package:freezed_annotation/freezed_annotation.dart';

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

  /// "MM/YYYY", matching the original reference CV's date format.
  String toMmYyyy() => '${month.toString().padLeft(2, '0')}/$year';

  /// "Mon YYYY" (e.g. "Aug 2022"), matching every template's date format —
  /// a consistent 3-letter month abbreviation throughout.
  String toMonYyyy() => '${_monthNames[month - 1]} $year';
}

const _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
