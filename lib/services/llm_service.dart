import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider_registry.dart';

/// Owns Copilot *policy* — which provider to call, the shared transport,
/// and nothing about any vendor's wire format. An [LlmProvider]
/// (resolved through [LlmProviderRegistry]) owns *dialect*; see
/// `lib/services/llm/llm_provider.dart`'s doc comment for the split.
///
/// [LlmProviderRegistry] is instantiated directly rather than injected
/// through the locator — it's stateless and deterministic (same
/// reasoning as `CvComposer` not getting its own service wrapper, see
/// its doc comment), and nothing besides this service ever needs one.
class LlmService {
  /// [client] is a test seam — production code always uses the default.
  /// Nothing else needs one injected, so this isn't a locator
  /// registration, just a constructor default.
  ///
  /// The timeouts are the whole reason a tailoring request can report
  /// [LlmFailure.timeout] at all: `Dio` applies none by default, so
  /// without these a hung request waits on the OS socket timeout with the
  /// user watching a spinner. [_receiveTimeout] is deliberately generous —
  /// a full tailoring pass with adaptive thinking is a single long
  /// request with nothing to render until it completes.
  LlmService({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: _connectTimeout,
              sendTimeout: _sendTimeout,
              receiveTimeout: _receiveTimeout,
            ),
          );

  static const _connectTimeout = Duration(seconds: 20);
  static const _sendTimeout = Duration(seconds: 60);
  static const _receiveTimeout = Duration(minutes: 10);

  final Dio _client;
  final LlmProviderRegistry _registry = LlmProviderRegistry();

  /// The cheapest possible proof [apiKey] is valid for [providerId] — see
  /// [LlmProvider.validateKey]. Propagates [LlmException] for the caller
  /// to map to UI copy.
  ///
  /// `async` rather than returning the delegate's future directly: the
  /// empty-key guard below would otherwise throw *synchronously*, escaping
  /// a caller's `runBusyFuture(...)` instead of being captured as that
  /// call's error. Same reason `VaultViewModel._load` is written the way
  /// it is.
  Future<void> testConnection(String providerId, String apiKey) async {
    if (apiKey.isEmpty) throw const LlmException(LlmFailure.noKey);
    return _registry
        .byId(providerId)
        .validateKey(client: _client, apiKey: apiKey);
  }

  /// The seam the tailoring pass calls into — thin delegation to
  /// whichever [LlmProvider] [providerId] resolves to. `async` for the
  /// same reason as [testConnection].
  Future<LlmJsonResponse> completeJson({
    required String providerId,
    required String modelId,
    required String apiKey,
    required String systemPrompt,
    required String userContent,
    required JsonSchema schema,
  }) async {
    if (apiKey.isEmpty) throw const LlmException(LlmFailure.noKey);
    return _registry
        .byId(providerId)
        .completeJson(
          client: _client,
          apiKey: apiKey,
          modelId: modelId,
          systemPrompt: systemPrompt,
          userContent: userContent,
          schema: schema,
        );
  }
}
