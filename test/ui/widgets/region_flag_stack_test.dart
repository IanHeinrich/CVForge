import 'package:cv_forge/models/region/region_presets.dart';
import 'package:cv_forge/ui/widgets/common/region_flag_stack/region_flag_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A layout invariant with no ViewModel above it — the same carve-out
/// `ats_xray_painter_test.dart` sits in. Worth pinning because the first
/// version of this widget scaled each glyph by a hand-picked fraction of
/// the box, which overflowed: a flag emoji is a regional-indicator *pair*
/// whose advance width is wider than its font size, so no fraction chosen
/// by hand is safe across platform emoji fonts.
void main() {
  Future<void> pump(WidgetTester tester, List<String> flags, double size) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RegionFlagStack(flags: flags, size: size),
          ),
        ),
      ),
    );
  }

  group('RegionFlagStack -', () {
    // Both sizes it is actually used at: the picker/Settings mark and
    // StudioDocumentBar's icon slot.
    for (final size in [28.0, 16.0]) {
      for (var count = 1; count <= 4; count++) {
        testWidgets('lays $count flag(s) out at ${size}px without '
            'overflowing', (tester) async {
          await pump(tester, List.filled(count, '🇬🇧'), size);

          expect(tester.takeException(), isNull);
          expect(
            tester.getSize(find.byType(RegionFlagStack)),
            Size(size, size),
          );
        });
      }
    }

    testWidgets('keeps one square footprint whatever a region declares — '
        'the slots it drops into are built for a single glyph', (tester) async {
      for (final region in RegionProfile.values) {
        await pump(tester, region.preset.flags, 28);

        expect(tester.takeException(), isNull, reason: region.name);
        expect(
          tester.getSize(find.byType(RegionFlagStack)),
          const Size(28, 28),
          reason: region.name,
        );
      }
    });

    testWidgets('truncates past four rather than shrinking further, since '
        'a fifth flag would be illegible at any size used here', (
      tester,
    ) async {
      await pump(tester, const ['🇸🇪', '🇳🇴', '🇩🇰', '🇫🇮', '🇮🇸'], 28);

      expect(tester.takeException(), isNull);
      expect(find.text('🇸🇪'), findsOneWidget);
      expect(find.text('🇮🇸'), findsNothing);
    });

    testWidgets('an empty flag list still occupies its slot rather than '
        'collapsing the row around it', (tester) async {
      await pump(tester, const [], 28);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(RegionFlagStack)), const Size(28, 28));
    });
  });
}
