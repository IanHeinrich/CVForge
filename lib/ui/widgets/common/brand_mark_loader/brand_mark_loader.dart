import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cv_forge/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The CVForge mark with the hammer working — a loading indicator for waits
/// long enough that a spinner reads as a stall rather than as progress.
///
/// Use it where the wait is measured in tens of seconds (the AI assistant run
/// is the case it was built for). For a wait of a second or two a plain
/// [CircularProgressIndicator] is the better tool: a full strike cycle takes
/// [_cycle], so a short wait shows an arbitrary fragment of a swing.
///
/// The same animation as the pre-Flutter splash in `web/index.html`, which
/// works out the swing's geometry in full. Both use the same numbers, so a
/// change to one wants the same change to the other; they are separate
/// because that one has to run before any Dart does.
class BrandMarkLoader extends StatefulWidget {
  const BrandMarkLoader({
    super.key,
    this.size = defaultSize,
    this.color,
    this.semanticsLabel,
  });

  /// Large enough for the swing to read. Below roughly 80 the hammer's arc
  /// stops being legible and the mark is better served by [BrandMark].
  static const double defaultSize = 120;

  final double size;

  /// Defaults to the ambient [IconTheme] colour, matching `BrandMark`.
  final Color? color;

  /// Announced in place of the mark. A loading indicator that says nothing
  /// leaves a screen-reader user with no signal that anything is happening,
  /// so call sites should pass what is being waited on.
  final String? semanticsLabel;

  @override
  State<BrandMarkLoader> createState() => _BrandMarkLoaderState();
}

/// One full strike. Matches the web splash's 1300ms.
const _cycle = Duration(milliseconds: 1300);

/// The slower, motion-free cycle used when the platform asks for reduced
/// motion — see [_BrandMarkLoaderState.build].
const _reducedMotionCycle = Duration(milliseconds: 2400);

/// The mark's own coordinate space. The art is a 192 box; the asset's viewBox
/// is widened to 232 and re-centred on the mark's centre, because the swing
/// carries the hand out past the mark's right edge. Both layer assets use this
/// box, so they overlay with no per-layer offset.
const _viewBoxSize = 232.0;
const _viewBoxOrigin = -20.0;

/// The haft tip — the hand — in mark coordinates. Every pose is a rotation
/// about this point plus a translation of it.
const _pivot = Offset(168, 19);

/// Where the head's end face meets the anvil: on the strip of face between
/// the page's lifted corner and the horn root. The sparks are struck from
/// here. The value predates the anvil redraw, which kept the face top at
/// y=100 precisely so this — and every pose below — could survive it.
const _contact = Offset(134, 94);

/// Rotation is on top of the +35deg the hammer already carries in the asset,
/// so these are 35 less than the totals quoted in `web/index.html`.
const _windup = _Pose(65, 18.5, -28.5);
const _impact = _Pose(35, 38.5, 12.3);

/// The top of the bounce, and the brief hang after it. The hammer leaves the
/// anvil fast and decelerates into [_bounce] — clearing the face by 37 —
/// drifts on to [_hang] as the momentum runs out, and only then gets lifted
/// back to [_windup]. Rolling those two into one even-rated stroke is what
/// made an earlier pass look like the hammer was being picked up off the face
/// rather than thrown off it.
const _bounce = _Pose(60, 31.8, -13.6);
const _hang = _Pose(62, 30.2, -15.9);

/// A hammer pose: a rotation about [_pivot], and a translation of the whole
/// hammer, both in the mark's coordinate space. The translation is what keeps
/// this from reading as a lever on a hinge — through the blow the hand itself
/// drops 27 and comes forward 9 while the head drops 58.
class _Pose {
  const _Pose(this.rotationDegrees, this.dx, this.dy);

  final double rotationDegrees;
  final double dx;
  final double dy;

  static _Pose lerp(_Pose a, _Pose b, double t) => _Pose(
    lerpDouble(a.rotationDegrees, b.rotationDegrees, t)!,
    lerpDouble(a.dx, b.dx, t)!,
    lerpDouble(a.dy, b.dy, t)!,
  );
}

