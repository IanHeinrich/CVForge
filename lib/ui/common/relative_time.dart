import 'package:cv_forge/l10n/generated/app_localizations.dart';

/// "today" / "yesterday" / "N days ago", falling back to an absolute date
/// past a month — "47 days ago" stops being a useful unit for something you
/// may not think about for months at a time. Extracted from
/// `BackupSettingsCard`'s original private `_formatRelative` once a second
/// caller ([DriveSettingsCard]/`DriveSyncIndicator`) needed the identical
/// formatting — see this repo's "state a cross-cutting rationale once" rule.
///
/// Takes [l10n] rather than reading the locator, so it stays a pure function
/// of its inputs and every caller makes the dependency visible.
String formatRelativeTime(AppLocalizations l10n, DateTime time) {
  final days = DateTime.now().difference(time).inDays;
  if (days <= 0) return l10n.commonRelativeToday;
  if (days == 1) return l10n.commonRelativeYesterday;
  if (days < 30) return l10n.commonRelativeDaysAgo(days);
  return l10n.commonRelativeOnDate(time);
}
