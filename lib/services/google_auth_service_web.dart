import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'gis_bindings.dart' as gis;
import 'google_auth_service.dart';

/// The real [GoogleAuthService] — split into its own file for the same
/// reason `PdfExtractionServiceWeb` is: `package:web`/`dart:js_interop`
/// don't compile under the Dart VM at all, so nothing the VM-run test
/// suite touches may import this file. See [GoogleAuthService]'s doc
/// comment, and `main.dart` for how this gets registered.
class GoogleAuthServiceWeb implements GoogleAuthService {
  GoogleAuthServiceWeb({String? clientId})
    : _clientId =
          clientId ?? const String.fromEnvironment('GOOGLE_OAUTH_CLIENT_ID');

  /// Read-only access to the app's own hidden per-app storage folder —
  /// see this feature's design doc for why this is the one scope this
  /// whole feature ever requests: it's classified non-sensitive by
  /// Google (no OAuth verification review needed) and can't reach any of
  /// the user's real Drive files.
  static const _scope = 'https://www.googleapis.com/auth/drive.appdata';

  /// A silent renewal is attempted this long before the cached token's
  /// actual expiry (GIS tokens last 3600s) — enough headroom that a sync
  /// in flight when the token is close to expiring doesn't get cut off
  /// mid-request by a token that expires a few seconds after
  /// [silentAccessToken] handed it out.
  static const _renewBefore = Duration(minutes: 5);

  final String _clientId;

  @override
  bool get isConfigured => _clientId.isNotEmpty;

  gis.GisTokenClient? _tokenClient;
  Completer<void>? _scriptLoad;

  String? _accessToken;
  DateTime? _expiresAt;

  /// Set immediately before every `requestAccessToken` call and completed
  /// by the shared `callback` GIS invokes once that request resolves.
  /// GIS's token client has exactly one callback per client instance
  /// (set at [_ensureTokenClient] time), so every request funnels through
  /// this single completer — safe because [_requestToken] serializes on
  /// [_requestLock], never issuing a second request while one is still
  /// in flight.
  Completer<gis.GisTokenResponse>? _pendingRequest;

  /// Chains successive [_requestToken] calls so two overlapping callers
  /// (e.g. a background silent renewal and a user-initiated [connect])
  /// never both have a `requestAccessToken` call in flight at once —
  /// there is exactly one JS `callback` per token client, so a second
  /// concurrent request would race the first for it. `null` means
  /// nothing is currently queued.
  Future<void>? _requestLock;

  @override
  Future<String?> silentAccessToken() async {
    if (!isConfigured) return null;
    final cached = _accessToken;
    final expiresAt = _expiresAt;
    if (cached != null &&
        expiresAt != null &&
        DateTime.now().isBefore(expiresAt.subtract(_renewBefore))) {
      return cached;
    }
    try {
      final response = await _requestToken(prompt: '');
      return _handleResponse(response, throwOnError: false);
    } on GoogleAuthException {
      return null;
    }
  }

  @override
  Future<void> warmUp() async {
    if (!isConfigured) return;
    try {
      await _ensureTokenClient();
    } on GoogleAuthException {
      // Nothing to surface yet — the next real request reports it.
    }
  }

  Completer<String?>? _gestureWait;
  JSFunction? _gestureListener;

  @override
  Future<String?> tokenOnNextUserGesture() {
    final pending = _gestureWait;
    if (pending != null) return pending.future;
    if (!isConfigured) return Future.value(null);

    final completer = Completer<String?>();
    _gestureWait = completer;

    void onGesture(web.Event event) {
      _removeGestureListener();
      // Deliberately not awaited before the request goes out: transient
      // activation is short-lived, and everything slow (the GIS script,
      // the token client) was already done in warmUp.
      silentAccessToken().then((token) {
        _gestureWait = null;
        if (!completer.isCompleted) completer.complete(token);
      });
    }

    final listener = onGesture.toJS;
    _gestureListener = listener;
    web.document.addEventListener('pointerdown', listener);
    web.document.addEventListener('keydown', listener);
    return completer.future;
  }

  void _removeGestureListener() {
    final listener = _gestureListener;
    if (listener == null) return;
    web.document.removeEventListener('pointerdown', listener);
    web.document.removeEventListener('keydown', listener);
    _gestureListener = null;
  }

  @override
  Future<String> connect() async {
    if (!isConfigured) {
      throw const GoogleAuthException(GoogleAuthFailure.notConfigured);
    }
    final response = await _requestToken(prompt: 'consent');
    final token = _handleResponse(response, throwOnError: true);
    // _handleResponse only returns null when throwOnError is false.
    return token!;
  }

