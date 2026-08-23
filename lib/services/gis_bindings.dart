// ignore_for_file: public_member_api_docs
//
// `dart:js_interop` bindings for Google Identity Services' token client
// (`google.accounts.oauth2`, loaded on demand from
// `https://accounts.google.com/gsi/client` by `GoogleAuthServiceWeb` —
// unlike `pdf.js`, this can't be vendored locally, since it's the live
// OAuth/consent surface itself). Modeled on `pdfjs_bindings.dart`'s shape
// and its "binding-correctness notes" discipline.
//
// Binding-correctness notes:
//  - `initTokenClient`'s config and `requestAccessToken`'s options are
//    both built by hand via `dart:js_interop_unsafe`'s `setProperty`
//    (`_jsObject` below) rather than an `external factory` on an
//    extension type. GIS's own field names (`client_id`,
//    `error_callback`) are snake_case, and a factory constructor's
//    per-parameter `@JS('name')` rename is newer, less-exercised
//    dart:js_interop surface than a plain `JSObject`/`setProperty` build
//    — this file takes the more conservative, unambiguously-correct path
//    given there's no way to compile-check it against the real bundle
//    from here (contrast `pdfjs_bindings.dart`, verified against a
//    vendored, inspectable bundle).
//  - `callback`/`error_callback` are plain JS functions taking one
//    argument each; built via `(GisTokenResponse r) { ... }.toJS`, the
//    same conversion `pdf_extraction_service_web.dart` already uses for
//    the reverse direction (Dart values into a JS binding).
//  - `expires_in` arrives as a JS number, not a string — unlike Drive's
//    own `version` field elsewhere in this feature, which Google's
//    int64-as-string convention forces to a string.
@JS('google.accounts.oauth2')
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS()
external GisTokenClient initTokenClient(JSObject config);

@JS()
external void revoke(String accessToken, JSFunction done);

/// Builds the `initTokenClient` config object. [callback] receives the
/// [GisTokenResponse] on both success and failure — GIS reports a failed
/// request as an `error` field on the same response shape, never as a
/// rejected promise or a thrown error, so there's no separate error path
/// to wire here.
JSObject buildTokenClientConfig({
  required String clientId,
  required String scope,
  required JSFunction callback,
}) => JSObject()
  ..setProperty('client_id'.toJS, clientId.toJS)
  ..setProperty('scope'.toJS, scope.toJS)
  ..setProperty('callback'.toJS, callback);

/// Builds `requestAccessToken`'s options object. [prompt] is `''` for a
/// silent renewal attempt (fails rather than showing UI if one would be
/// needed) or `'consent'` for the interactive, user-gesture-only flow —
/// see `GoogleAuthServiceWeb.silentAccessToken`/`connect`.
JSObject buildRequestAccessTokenOptions({required String prompt}) =>
    JSObject()..setProperty('prompt'.toJS, prompt.toJS);

@anonymous
@JS()
extension type GisTokenClient._(JSObject _) implements JSObject {
  external void requestAccessToken(JSObject options);
}

@anonymous
@JS()
extension type GisTokenResponse._(JSObject _) implements JSObject {
  @JS('access_token')
  external String? get accessToken;

  @JS('expires_in')
  external int? get expiresIn;

  /// Present only on failure — e.g. `'access_denied'` (user closed the
  /// consent popup), `'immediate_failed'`/`'interaction_required'` (no
  /// prior grant, so a silent `prompt: ''` request genuinely cannot
  /// succeed), or `'popup_closed'`. Never thrown as a JS exception; this
  /// field is the only failure signal `requestAccessToken` produces.
  external String? get error;

  @JS('error_description')
  external String? get errorDescription;
}
