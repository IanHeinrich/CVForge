import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:cv_forge/models/draft/cv_section_type.dart';
import 'package:cv_forge/models/region/region_profile.dart';

part 'cv_preferences.freezed.dart';
part 'cv_preferences.g.dart';

/// The slice of [AppSettings] that follows the user between devices.
///
/// Split out as its own type rather than syncing [AppSettings] wholesale,
/// because that guarantee needs to be structural. A secret must not be
/// reachable from anything that crosses the network, and "we remembered
/// not to add one" is a weaker promise than "this type has five fields and
/// none of them is a credential". `CvBackupBundle` carries this, never
/// [AppSettings], so a future field added there cannot start travelling by
/// accident.
///
/// Deliberately excluded, and none of these are oversights:
/// - **the API key** — a secret, and it isn't even a field on
///   [AppSettings]; it lives in its own storage row.
/// - **`lastBackupAt`** — a fact about one device ("*this* browser
///   exported recently"). Syncing it would have a second device claim a
///   download it never made.
@freezed
abstract class CvPreferences with _$CvPreferences {
  const factory CvPreferences({
    @Default(RegionProfile.uk) RegionProfile defaultRegion,
    String? aiAssistantProviderId,
    String? aiAssistantModelId,

    /// When an AI Assistant connection test first succeeded on *any*
    /// device — the one piece of AI Assistant setup that can safely travel,
    /// and the reason the key itself doesn't need to.
    ///
    /// A key is a secret, so it stays on the device that has it (see this
    /// class' exclusion list). But "you have already set this up
    /// somewhere" is not a secret, and without it a second device is
    /// indistinguishable from a brand-new user: it shows an empty box with
    /// no hint that the missing piece is a key the user already owns.
    /// Settings reads this to say so, and to prompt for the key rather
    /// than for the whole setup.
    ///
    /// Never cleared by removing a key — it records that setup happened,
    /// not that this device is currently configured. [ApiKeyOrigin] is the
    /// authority on the latter.
    DateTime? aiAssistantConfiguredAt,

    /// The section order (see `CvDraft.sectionOrder`) to seed a brand-new
    /// draft with, set via the "Save as my default" action in Studio.
    /// Null means no default has ever been saved — a new draft then falls
    /// back to its chosen template's own `CvTemplate.sectionOrder`. Never
    /// re-resolved against an existing draft; it only ever seeds a draft
    /// at creation time. Saved and reset together with
    /// [defaultHiddenSections] by the same Studio action, so the two
    /// fields never drift apart, but kept as two fields rather than one
    /// combined value — same shape as `CvDraft.sectionOrder` /
    /// `CvDraft.hiddenSections` being separate fields there too.
    List<CvSectionType>? defaultSectionOrder,

    /// Same seed-only rationale as [defaultSectionOrder], one field over
    /// for `CvDraft.hiddenSections` — which sections a brand-new draft
    /// starts with hidden. Null means no default has been saved, so a new
    /// draft starts with nothing hidden.
    Set<CvSectionType>? defaultHiddenSections,

    /// The UI language, as a BCP-47 language tag ('en', 'de', 'pt-BR').
    /// Null — the default — means "follow the browser's own locale", and is
    /// what a user who never opens the language picker keeps.
    ///
    /// That default is why this belongs here rather than in [AppSettings]:
    /// only an *explicit* choice ever travels between devices. Someone who
    /// never picks a language syncs nothing, and each browser goes on
    /// following itself. A language is a fact about the person, like
    /// [defaultRegion] — not about the device, like `lastBackupAt`.
    ///
    /// A tag rather than an enum so that adding a supported language is
    /// exactly one new `.arb` file, with nothing here to keep in lockstep.
    /// `LocalizationService` validates it on read and falls back to the
    /// platform locale if it names a language this build no longer ships.
    ///
    /// Only ever the language of the app's *chrome*. The CV itself is
    /// produced in English regardless — see `CvComposer` for why the
    /// document's language is a separate axis.
    String? localeTag,

    /// When any field above last changed — the tie-break when two devices
    /// have both edited their preferences since they last agreed. These
    /// are flat scalars with no ids to merge by, so unlike the Vault there
    /// is nothing finer to fall back on.
    required DateTime updatedAt,
  }) = _CvPreferences;

  factory CvPreferences.fromJson(Map<String, dynamic> json) =>
      _$CvPreferencesFromJson(json);

  /// Epoch-dated on purpose: a device that has never touched its
  /// preferences should always lose a tie-break to one that has.
  factory CvPreferences.empty() =>
      CvPreferences(updatedAt: DateTime.fromMillisecondsSinceEpoch(0));
}