class _PoseTween extends Tween<_Pose> {
  _PoseTween({required _Pose super.begin, required _Pose super.end});

  @override
  _Pose lerp(double t) => _Pose.lerp(begin!, end!, t);
}

class _BrandMarkLoaderState extends State<BrandMarkLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  )..repeat();

  /// Weights are percentages of the cycle, so they read against the web
  /// splash's keyframe stops directly: 10 / 25 / 31 / 43 / 51 / 79. The beat
  /// held at the impact is taken out of the two windup holds rather than out
  /// of the strokes either side, so the swing, bounce and lift keep the
  /// durations they were tuned to.
  late final Animation<_Pose> _hammer = TweenSequence<_Pose>([
    TweenSequenceItem(tween: ConstantTween(_windup), weight: 10),
    TweenSequenceItem(
      tween: _PoseTween(
        begin: _windup,
        end: _impact,
      ).chain(CurveTween(curve: const Cubic(.55, 0, .9, .35))),
      weight: 15,
    ),
    // A hammer meeting an immovable face stops dead, so unlike the hang at the
    // top of the bounce this is a true hold rather than a drift. The give
    // comes from the anvil's jolt and the sparks, both of which run across it.
    TweenSequenceItem(tween: ConstantTween(_impact), weight: 6),
    // The deceleration off the face stays gentle enough to spread over the
    // frames it has: a curve that front-loads the distance covers most of the
    // travel in the first frame and then crawls, which reads as choppiness
    // rather than as force.
    TweenSequenceItem(
      tween: _PoseTween(
        begin: _impact,
        end: _bounce,
      ).chain(CurveTween(curve: const Cubic(.08, .6, .3, 1))),
      weight: 12,
    ),
    TweenSequenceItem(
      tween: _PoseTween(
        begin: _bounce,
        end: _hang,
      ).chain(CurveTween(curve: const Cubic(.3, .3, .6, 1))),
      weight: 8,
    ),
    TweenSequenceItem(
      tween: _PoseTween(
        begin: _hang,
        end: _windup,
      ).chain(CurveTween(curve: const Cubic(.5, 0, .3, 1))),
      weight: 28,
    ),
    TweenSequenceItem(tween: ConstantTween(_windup), weight: 21),
  ]).animate(_controller);

  /// The anvil takes the blow: without it the hammer stops dead against a
  /// surface that never acknowledges the hit.
  late final Animation<double> _jolt = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 3.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 2,
    ),
    // Springs back as the hammer leaves, so the recoil reads as the face
    // throwing it off rather than the arm lifting it.
    TweenSequenceItem(
      tween: Tween(
        begin: 3.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 6,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 67),
  ]).animate(_controller);

  late final Animation<double> _sparkOpacity = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 4),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 15,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: 56),
  ]).animate(_controller);

  late final Animation<double> _sparkScale = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0.3), weight: 25),
    TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 4),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.7,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 15,
    ),
    TweenSequenceItem(tween: ConstantTween(0.3), weight: 56),
  ]).animate(_controller);

  /// Reduced motion still has to say "working", so the mark breathes on
  /// opacity — a cue that carries no motion signal.
  late final Animation<double> _breathe = Tween(
    begin: 1.0,
    end: 0.5,
  ).animate(CurvedAnimation(curve: Curves.easeInOut, parent: _controller));

  /// Reduced motion is a [MediaQuery] value, so the cycle it selects is set
  /// here rather than in `build` — `repeat()` schedules a tick, which is not
  /// something to fire from inside a build.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wanted = _reduceMotion ? _reducedMotionCycle : _cycle;
    if (_controller.duration != wanted) {
      _controller.duration = wanted;
      _controller.repeat(reverse: _reduceMotion);
    }
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Mark coordinates to pixels within the rendered box.
  double _scale() => widget.size / _viewBoxSize;

  Offset _toPixels(Offset markPoint) =>
      (markPoint - const Offset(_viewBoxOrigin, _viewBoxOrigin)) * _scale();

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    final reduceMotion = _reduceMotion;

    return Semantics(
      label: widget.semanticsLabel,
      excludeSemantics: true,
      liveRegion: widget.semanticsLabel != null,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: reduceMotion
            ? FadeTransition(opacity: _breathe, child: _restingMark(color))
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => _swing(color),
              ),
      ),
    );
  }

  /// The two layers unanimated compose exactly the static mark.
  Widget _restingMark(Color color) => Stack(
    children: [_layer(_anvilAsset, color), _layer(_hammerAsset, color)],
  );

  Widget _swing(Color color) {
    final scale = _scale();
    final pivot = _toPixels(_pivot);
    final pose = _hammer.value;

    final transform = Matrix4.translationValues(pivot.dx, pivot.dy, 0)
      ..multiply(Matrix4.rotationZ(pose.rotationDegrees * math.pi / 180))
      ..multiply(Matrix4.translationValues(-pivot.dx, -pivot.dy, 0))
      ..multiply(
        Matrix4.translationValues(pose.dx * scale, pose.dy * scale, 0),
      );

    return Stack(
      children: [
        Transform.translate(
          offset: Offset(0, _jolt.value * scale),
          child: _layer(_anvilAsset, color),
        ),
        Transform(transform: transform, child: _layer(_hammerAsset, color)),
        Opacity(
          opacity: _sparkOpacity.value,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _SparksPainter(
              scale: scale,
              origin: _toPixels(_contact),
              burst: _sparkScale.value,
            ),
          ),
        ),
      ],
    );
  }

  Widget _layer(String asset, Color color) => SvgPicture.asset(
    asset,
    width: widget.size,
    height: widget.size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    excludeFromSemantics: true,
  );
}

