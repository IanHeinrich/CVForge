/// "today" / "yesterday" / "N days ago", falling back to an absolute
/// `DD/MM/YYYY` past a month — "47 days ago" stops being a useful unit for
/// something you may not think about for months at a time. Extracted from
/// `BackupSettingsCard`'s original private `_formatRelative` once a second
/// caller ([DriveSettingsCard]/`DriveSyncIndicator`) needed the identical
/// formatting — see this repo's "state a cross-cutting rationale once"
/// rule.
String formatRelativeTime(DateTime time) {
  final days = DateTime.now().difference(time).inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'yesterday';
  if (days < 30) return '$days days ago';
  return 'on ${time.day.toString().padLeft(2, '0')}/'
      '${time.month.toString().padLeft(2, '0')}/${time.year}';
}
