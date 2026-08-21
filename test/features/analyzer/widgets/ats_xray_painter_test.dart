import 'package:cv_forge/features/analyzer/widgets/ats_xray_painter.dart';
import 'package:cv_forge/models/ats/ats_finding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rectA = (left: 0.0, top: 0.0, right: 10.0, bottom: 10.0);
  const rectB = (left: 5.0, top: 5.0, right: 20.0, bottom: 20.0);
  const boxA = (rect: rectA, style: AtsXrayBoxStyle.ambient, severity: null);
  const boxB = (
    rect: rectB,
    style: AtsXrayBoxStyle.evidence,
    severity: AtsFindingSeverity.critical,
  );

  group('AtsXrayPainter.shouldRepaint', () {
    test('is false when the same boxes list instance is reused', () {
      final boxes = [boxA, boxB];

      final painter = AtsXrayPainter(boxes);
      final oldPainter = AtsXrayPainter(boxes);

      expect(painter.shouldRepaint(oldPainter), isFalse);
    });

    test('is true when a different boxes list instance is supplied — even '
        'with equal content', () {
      final painter = AtsXrayPainter([boxA]);
      final oldPainter = AtsXrayPainter([boxA]);

      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    test('is true when showFlowLines toggles with the same boxes instance', () {
      final boxes = [boxA, boxB];

      final painter = AtsXrayPainter(boxes, showFlowLines: true);
      final oldPainter = AtsXrayPainter(boxes);

      expect(painter.shouldRepaint(oldPainter), isTrue);
    });

    test('is true when the selection changes', () {
      final boxes = [boxA, boxB];
      final selectionRects = [rectA];

      final painter = AtsXrayPainter(
        boxes,
        selection: (rects: selectionRects, shape: AtsEvidenceShape.span),
      );
      final oldPainter = AtsXrayPainter(boxes);

      expect(painter.shouldRepaint(oldPainter), isTrue);
    });
  });

  testWidgets('paints an empty or populated box list without throwing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: CustomPaint(
            painter: AtsXrayPainter(
              [boxA, boxB],
              showFlowLines: true,
              selection: (rects: [rectA, rectB], shape: AtsEvidenceShape.span),
            ),
          ),
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
