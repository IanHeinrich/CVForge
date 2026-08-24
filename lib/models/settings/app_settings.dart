import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/settings/app_theme_mode.dart';
import 'package:cv_forge/models/settings/cv_preferences.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Everything `SettingsService` persists, split by what travels.
///
/// [preferences] is the portable half — it rides in `CvBackupBundle` and
/// syncs to Drive, so the same person gets the same region and the same
/// default layout on every browser. Everything else here is deliberately
/// device-scoped; see [CvPreferences] for why each excluded field is
/// excluded.
///
/// The API key is not a field here at all. It lives in its own storage row
/// keyed per provider, so no code path that serializes settings can carry
/// a secret along by accident. There is no "remember my key" flag either:
/// a validated key is always saved to this device, the same as the Vault
/// and every CV, and `ApiKeyOrigin` reports where it actually ended up.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    required int schemaVersion,
    required CvPreferences preferences,

    /// When `BackupService.exportBackup` last completed on *this* device,
    /// set by `SettingsViewModel.exportBackup` — null means never.
    DateTime? lastBackupAt,

    /// Which chrome theme this browser renders in.
    ///
    /// Device-scoped for the same reason as [lastBackupAt]: it is a fact
    /// about *this* screen, not about the person. Syncing it would have a
    /// laptop in a bright room adopt the theme chosen on a phone at night,
    /// and [AppThemeMode.system] — the default — is by definition a
    /// property of the device it is read on.
    @Default(AppThemeMode.system) AppThemeMode themeMode,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  factory AppSettings.empty() =>
      AppSettings(schemaVersion: 1, preferences: CvPreferences.empty());
}
