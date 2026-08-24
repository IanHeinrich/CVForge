import 'package:cv_forge/l10n/generated/app_localizations.dart';

/// [month]'s abbreviation (1 = January … 12 = December) in the language the
/// **app** is being read in.
///
/// Not `YearMonth.monthName`, which answers the same question for the
/// language the **CV** is written in — the picker stores a month *number*,
/// so its labels are only ever chrome. A Spanish reader sees "sept" while
/// their German CV prints "Sept.", which is what both of them wanted.
String monthLabel(AppLocalizations l10n, int month) => switch (month) {
  1 => l10n.vaultMonthJan,
  2 => l10n.vaultMonthFeb,
  3 => l10n.vaultMonthMar,
  4 => l10n.vaultMonthApr,
  5 => l10n.vaultMonthMay,
  6 => l10n.vaultMonthJun,
  7 => l10n.vaultMonthJul,
  8 => l10n.vaultMonthAug,
  9 => l10n.vaultMonthSep,
  10 => l10n.vaultMonthOct,
  11 => l10n.vaultMonthNov,
  12 => l10n.vaultMonthDec,
  // Unreachable: every caller passes a YearMonth.month, whose own
  // assertion has already constrained it to 1-12.
  _ => throw ArgumentError.value(month, 'month', 'must be 1-12'),
};
