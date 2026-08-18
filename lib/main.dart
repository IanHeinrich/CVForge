import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:cv_forge/app/app.bottomsheets.dart';
import 'package:cv_forge/app/app.dialogs.dart';
import 'package:cv_forge/app/app.locator.dart';
import 'package:cv_forge/app/app.router.dart';
import 'package:cv_forge/services/draft_service.dart';
import 'package:cv_forge/services/vault_service.dart';
import 'package:cv_forge/ui/common/app_strings.dart';
import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await setupLocator(stackedRouter: stackedRouter);
  setupDialogUi();
  setupBottomSheetUi();
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
