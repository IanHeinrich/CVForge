import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
import 'package:cv_forge/services/google_auth_service.dart';
import 'package:cv_forge/services/google_auth_service_web.dart';
import 'package:cv_forge/services/localization_service.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/services/pdf_extraction_service_web.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/l10n/generated/app_localizations.dart';
import 'package:cv_forge/ui/common/app_strings.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await setupLocator(stackedRouter: stackedRouter);
  // Registered by hand rather than through app.dart's @StackedApp list —
  // see PdfExtractionService's doc comment. main.dart is never imported by
  // a test, so it is the only safe entry point for package:web.
  locator.registerLazySingleton<PdfExtractionService>(
    PdfExtractionServiceWeb.new,
  );
  // Same reasoning as PdfExtractionService above: GoogleAuthServiceWeb
  // reaches dart:js_interop, which doesn't compile under the Dart VM.
  locator.registerLazySingleton<GoogleAuthService>(GoogleAuthServiceWeb.new);
  setupDialogUi();
  // Both DateFormat and gen-l10n's own DateTime placeholders throw for any
  // locale whose date symbols haven't been loaded, so this has to happen
  // before the first frame regardless of which locale wins below.
  await initializeDateFormatting();
  // Awaited — one local IndexedDB row, against painting the first frame in
  // the browser's language and then visibly correcting it.
  //
  // Guarded because ready() rethrows, and IndexedDB really can be
  // unavailable (Firefox strict privacy mode): an uncaught throw here
  // means runApp is never reached, a white screen for exactly those users.
  // They fall back to the browser's language and see the existing
  // storage-unavailable banner.
  try {
    await locator<SettingsService>().load();
  } catch (_) {}
  await locator<LocalizationService>().initialise();
  // Arms autosave for the whole session whatever route the user lands on
  // — see DriveSyncService.start for why this can't wait for StartupView.
  // Not awaited: the first paint shouldn't block on a Drive round trip.
  unawaited(locator<DriveSyncService>().start());
  // Awaited because the first frame depends on it: `settings` reports the
  // default theme until this resolves, so a user who chose Light sees a
  // dark frame and a flip. `unawaited` would narrow that, not close it.
  //
  // Swallowing the failure is safe: `PersistedStoreMixin.ready` resets its
  // memoized future on throw, so `SettingsViewModel` re-attempts and
  // surfaces `StorageUnavailableCard`. All that is lost here is the theme
  // reverting to its default, and this is a read, so the project's
  // never-fire-and-forget-a-write rule doesn't apply.
  try {
    await locator<SettingsService>().load();
  } catch (_) {}
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

/// A [WidgetsBindingObserver] so [didChangeAppLifecycleState] fires on
/// [AppLifecycleState.hidden]. On web that is the only reliable signal a
/// debounced write is about to be cut short, so it flushes both services
/// rather than waiting on their timers.
class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  final _settingsService = locator<SettingsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.hidden) return;
    unawaited(locator<VaultService>().flushPendingWrites());
    unawaited(locator<DraftService>().flushPendingWrites());
    unawaited(locator<DriveSyncService>().flushPendingWrites());
  }

  /// The browser's language list changed. Only moves anything for a user
  /// who hasn't picked a language explicitly — see
  /// [LocalizationService.didChangeSystemLocales].
  @override
  void didChangeLocales(List<Locale>? locales) {
    locator<LocalizationService>().didChangeSystemLocales();
  }

  @override
  Widget build(BuildContext context) {
    final localization = locator<LocalizationService>();
    return ResponsiveApp(
      // Inside ResponsiveApp's builder, so a locale or theme change
      // rebuilds MaterialApp without replaying the `.animate().fadeIn()`
      // wrapper below. Merged rather than nested: the two are independent
      // triggers for the same rebuild, and neither outranks the other.
      builder: (_) => ListenableBuilder(
        listenable: Listenable.merge([localization, _settingsService]),
        builder: (_, _) => MaterialApp.router(
          // `ksAppTitle` is a brand name, so it isn't localized.
          title: ksAppTitle,
          // A concrete locale, never null: it stops MaterialApp running its
          // own resolution, which could otherwise disagree with the locale
          // ViewModels read strings from.
          locale: localization.resolvedLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          // `theme` is Flutter's *light* slot. `themeMode` is always
          // explicit: with a non-null `darkTheme`, omitting it silently
          // defaults to `ThemeMode.system`. `MaterialApp` resolves `system`
          // against platform brightness itself, so nothing here watches it.
          theme: buildAppTheme(brightness: Brightness.light),
          darkTheme: buildAppTheme(),
          themeMode: _settingsService.settings.themeMode.materialThemeMode,
          routerDelegate: stackedRouter.delegate(),
          routeInformationParser: stackedRouter.defaultRouteParser(),
        ),
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 50),
      duration: const Duration(milliseconds: 400),
    );
  }
}
