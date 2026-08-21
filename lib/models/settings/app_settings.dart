import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/render/region_profile.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Device-scoped preferences — persisted separately from career data (see
/// `CvBackupBundle`'s doc comment for why settings are never part of a
/// backup). [copilotProviderId]/[copilotModelId]/[rememberApiKey] were
/// added ahead of their first writer, the same bet `CvDraft` made on
/// `bulletOverrides` well before Phase 2 built its UI — `SettingsService`
/// gained its first mutators for them in 4.4. The API key itself is
/// deliberately never a field here — it lives in its own storage row,
/// keyed per provider, so no code path that ever serializes [AppSettings]
/// can carry a secret along by accident.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    required int schemaVersion,
    @Default(RegionProfile.uk) RegionProfile defaultRegion,
    String? copilotProviderId,
    String? copilotModelId,
    @Default(false) bool rememberApiKey,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  factory AppSettings.empty() =>
      const AppSettings(schemaVersion: 1, defaultRegion: RegionProfile.uk);
}
