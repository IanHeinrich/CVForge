/// "< 1 hour ago" / "N hours ago" / "yesterday" / "N days ago", falling
/// back to an absolute `DD/MM/YYYY` past a month — "47 days ago" stops
/// being a useful unit for something you may not think about for months at
/// a time.
///
/// Deliberately terse: these render into caption-width slots (a 200px
/// drafts card, a settings row), and the spelled-out "less than an hour
/// ago" was long enough to ellipsise on the narrowest of them.
///
/// Hour granularity below a day, because the coarser "today" this replaced
/// couldn't tell a CV edited a minute ago from one edited at breakfast —
/// and the hours after an edit are exactly the window in which "when did I
/// last touch this?" gets asked.
///
/// Extracted from `BackupSettingsCard`'s original private `_formatRelative`
/// once a second caller ([DriveSettingsCard]/`DriveSyncIndicator`) needed
/// the identical formatting — see this repo's "state a cross-cutting
/// rationale once" rule. Every caller reads the result as the tail of a
/// sentence ("Last backed up …", "Updated …"), so each branch has to be a
/// phrase that completes one.
String formatRelativeTime(DateTime time) {
  final elapsed = DateTime.now().difference(time);
  // Also catches a timestamp marginally in the future — a drifted clock,
  // or a write from another tab — which would otherwise count backwards.
  if (elapsed.inHours < 1) return '< 1 hour ago';
  if (elapsed.inHours == 1) return '1 hour ago';
  if (elapsed.inHours < 24) return '${elapsed.inHours} hours ago';
  final days = elapsed.inDays;
  if (days == 1) return 'yesterday';
  if (days < 30) return '$days days ago';
  return 'on ${time.day.toString().padLeft(2, '0')}/'
      '${time.month.toString().padLeft(2, '0')}/${time.year}';
}
