import 'package:freezed_annotation/freezed_annotation.dart';

part 'cv_preferences.freezed.dart';
part 'cv_preferences.g.dart';

/// The slice of [AppSettings] that follows the user between devices.
///
/// A separate type rather than syncing [AppSettings] wholesale, so that
/// "nothing secret crosses the network" is structural: `CvBackupBundle`
/// carries this, never [AppSettings].
///
/// Excluded: the API key (a secret, in its own storage row); `lastBackupAt`
/// (a fact about one device); and anything that shapes the produced CV,
/// which lives on `CvVault.documentDefaults` instead.
@freezed
abstract class CvPreferences with _$CvPreferences {
  const factory CvPreferences({
    String? aiAssistantProviderId,
    String? aiAssistantModelId,

    /// When an AI Assistant connection test first succeeded on *any*
    /// device. Lets a second device prompt for just the key rather than
    /// the whole setup, without the key itself having to travel.
    ///
    /// Never cleared by removing a key — it records that setup happened,
    /// not that this device is configured. [ApiKeyOrigin] owns the latter.
    DateTime? aiAssistantConfiguredAt,

    /// The UI language as a BCP-47 tag; null means "follow the browser's
    /// own locale", so only an *explicit* choice ever syncs.
    ///
    /// A tag rather than an enum, so adding a language is one new `.arb`
    /// file. `LocalizationService` validates it on read and falls back to
    /// the platform locale for a language this build no longer ships.
    ///
    /// Never the language the CV is written in — that is
    /// `DocumentLanguage`, which owns the distinction.
    String? localeTag,

    /// When any field above last changed — the tie-break when two devices
    /// have both edited since they last agreed. Flat scalars with no ids,
    /// so unlike the Vault there is nothing finer to merge by.
    required DateTime updatedAt,
  }) = _CvPreferences;

  factory CvPreferences.fromJson(Map<String, dynamic> json) =>
      _$CvPreferencesFromJson(json);

  /// Epoch-dated on purpose: a device that has never touched its
  /// preferences should always lose a tie-break to one that has.
  factory CvPreferences.empty() =>
      CvPreferences(updatedAt: DateTime.fromMillisecondsSinceEpoch(0));
}
