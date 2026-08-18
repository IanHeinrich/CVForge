import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

/// Scales [child] (rendered by a template at natural PDF-point size) to
/// fit the available width, and renders it on a whole number of
/// full-page-height white sheets — one if [child] is shorter than a page,
/// two-plus with a dashed divider at each page break otherwise. It never
/// shrinks the page to hug shorter content, since a CV preview should read
/// as "pages", not as an arbitrarily-tall strip of white.
///
/// Deliberately NOT `FittedBox` — it throws inside `AspectRatio` inside a
/// fixed-width `Container` (flutter#142910). Deliberately NOT real
/// pagination either — reimplementing `pw.MultiPage`'s splitting in
/// Flutter is a large effort for a preview already declared approximate;
/// the PDF is the authority on where pages actually break.
///
/// [child]'s height isn't known ahead of layout, so this does a rough
/// first-frame estimate (one page's height) and corrects itself via
/// [WidgetsBinding.addPostFrameCallback] once the real height is
/// measured — a one-frame visual settle, not a layout bug.
///
/// The measured subtree sits inside an [OverflowBox] with an unbounded
/// height so it always reports its true intrinsic height, decoupled from
/// the page-rounded height the rest of this widget lays it out against.
/// Without that decoupling, a naive implementation would feed the current
/// (possibly wrong) height estimate back in as a constraint — since a
/// `Column` defaults to `MainAxisSize.max`, it would report back exactly
/// that constrained height instead of its real one, so each "correction"
/// would shrink the estimate instead of fixing it, collapsing the preview
/// over dozens of frames instead of settling in one measurement.
class CvPageSurface extends StatefulWidget {
  const CvPageSurface({super.key, required this.format, required this.child});

  final PdfPageFormat format;
  final Widget child;

  @override
  State<CvPageSurface> createState() => _CvPageSurfaceState();
}

class _CvPageSurfaceState extends State<CvPageSurface> {
  final _contentKey = GlobalKey();
  late double _naturalHeight = widget.format.height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth <= 0
            ? 1.0
            : constraints.maxWidth / widget.format.width;
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

        final pageCount = math.max(
          1,
          (_naturalHeight / widget.format.height).ceil(),
        );
        final totalHeight = pageCount * widget.format.height;

        return SizedBox(
          width: constraints.maxWidth,
          height: totalHeight * scale,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topLeft,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: widget.format.width,
                  height: totalHeight,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: Colors.white),
                      ),
                      OverflowBox(
                        alignment: Alignment.topLeft,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: SizedBox(
                          key: _contentKey,
                          width: widget.format.width,
                          child: widget.child,
                        ),
                      ),
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PageBreakGuidePainter(
                            pageHeight: widget.format.height,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _measure() {
    final box = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    if ((box.size.height - _naturalHeight).abs() > 0.5) {
      setState(() => _naturalHeight = box.size.height);
    }
  }
}

class _PageBreakGuidePainter extends CustomPainter {
  const _PageBreakGuidePainter({required this.pageHeight});

  final double pageHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBBBBBB)
      ..strokeWidth = 1;

    var y = pageHeight;
    const dashWidth = 6.0;
    const dashGap = 4.0;
    while (y < size.height) {
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
        x += dashWidth + dashGap;
      }
      y += pageHeight;
    }
  }

  @override
  bool shouldRepaint(covariant _PageBreakGuidePainter oldDelegate) =>
      oldDelegate.pageHeight != pageHeight;
}
