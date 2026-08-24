import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/models/document/document_language.dart';

/// What to call a document language in the picker.
///
/// Lives here rather than on [DocumentLanguage] because
/// [AppLocalizations] imports Flutter and `lib/models/` must not — the
/// enum stays put, only its label moves. Same arrangement as
/// `model_labels.dart` and `region_labels.dart`.
///
/// Every value is an **autonym** — the language's own name for itself,
/// identical in `app_en.arb` and `app_es.arb`, and never translated. That
/// is the same rule the UI language picker follows, and for the same
/// reason: someone who has landed in a language they cannot read has to
/// be able to find their way out.
extension DocumentLanguageLabel on DocumentLanguage {
  String displayLabel(AppLocalizations l10n) => switch (this) {
    DocumentLanguage.enGb => l10n.documentLanguageEnGbName,
    DocumentLanguage.enUs => l10n.documentLanguageEnUsName,
    DocumentLanguage.enAu => l10n.documentLanguageEnAuName,
    DocumentLanguage.de => l10n.documentLanguageDeName,
    DocumentLanguage.deAt => l10n.documentLanguageDeAtName,
    DocumentLanguage.fr => l10n.documentLanguageFrName,
    DocumentLanguage.frCa => l10n.documentLanguageFrCaName,
    DocumentLanguage.nl => l10n.documentLanguageNlName,
    DocumentLanguage.it => l10n.documentLanguageItName,
    DocumentLanguage.es => l10n.documentLanguageEsName,
    DocumentLanguage.es419 => l10n.documentLanguageEs419Name,
    DocumentLanguage.ptPt => l10n.documentLanguagePtPtName,
    DocumentLanguage.ptBr => l10n.documentLanguagePtBrName,
    DocumentLanguage.sv => l10n.documentLanguageSvName,
    DocumentLanguage.nb => l10n.documentLanguageNbName,
    DocumentLanguage.da => l10n.documentLanguageDaName,
    DocumentLanguage.fi => l10n.documentLanguageFiName,
  };
}
