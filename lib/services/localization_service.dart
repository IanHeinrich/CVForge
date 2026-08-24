import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/services/settings_service.dart';

/// Owns the app chrome's language: which locale is active, and the
/// [AppLocalizations] to read strings from.
///
/// Exists as a service rather than living on `BuildContext` because roughly a
/// tenth of this app's user-facing copy is assembled in ViewModels and
/// Services — `AtsAnalyzerService` bakes finding titles into `AtsFinding`,
/// `SettingsViewModel` owns four confirm dialogs — none of which has a
/// context. Views can still use `context.l10n`; both paths resolve to the
/// same locale because [MaterialApp] is handed [resolvedLocale] rather than
/// being left to resolve one of its own.
///
/// Only ever the *chrome's* language, never the document's — see
/// `DocumentLanguage`, which owns that axis. Nothing here may reach it,
/// and the import graph enforces that: `lib/models/document/` cannot see
/// `AppLocalizations`.
class LocalizationService with ListenableServiceMixin {
  LocalizationService() {
    _settingsService.addListener(_adoptStoredLocale);
  }

  final _settingsService = locator<SettingsService>();

  /// What the user explicitly chose. Null — the default — means "follow the
  /// browser", and is deliberately distinct from [resolvedLocale]: only an
  /// explicit choice is persisted, and only an explicit choice syncs between
  /// devices (see [CvPreferences.localeTag]).
  Locale? _selected;
  Locale? get selectedLocale => _selected;

  /// Always a concrete locale this build actually ships. Never null, never
  /// unsupported — [strings] would throw on anything else.
  late Locale _resolved = _resolve(null);
  Locale get resolvedLocale => _resolved;

  /// Cached rather than looked up per read. `lookupAppLocalizations`
  /// constructs a fresh instance every call, and this getter is read many
  /// times per frame from ViewModel getters.
  late AppLocalizations _strings = lookupAppLocalizations(_resolved);
  AppLocalizations get strings => _strings;

  static List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Adopts whatever is already in settings. Call once at startup, after
  /// `SettingsService.load()`, so the first frame paints in the right
  /// language instead of flashing the browser's and then correcting itself.
  Future<void> initialise() async {
    _adoptStoredLocale();
  }

  /// The single write path: persists *and* updates in one call, so no caller
  /// can move one without the other. Null restores "follow the browser".
  Future<void> setLocale(Locale? locale) async {
    await _settingsService.setLocaleTag(locale?.toLanguageTag());
    _apply(locale);
  }

  /// The browser's language list changed. Only meaningful while the user is
  /// following it — an explicit choice outranks the platform.
  void didChangeSystemLocales() {
    if (_selected != null) return;
    _apply(null);
  }

  /// Settings changed underneath us. `SettingsService.replacePreferences` is
  /// the path that matters: a Drive sync or a backup import can replace the
  /// stored language without ever going through [setLocale].
  void _adoptStoredLocale() {
    _apply(_parseTag(_settingsService.settings.preferences.localeTag));
  }

  void _apply(Locale? selected) {
    final resolved = _resolve(selected);
    if (_selected == selected && _resolved == resolved) return;
    _selected = selected;
    _resolved = resolved;
    _strings = lookupAppLocalizations(resolved);
    // So a bare `DateFormat.yMd()` anywhere in the app follows the same
    // locale as the strings around it, without every call site passing one.
    Intl.defaultLocale = resolved.toLanguageTag();
    notifyListeners();
  }

  /// Everything funnels through here, because `lookupAppLocalizations` does
  /// not resolve — it matches language/script/country exactly and throws a
  /// [FlutterError] on anything else. Browsers hand us `en-GB`, `fr-CA`,
  /// `zh-Hant-TW`; a UK user would crash the app on startup without this.
  ///
  /// [basicLocaleListResolution] is Flutter's own algorithm and never throws,
  /// falling back to the first supported locale — the same never-throw
  /// contract `LlmProviderRegistry.byId` holds, and for the same reason: a
  /// settings read must not be able to take the app down.
  Locale _resolve(Locale? preferred) => basicLocaleListResolution([
    ?preferred,
    ...WidgetsBinding.instance.platformDispatcher.locales,
  ], AppLocalizations.supportedLocales);

  /// A BCP-47 tag as stored by [setLocale]. Deliberately tolerant: a tag
  /// naming a language this build no longer ships still parses here and is
  /// then dropped by [_resolve], rather than throwing.
  Locale? _parseTag(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split(RegExp('[-_]'));
    return switch (parts.length) {
      1 => Locale(parts[0]),
      2 =>
        parts[1].length == 4
            ? Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1])
            : Locale(parts[0], parts[1]),
      _ => Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts[1],
        countryCode: parts[2],
      ),
    };
  }
}
