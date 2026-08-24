/// Which stage of a Google auth flow failed — mirrors [PdfExtractionFailure]/
/// [BackupFailure]'s precedent so the UI can show different recovery copy
/// per failure mode instead of one generic "something went wrong".
enum GoogleAuthFailure {
  /// No `GOOGLE_OAUTH_CLIENT_ID` was compiled into this build — the whole
  /// Drive sync feature should be hidden before this can ever be hit; see
  /// [GoogleAuthService.isConfigured].
  notConfigured,

  /// The Google Identity Services script itself failed to load — a
  /// network/CDN problem, not a problem with the user's account.
  scriptLoadFailed,

  /// The user closed the consent popup, or the browser blocked it for not
  /// originating from a direct user gesture.
  cancelledOrBlocked,

  /// Every other GIS-reported failure — surfaced with the raw `error`
  /// string as [GoogleAuthException.cause] rather than swallowed.
  unknown,
}

/// Wraps whatever [GoogleAuthService.connect] (or a failed silent renewal
/// worth surfacing rather than just returning null for) threw, tagged with
/// [failure] so callers can classify it without inspecting the underlying
/// value.
class GoogleAuthException implements Exception {
  const GoogleAuthException(this.failure, [this.cause]);

  final GoogleAuthFailure failure;
  final Object? cause;

  @override
  String toString() => 'GoogleAuthException(failure: $failure, cause: $cause)';
}

/// Vends short-lived Google OAuth access tokens scoped to
/// `drive.appdata` — nothing else. Pure interface, deliberately not
/// registered through `app.dart`'s `@StackedApp(dependencies: [...])`
/// list: the real implementation ([GoogleAuthServiceWeb], in
/// `google_auth_service_web.dart`) imports `dart:js_interop`/`package:web`
/// via `gis_bindings.dart`, which doesn't compile under the Dart VM at
/// all. Registering it through the normal list would pull that import
/// into the centrally-generated `app.locator.dart` and break the whole
/// VM-run test suite — see [PdfExtractionService]'s doc comment for the
/// exact same reasoning, and `main.dart` for how this is wired instead
/// (a manual `registerLazySingleton` call, not the annotation).
///
/// Deliberately stateless from callers' point of view: no persisted
/// token, no reactive "signed in" stream. Browser OAuth issues no refresh
/// token to a public client (see this feature's design doc), so every
/// access token this vends lives in memory only and is either the still-
/// valid cached one or a freshly renewed one — there is nothing durable
/// to expose. `DriveSyncService` is the layer that turns "can/can't get a
/// token right now" into the reactive [DriveSyncStatus] the UI binds to.
abstract class GoogleAuthService {
  /// True once a non-empty client ID was compiled into this build via
  /// `--dart-define=GOOGLE_OAUTH_CLIENT_ID=...`. `DriveSettingsCard` uses
  /// this (via `DriveSyncService.isAvailable`) to hide the entire feature
  /// rather than show a broken "Connect" button in local dev or a
  /// misconfigured deploy.
  bool get isConfigured;

  /// Returns a valid access token without ever showing UI — either a
  /// still-fresh cached one, or one silently renewed (`prompt: ''`)
  /// against an existing Google session and a grant this app already
  /// has. Returns `null` when silent renewal isn't possible (no prior
  /// grant, the Google session itself has ended, or the grant was
  /// revoked) — a normal, expected outcome that flips
  /// `DriveSyncStatus.needsReauth`, not a thrown failure.
  ///
  /// **Renewal needs a live user gesture**, even with `prompt: ''` and a
  /// grant already in place. GIS renews by opening a popup, and a browser
  /// refuses that outside a gesture — confirmed from GIS's own
  /// `error_callback` reporting `popup_failed_to_open` on every page load.
  /// So this returns `null` whenever the cache is empty and no gesture is
  /// in flight, which is the normal state immediately after a refresh.
  /// [tokenOnNextUserGesture] is how a caller recovers from that.
  Future<String?> silentAccessToken();

  /// Loads the GIS client and builds the token client without requesting
  /// a token — safe to call at page load, where a real request would be
  /// blocked. Worth doing early: a browser's transient activation lasts
  /// only a few seconds, so a cold script load inside a gesture handler
  /// can burn the very activation the request needs.
  Future<void> warmUp();

  /// Completes with a token minted from the user's next interaction with
  /// the page, or `null` if that attempt fails too (the grant is gone, so
  /// only an interactive [connect] can recover).
  ///
  /// This is the counterpart to [silentAccessToken]'s gesture
  /// requirement: after a refresh there is no cached token and no way to
  /// mint one until the user touches something, so callers arm this and
  /// carry on rather than declaring the session dead. Repeated calls
  /// while one is already armed share the same pending attempt.
  Future<String?> tokenOnNextUserGesture();

  /// Requests the `drive.appdata` scope interactively, showing Google's
  /// consent UI if needed. Must be called synchronously from a user
  /// gesture (a button's `onPressed`) — browsers, and GIS itself, block
  /// the popup otherwise. Throws [GoogleAuthException] if the user
  /// cancels/the popup is blocked, or the request otherwise fails.
  Future<String> connect();

  /// Revokes the current grant with Google and clears every cached
  /// token, so a subsequent [silentAccessToken] correctly returns `null`
  /// until [connect] is called again.
  Future<void> disconnect();
}
