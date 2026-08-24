/// Which chrome theme the app renders in — the app's own type rather than
/// Flutter's `ThemeMode`, because `lib/models/` must never import Flutter
/// (see the models-layer rule in CONTRIBUTING.md). `app_theme.dart` owns
/// the mapping to `ThemeMode`.
///
/// A bare enum beside the model that carries it, matching `RegionProfile`
/// and `ApiKeyOrigin`. Serialised by name, so reordering these is a
/// breaking storage change and appending is not.
enum AppThemeMode {
  /// Follow the device's own light/dark setting, and keep following it
  /// when it changes. The default: it is the only value that is right
  /// before the user has expressed a preference.
  system,

  /// Always light, regardless of the device.
  light,

  /// Always dark, regardless of the device.
  dark,
}
