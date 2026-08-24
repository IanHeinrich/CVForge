/// Which stage of a Google auth flow failed, so the UI can show recovery
/// copy per mode. Mirrors [PdfExtractionFailure]/[BackupFailure].
enum GoogleAuthFailure {
  /// No `GOOGLE_OAUTH_CLIENT_ID` in this build. [GoogleAuthService
  /// .isConfigured] should have hidden the feature before this is hit.
  notConfigured,

  /// The Google Identity Services script failed to load — a network/CDN
  /// problem, not a problem with the user's account.
  scriptLoadFailed,

  /// The user closed the consent popup, or the browser blocked it for not
  /// originating from a direct user gesture.
  cancelledOrBlocked,

  /// Every other GIS-reported failure, surfaced with the raw `error`
  /// string as [GoogleAuthException.cause].
  unknown,
}

/// Wraps whatever [GoogleAuthService.connect] threw, tagged with [failure]
/// so callers classify it without inspecting the underlying value.
class GoogleAuthException implements Exception {
  const GoogleAuthException(this.failure, [this.cause]);

  final GoogleAuthFailure failure;
  final Object? cause;

  @override
  String toString() => 'GoogleAuthException(failure: $failure, cause: $cause)';
}

/// Vends short-lived Google OAuth access tokens scoped to `drive.appdata`
/// and nothing else.
///
/// A pure interface, registered by hand in `main.dart` rather than through
/// `@StackedApp(dependencies: [...])` — [GoogleAuthServiceWeb] reaches
/// `dart:js_interop`, which would pull that import into the generated
/// `app.locator.dart` and break the VM-run test suite. Same reasoning as
/// [PdfExtractionService].
///
/// Stateless to callers: browser OAuth issues no refresh token to a public
/// client, so every token this vends is in memory only and there is
/// nothing durable to expose. `DriveSyncService` turns "can/can't get a
/// token right now" into the reactive [DriveSyncStatus] the UI binds to.
abstract class GoogleAuthService {
  /// True once a non-empty `--dart-define=GOOGLE_OAUTH_CLIENT_ID=...` was
  /// compiled in. `DriveSettingsCard` hides the whole feature when false,
  /// rather than showing a "Connect" button that can only fail.
  bool get isConfigured;

  /// A valid access token without ever showing UI — a still-fresh cached
  /// one, or one silently renewed against an existing grant. `null` when
  /// renewal isn't possible, which is expected and flips
  /// `DriveSyncStatus.needsReauth` rather than throwing.
  ///
  /// **Renewal needs a live user gesture**, even with `prompt: ''`: GIS
  /// renews via a popup and the browser refuses one outside a gesture
  /// (`popup_failed_to_open`). So this returns `null` whenever the cache
  /// is empty and no gesture is in flight — the normal state right after a
  /// refresh, which [tokenOnNextUserGesture] recovers from.
  Future<String?> silentAccessToken();

  /// Loads the GIS client without requesting a token, so it is safe at
  /// page load. Worth doing early: transient activation lasts only a few
  /// seconds, so a cold script load inside a gesture handler can burn the
  /// very activation the request needs.
  Future<void> warmUp();

  /// Completes with a token minted from the user's next interaction, or
  /// `null` if that fails too (only an interactive [connect] can recover).
  ///
  /// The counterpart to [silentAccessToken]'s gesture requirement: callers
  /// arm this after a refresh and carry on rather than declaring the
  /// session dead. Repeated calls share the same pending attempt.
  Future<String?> tokenOnNextUserGesture();

  /// Requests the `drive.appdata` scope interactively. Must be called
  /// synchronously from a user gesture, or the popup is blocked. Throws
  /// [GoogleAuthException] on cancel, block, or any other failure.
  Future<String> connect();

  /// Revokes the grant and clears every cached token, so
  /// [silentAccessToken] returns `null` until [connect] runs again.
  Future<void> disconnect();
}
