import 'package:cv_forge/ui/common/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// The surface every golden in this suite is captured at. Wide enough for
/// the desktop three-column layouts; a per-test size would make two
/// baselines incomparable at a glance.
const goldenSurfaceSize = Size(1600, 1000);

/// Pumps [view] inside the app's own theme at [goldenSurfaceSize], with
/// fonts loaded and the device pixel ratio pinned to 1.
///
/// Shared so a change to how goldens are staged — surface size, theme,
/// pixel ratio — lands on every baseline at once instead of drifting
/// between files. Baselines are generated on `ubuntu-latest` (see
/// `.github/workflows/update-goldens.yml`) and compared there again on
/// every PR by `ci.yml`'s plain `flutter test`; font rasterization differs
/// by platform, so these fail with a small pixel diff on a non-Linux dev
/// machine even with no changes at all.
Future<void> pumpGoldenScreen(WidgetTester tester, Widget view) async {
  await loadAppFonts();
  await tester.binding.setSurfaceSize(goldenSurfaceSize);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    MediaQuery(
      data: const MediaQueryData(
        size: goldenSurfaceSize,
        devicePixelRatio: 1.0,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: view,
      ),
    ),
  );
}
