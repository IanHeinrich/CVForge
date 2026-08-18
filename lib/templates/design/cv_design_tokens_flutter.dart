import 'package:flutter/widgets.dart';

import 'cv_design_tokens.dart';

/// Flutter-side adapter for [CvDesignTokens]/[CvTypeToken] — the ONLY file
/// under `templates/design/` allowed to import `flutter`.
extension CvTypeTokenFlutter on CvTypeToken {
  /// [fontFamily] is passed in rather than baked into the token, since the
  /// token itself is renderer-agnostic. [smallCaps] is deliberately NOT
  /// reflected here — Liberation Serif has no OpenType `smcp` feature, so
  /// small caps are faked by splitting text into full/reduced-size runs
  /// (see `small_caps.dart`); this style is the "full size" run's style,
  /// and callers derive the reduced-size run's style from it.
  TextStyle toTextStyle(String fontFamily) => TextStyle(
    fontFamily: fontFamily,
    fontSize: sizePt,
    fontWeight: weight == CvWeight.bold ? FontWeight.bold : FontWeight.normal,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    // pw.TextStyle.lineSpacing is EXTRA points between lines; Flutter's
    // TextStyle.height is a multiplier of the whole line box. Convert
    // the pt-based token into that multiplier here.
    height: (sizePt + lineSpacingPt) / sizePt,
    letterSpacing: letterSpacingPt,
    color: colorArgb == null ? null : Color(colorArgb!),
  );
}

extension CvDesignTokensFlutter on CvDesignTokens {
  EdgeInsets get pageMargins =>
      EdgeInsets.fromLTRB(marginLeft, marginTop, marginRight, marginBottom);
}
