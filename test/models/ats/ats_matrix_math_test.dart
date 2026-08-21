import 'dart:math' as math;

import 'package:cv_forge/models/ats/ats_matrix_math.dart';
import 'package:cv_forge/models/ats/ats_text_node.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('composeAtsTextMatrix', () {
    test('identity item composed with a scale+flip viewport', () {
      // item: translate only (a=1,b=0,c=0,d=1,e=10,f=20)
      // viewport: scale x2 horizontally, scale -2 (flip) vertically,
      // translate (5, 100) — hand-computed via standard row-vector
      // matrix multiplication [a b 0; c d 0; e f 1] independently of the
      // scalar formula under test.
      const item = AtsTextMatrix(a: 1, b: 0, c: 0, d: 1, e: 10, f: 20);
      const viewport = AtsTextMatrix(a: 2, b: 0, c: 0, d: -2, e: 5, f: 100);

      final result = composeAtsTextMatrix(item, viewport);

      expect(result.a, 2);
      expect(result.b, 0);
      expect(result.c, 0);
      expect(result.d, -2);
      expect(result.e, 25); // 10*2 + 20*0 + 5
      expect(result.f, 60); // 10*0 + 20*-2 + 100
    });

    test('a 90-degree rotated item composed with the identity viewport '
        'is unchanged', () {
      const item = AtsTextMatrix(a: 0, b: 1, c: -1, d: 0, e: 3, f: 4);
      const identity = AtsTextMatrix(a: 1, b: 0, c: 0, d: 1, e: 0, f: 0);

      final result = composeAtsTextMatrix(item, identity);

      expect(result.a, item.a);
      expect(result.b, item.b);
      expect(result.c, item.c);
      expect(result.d, item.d);
      expect(result.e, item.e);
      expect(result.f, item.f);
    });

    test('composing with an identity item leaves the viewport unchanged', () {
      const identity = AtsTextMatrix(a: 1, b: 0, c: 0, d: 1, e: 0, f: 0);
      const viewport = AtsTextMatrix(
        a: 1.5,
        b: 0,
        c: 0,
        d: -1.5,
        e: 12,
        f: 300,
      );

      final result = composeAtsTextMatrix(identity, viewport);

      expect(result.a, viewport.a);
      expect(result.b, viewport.b);
      expect(result.c, viewport.c);
      expect(result.d, viewport.d);
      expect(result.e, viewport.e);
      expect(result.f, viewport.f);
    });
  });

  group('atsInkBoxRect', () {
    // A simple horizontal, unrotated 10pt run starting at (56.69, 700),
    // 50pt advance — the shape `ats_analyzer_service_test.dart`'s node
    // fixtures already use. The viewport here is the identity (scale 1,
    // no flip) so the expected pixel-space numbers are just the
    // page-space ones, making the ascent/descent/width math easy to
    // check by hand.
    const node = AtsTextNode(
      pageIndex: 0,
      str: 'Hello',
      transform: AtsTextMatrix(a: 10, b: 0, c: 0, d: 10, e: 56.69, f: 700),
      width: 50,
      fontName: 'g_d0_f1',
    );
    const identityViewport = AtsTextMatrix(a: 1, b: 0, c: 0, d: 1, e: 0, f: 0);

    test('unrotated run: box spans the advance width and ascent/descent '
        'around the baseline', () {
      final rect = atsInkBoxRect(
        node: node,
        viewport: identityViewport,
        ascent: 0.8,
        descent: -0.2,
      );

      expect(rect.left, closeTo(56.69, 1e-9));
      expect(rect.right, closeTo(56.69 + 50, 1e-9));
      // ascent extends "up" (larger y, this fixture's page space is
      // still y-up pre-viewport) from the baseline, descent "down" —
      // atsInkBoxRect takes the bounding box, so top/bottom end up
      // sorted regardless of which direction is numerically larger.
      expect(rect.bottom, closeTo(700 + 0.8 * 10, 1e-9));
      expect(rect.top, closeTo(700 - 0.2 * 10, 1e-9));
    });

    test('missing ascent/descent falls back to typical defaults instead '
        'of throwing', () {
      final rect = atsInkBoxRect(node: node, viewport: identityViewport);

      expect(rect.left, closeTo(56.69, 1e-9));
      expect(rect.right, closeTo(56.69 + 50, 1e-9));
      expect(rect.top, lessThan(rect.bottom));
    });

    test('a 90-degree rotated run produces a box rotated into the '
        'vertical axis instead of the horizontal one', () {
      const rotated = AtsTextNode(
        pageIndex: 0,
        str: 'CONFIDENTIAL',
        transform: AtsTextMatrix(a: 0, b: 10, c: -10, d: 0, e: 20, f: 300),
        width: 80,
        fontName: 'g_d0_f1',
      );

      final rect = atsInkBoxRect(
        node: rotated,
        viewport: identityViewport,
        ascent: 0.8,
        descent: -0.2,
      );

      // The advance runs along +y (not +x) for a 90-degree-rotated run,
      // so the box should be tall and narrow, not wide and short.
      expect(rect.bottom - rect.top, greaterThan(rect.right - rect.left));
      expect(rect.bottom - rect.top, closeTo(80, 1e-9));
    });

    test('projects through a non-identity viewport (scale + y-flip) '
        'rather than just passing page-space coordinates through', () {
      const viewport = AtsTextMatrix(a: 2, b: 0, c: 0, d: -2, e: 0, f: 1000);

      final rect = atsInkBoxRect(
        node: node,
        viewport: viewport,
        ascent: 0.8,
        descent: -0.2,
      );

      expect(rect.left, closeTo(56.69 * 2, 1e-9));
      expect(rect.right, closeTo((56.69 + 50) * 2, 1e-9));
      // The y-flip means the page-space "top" (ascent side, larger y)
      // maps to the smaller pixel y — confirm the box didn't just copy
      // page-space y values through unprojected.
      final expectedTopPageY = 700 + 0.8 * 10;
      final expectedBottomPageY = 700 - 0.2 * 10;
      expect(rect.top, closeTo(expectedTopPageY * -2 + 1000, 1e-9));
      expect(rect.bottom, closeTo(expectedBottomPageY * -2 + 1000, 1e-9));
    });
  });

  // Sanity check on the rotation convention `atsInkBoxRect` relies on —
  // matches `AtsTextMatrix.rotationRadians`'s own doc comment.
  test('atan2(b, a) is 0 for an unrotated matrix and pi/2 for a '
      '90-degree one', () {
    const unrotated = AtsTextMatrix(a: 10, b: 0, c: 0, d: 10, e: 0, f: 0);
    const rotated90 = AtsTextMatrix(a: 0, b: 10, c: -10, d: 0, e: 0, f: 0);

    expect(unrotated.rotationRadians, closeTo(0, 1e-9));
    expect(rotated90.rotationRadians, closeTo(math.pi / 2, 1e-9));
  });

  group('atsUnionRect', () {
    test('a single rect unions to itself', () {
      const rect = (left: 1.0, top: 2.0, right: 3.0, bottom: 4.0);

      expect(atsUnionRect([rect]), rect);
    });

    test('unions the outer extent of disjoint rects, not their overlap', () {
      const a = (left: 0.0, top: 0.0, right: 10.0, bottom: 10.0);
      const b = (left: 50.0, top: -5.0, right: 60.0, bottom: 2.0);

      final union = atsUnionRect([a, b]);

      expect(union.left, 0);
      expect(union.top, -5);
      expect(union.right, 60);
      expect(union.bottom, 10);
    });
  });
}
