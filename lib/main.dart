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
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/ui/common/app_strings.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
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

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (_) => MaterialApp.router(
        title: ksAppTitle,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerDelegate: stackedRouter.delegate(),
        routeInformationParser: stackedRouter.defaultRouteParser(),
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 50),
      duration: const Duration(milliseconds: 400),
    );
  }
}