const _anvilAsset = 'assets/brand/cvforge-mark-anvil.svg';
const _hammerAsset = 'assets/brand/cvforge-mark-hammer.svg';

/// The four sparks struck off the contact corner, in mark coordinates. They
/// sit clear of the head's own silhouette at the moment of impact, so they are
/// not hidden behind it — and, on the left pair, clear of the page's lifted
/// corner at (101,93). Painted rather than shipped as a third asset: they
/// are four straight lines, not brand art.
const _sparks = <List<double>>[
  [126, 99, 112, 101],
  [122, 93, 110, 85],
  [146, 99, 160, 101],
  [152, 96, 166, 91],
];

class _SparksPainter extends CustomPainter {
  const _SparksPainter({
    required this.scale,
    required this.origin,
    required this.burst,
  });

  final double scale;

  /// The contact point, in pixels — the sparks scale outward from it.
  final Offset origin;

  /// How far through the burst, as a scale factor about [origin].
  final double burst;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // The one place still reading the constant rather than
      // `colorScheme.primary`: a painter has no `BuildContext`, and the
      // brand accent is deliberately the same value in both themes (see
      // `app_colors.dart`), so threading a colour in would buy nothing.
      ..color = kcPrimaryColor
      // Matches the splash's spark weight: one step lighter than the mark's
      // 10-weight contour, so the burst reads as debris rather than limbs.
      ..strokeWidth = 7 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(burst);
    canvas.translate(-origin.dx, -origin.dy);

    for (final spark in _sparks) {
      canvas.drawLine(
        _toPixels(Offset(spark[0], spark[1])),
        _toPixels(Offset(spark[2], spark[3])),
        paint,
      );
    }

    canvas.restore();
  }

  Offset _toPixels(Offset markPoint) =>
      (markPoint - const Offset(_viewBoxOrigin, _viewBoxOrigin)) * scale;

  @override
  bool shouldRepaint(_SparksPainter oldDelegate) =>
      oldDelegate.burst != burst ||
      oldDelegate.scale != scale ||
      oldDelegate.origin != origin;
}
