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
  // Registered here, not through app.dart's @StackedApp dependencies list
  // like every other service — see PdfExtractionService's doc comment for
  // why importing package:web there would break the whole VM-run test
  // suite. main.dart is never imported by a test, so this is the only
  // place package:web can safely enter the compilation graph.
  locator.registerLazySingleton<PdfExtractionService>(
    PdfExtractionServiceWeb.new,
  );
  // Same reasoning and the same manual-registration mechanism as
  // PdfExtractionService above: GoogleAuthServiceWeb imports
  // dart:js_interop (via gis_bindings.dart), which doesn't compile under
  // the Dart VM, so it can't go through app.dart's normal
  // @StackedApp(dependencies: [...]) list.
  locator.registerLazySingleton<GoogleAuthService>(GoogleAuthServiceWeb.new);
  setupDialogUi();
  // Both DateFormat and gen-l10n's own DateTime placeholders throw for any
  // locale whose date symbols haven't been loaded, so this has to happen
  // before the first frame regardless of which locale wins below.
  await initializeDateFormatting();
  // Awaited, unlike DriveSyncService below, because the alternative is
  // painting the first frame in the browser's language and then visibly
  // correcting it. This is one local IndexedDB row, not a network round trip.
  //
  // Guarded because ready() rethrows: LocalStorageService documents IndexedDB
  // being genuinely unavailable (Firefox strict privacy mode), and an
  // uncaught throw here would mean runApp is never reached — a white screen
  // for exactly those users. They fall back to the browser's language, and
  // the existing storage-unavailable banner is what tells them why.
  try {
    await locator<SettingsService>().load();
  } catch (_) {}
  await locator<LocalizationService>().initialise();
  // Resumes a previously-connected Drive sync session (if any) and arms
  // autosave for the whole app session, regardless of which route the
  // user lands on first — see DriveSyncService.start's doc comment for
  // why this can't wait for StartupView. Not awaited: a no-op when never
  // connected, and otherwise best-effort — the first paint shouldn't
  // block on a network round trip to Drive.
  unawaited(locator<DriveSyncService>().start());
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

/// A [WidgetsBindingObserver] so [didChangeAppLifecycleState] fires on
/// [AppLifecycleState.hidden] — the tab being backgrounded, minimized, or
/// closed. On web that's the only reliable signal a debounced write is
/// about to be cut short, so it's the trigger for flushing both services
/// immediately rather than waiting on their normal timers.
class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
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
      // Inside ResponsiveApp's builder, so changing language rebuilds
      // MaterialApp without replaying the fade-in below.
      builder: (_) => ListenableBuilder(
        listenable: localization,
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
          theme: buildAppTheme(),
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
