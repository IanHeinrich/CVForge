import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/models/vault/language_proficiency.dart';

/// The app's own name for each CEFR band, for the Vault's picker.
///
/// Lives here rather than on the enum because `AppLocalizations` imports
/// Flutter and `lib/models/` must not — the same reason every other enum
/// label extension is in this folder.
///
/// These are chrome, not document text. What a CV *prints* is the bare
/// band ("C1") in every language, plus a translated word for the native
/// band — see `CvComposer._formatProficiency`. The gloss exists only so
/// someone who does not read CEFR can pick the right one.
extension LanguageProficiencyLabel on LanguageProficiency {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    LanguageProficiency.native => l10n.vaultProficiencyNative,
    LanguageProficiency.c2 => l10n.vaultProficiencyC2,
    LanguageProficiency.c1 => l10n.vaultProficiencyC1,
    LanguageProficiency.b2 => l10n.vaultProficiencyB2,
    LanguageProficiency.b1 => l10n.vaultProficiencyB1,
    LanguageProficiency.a2 => l10n.vaultProficiencyA2,
    LanguageProficiency.a1 => l10n.vaultProficiencyA1,
  };
}
