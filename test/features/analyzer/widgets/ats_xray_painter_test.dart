import 'package:cv_forge/features/analyzer/widgets/ats_xray_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rectA = (left: 0.0, top: 0.0, right: 10.0, bottom: 10.0);
  const rectB = (left: 5.0, top: 5.0, right: 20.0, bottom: 20.0);

  group('AtsXrayPainter.shouldRepaint', () {
    test('is false when the same rects list instance is reused', () {
      final rects = [rectA, rectB];

      final painter = AtsXrayPainter(rects);
      final oldPainter = AtsXrayPainter(rects);

      expect(painter.shouldRepaint(oldPainter), isFalse);
    });

    test('is true when a different rects list instance is supplied — even '
        'with equal content', () {
      final painter = AtsXrayPainter([rectA]);
      final oldPainter = AtsXrayPainter([rectA]);

      expect(painter.shouldRepaint(oldPainter), isTrue);
    });
  });

  testWidgets('paints an empty or populated rect list without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: AtsXrayPainter([rectA, rectB])),
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(painter: AtsXrayPainter(const [])),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
