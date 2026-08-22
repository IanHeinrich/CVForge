import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_section_type.dart';
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

    /// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
    /// draft with, set via the "Save as my default" action in Studio.
    /// Null means no default has ever been saved — a new draft then falls
    /// back to its chosen template's own `CvTemplate.sectionOrder`. Never
    /// re-resolved against an existing draft; it only ever seeds a draft
    /// at creation time. Saved and reset together with
    /// [defaultHiddenSections] by the same Studio action, so the two
    /// fields never drift apart from each other, but kept as two fields
    /// rather than one combined value — same shape as `CvDraft.sectionOrder`
    /// / `CvDraft.hiddenSections` being separate fields there too.
    List<CvSectionType>? defaultSectionOrder,

    /// Same seed-only rationale as [defaultSectionOrder], one field over
    /// for `CvDraft.hiddenSections` — which sections a brand-new draft
    /// starts with hidden. Null means no default has been saved, so a new
    /// draft starts with nothing hidden (`CvDraft.hiddenSections`'s own
    /// default).
    Set<CvSectionType>? defaultHiddenSections,

    /// When `BackupService.exportBackup` last completed, set by
    /// `SettingsViewModel.exportBackup` — null means never. Never included
    /// in a backup bundle by construction (see this class's own doc
    /// comment on why `CvBackupBundle` has no `AppSettings` field at all),
    /// so there is no stale-timestamp-on-restore case to guard against.
    DateTime? lastBackupAt,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  factory AppSettings.empty() =>
      const AppSettings(schemaVersion: 1, defaultRegion: RegionProfile.uk);
}