  @override
  Future<void> disconnect() async {
    final token = _accessToken;
    _accessToken = null;
    _expiresAt = null;
    _tokenClient = null;
    _removeGestureListener();
    // Anything still waiting on a gesture is waiting for a session that
    // no longer exists.
    final waiting = _gestureWait;
    _gestureWait = null;
    if (waiting != null && !waiting.isCompleted) waiting.complete(null);
    if (token == null) return;
    final completer = Completer<void>();
    gis.revoke(token, (() => completer.complete()).toJS);
    // revoke() has no documented failure mode worth surfacing as a
    // thrown exception — the tokens above are already cleared regardless
    // of whether Google's own record of the grant is revoked in time, so
    // this only bounds how long a slow/hung revoke call can hold up the
    // caller, not whether disconnecting "succeeds" from this app's own
    // point of view.
    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {},
    );
  }

  /// GIS's `callback` reliably fires when the user completes the flow, or
  /// explicitly denies it from *inside* Google's own UI (`error:
  /// 'access_denied'`) — but empirically does not always fire when the
  /// user just closes the popup window itself rather than clicking a
  /// button in it. Without a timeout that leaves [_requestToken]'s
  /// `completer` (and therefore [connect]/[silentAccessToken], and every
  /// UI state waiting on them) hung indefinitely on "connecting" with no
  /// way to recover short of a page reload. Silent renewal gets a short
  /// timeout — it either resolves fast or genuinely isn't going to
  /// succeed; interactive gets a long one, since a real human completing
  /// a Google sign-in (password managers, 2FA) can legitimately take a
  /// while.
  static const _silentTimeout = Duration(seconds: 10);
  static const _interactiveTimeout = Duration(minutes: 2);

  /// Serializes on [_requestLock] — see its doc comment — rather than
  /// running concurrently, so [_pendingRequest] is always unambiguous
  /// about which caller the next `callback` invocation belongs to.
  Future<gis.GisTokenResponse> _requestToken({required String prompt}) async {
    final previous = _requestLock;
    final unlock = Completer<void>();
    _requestLock = unlock.future;
    if (previous != null) await previous;
    try {
      final client = await _ensureTokenClient();
      final completer = Completer<gis.GisTokenResponse>();
      _pendingRequest = completer;
      client.requestAccessToken(
        gis.buildRequestAccessTokenOptions(prompt: prompt),
      );
      return await completer.future.timeout(
        prompt.isEmpty ? _silentTimeout : _interactiveTimeout,
        onTimeout: () => throw const GoogleAuthException(
          GoogleAuthFailure.cancelledOrBlocked,
          'timed out waiting for a response from Google',
        ),
      );
    } finally {
      _pendingRequest = null;
      unlock.complete();
    }
  }

  /// Caches a successful [response] and returns its token; on failure,
  /// either throws (interactive [connect]) or returns null (silent
  /// [silentAccessToken]) per [throwOnError] — the two callers need
  /// different failure shapes for the same underlying response.
  String? _handleResponse(
    gis.GisTokenResponse response, {
    required bool throwOnError,
  }) {
    final error = response.error;
    if (error != null) {
      if (!throwOnError) return null;
      final failure = error == 'access_denied' || error == 'popup_closed'
          ? GoogleAuthFailure.cancelledOrBlocked
          : GoogleAuthFailure.unknown;
      throw GoogleAuthException(failure, response.errorDescription ?? error);
    }
    final token = response.accessToken;
    final expiresIn = response.expiresIn;
    if (token == null || expiresIn == null) {
      if (!throwOnError) return null;
      throw const GoogleAuthException(GoogleAuthFailure.unknown);
    }
    _accessToken = token;
    _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    return token;
  }

  Future<gis.GisTokenClient> _ensureTokenClient() async {
    final existing = _tokenClient;
    if (existing != null) return existing;
    await _ensureScriptLoaded();
    final client = gis.initTokenClient(
      gis.buildTokenClientConfig(
        clientId: _clientId,
        scope: _scope,
        callback: ((gis.GisTokenResponse response) {
          final pending = _pendingRequest;
          if (pending == null || pending.isCompleted) return;
          pending.complete(response);
        }).toJS,
        // Without this the popup-blocked case reaches neither callback and
        // the request hangs until the timeout — see buildTokenClientConfig.
        errorCallback: ((gis.GisErrorResponse error) {
          final pending = _pendingRequest;
          if (pending == null || pending.isCompleted) return;
          pending.completeError(
            GoogleAuthException(
              error.type == 'popup_failed_to_open' ||
                      error.type == 'popup_closed'
                  ? GoogleAuthFailure.cancelledOrBlocked
                  : GoogleAuthFailure.unknown,
              '${error.type}: ${error.message}',
            ),
          );
        }).toJS,
      ),
    );
    _tokenClient = client;
    return client;
  }

  /// Injects `<script src="https://accounts.google.com/gsi/client">` on
  /// first use rather than unconditionally in `web/index.html` — this
  /// feature may never be used in a given session (not configured, or the
  /// user never opens the Drive card), and this is a third-party script
  /// this app otherwise has no reason to load on every single page view.
  Future<void> _ensureScriptLoaded() {
    final pending = _scriptLoad;
    if (pending != null) return pending.future;
    final completer = Completer<void>();
    _scriptLoad = completer;
    if (web.window.hasProperty('google'.toJS).toDart) {
      completer.complete();
      return completer.future;
    }
    final script = web.HTMLScriptElement()
      ..src = 'https://accounts.google.com/gsi/client'
      ..async = true
      ..defer = true;
    script.onLoad.listen((_) => completer.complete());
    script.onError.listen(
      (_) => completer.completeError(
        const GoogleAuthException(GoogleAuthFailure.scriptLoadFailed),
      ),
    );
    web.document.head!.appendChild(script);
    return completer.future;
  }
}
