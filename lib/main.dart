import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/drive_sync_service.dart';
import 'package:cv_forge/services/google_auth_service.dart';
import 'package:cv_forge/services/google_auth_service_web.dart';
import 'package:cv_forge/services/pdf_extraction_service.dart';
import 'package:cv_forge/services/pdf_extraction_service_web.dart';
import 'package:cv_forge/services/settings_service.dart';
import 'package:cv_forge/services/vault_service.dart';
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
  // Resumes a previously-connected Drive sync session (if any) and arms
  // autosave for the whole app session, regardless of which route the
  // user lands on first — see DriveSyncService.start's doc comment for
  // why this can't wait for StartupView. Not awaited: a no-op when never
  // connected, and otherwise best-effort — the first paint shouldn't
  // block on a network round trip to Drive.
  unawaited(locator<DriveSyncService>().start());
  // Awaited, unlike the Drive resume above, because the very first frame
  // depends on it: `SettingsService.settings` reports the default theme
  // until this resolves, so a user who chose Light would see a dark frame
  // and a flip. `unawaited` would only narrow that window, not close it.
  //
  // Swallowing the failure is safe rather than lazy — `PersistedStoreMixin.
  // ready` resets its memoized future when the load throws, so
  // `SettingsViewModel`'s own load re-attempts and surfaces the problem as
  // `StorageUnavailableCard`. What is lost by losing here is the theme
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
/// [AppLifecycleState.hidden] — the tab being backgrounded, minimized, or
/// closed. On web that's the only reliable signal a debounced write is
/// about to be cut short, so it's the trigger for flushing both services
/// immediately rather than waiting on their normal timers.
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      // Scoped to `MaterialApp.router` rather than a `setState` on this
      // State, so a theme change rebuilds the app's themed subtree without
      // touching the `.animate().fadeIn()` wrapper below.
      builder: (_) => ListenableBuilder(
        listenable: _settingsService,
        builder: (_, _) => MaterialApp.router(
          title: ksAppTitle,
          debugShowCheckedModeBanner: false,
          // `theme` is Flutter's *light* slot. Both are always supplied and
          // `themeMode` is always explicit: with a non-null `darkTheme`,
          // omitting `themeMode` silently defaults to `ThemeMode.system`,
          // which would make light the default on a light-OS machine.
          // `MaterialApp` resolves `system` against the platform brightness
          // itself and rebuilds when the OS flips, so nothing here needs to
          // watch it.
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
