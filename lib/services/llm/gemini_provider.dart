import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/models/llm/llm_usage.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';

/// Google's Gemini API, called directly from the browser. Unlike Anthropic,
/// no special browser-access header exists or is needed — confirmed via a
/// real `fetch()` from an arbitrary origin; general CORS support, not an
/// allowlist.
///
/// Every wire-shape detail below (uppercase `type` casing, string `enum`
/// support, the `candidates[].content.parts[].text` response shape,
/// `usageMetadata` field names, and the `error.status`/`error.details[]
/// .reason` error envelope) was confirmed against real `generateContent`
/// responses, not recalled from training. `systemInstruction` is the one
/// piece that
/// wasn't independently exercised this way; it's a long-stable, widely
/// documented part of this API's surface, but flagging it rather than
/// implying every field here was tested is the whole point of that note.
class GeminiProvider implements LlmProvider {
  const GeminiProvider();

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  @override
  String get id => 'gemini';

  @override
  String get displayName => 'Google Gemini';

  /// USD per million tokens, from Google's published rates as of
  /// 2026-08-21. `gemini-2.5-pro` omitted deliberately —
  /// confirmed via a real request that it has already been retired for
  /// new API keys (redirected to `gemini-3.5-flash-lite`), so a model list
  /// pulled once from `ListModels` is not enough to trust; only models
  /// actually exercised against `generateContent` belong here.
  @override
  List<LlmModelOption> get models => const [
    LlmModelOption(
      id: 'gemini-3.5-flash-lite',
      label: 'Gemini 3.5 Flash-Lite',
      // Pricing not yet re-checked for the 3.5 generation. Carrying
      // 2.5 Flash-Lite's rate forward as the closest known tier; treat
      // as provisional until confirmed against Google's pricing page for
      // the 3.5 models specifically.
      inputPricePerMTok: 0.10,
      outputPricePerMTok: 0.40,
    ),
    LlmModelOption(
      id: 'gemini-3.5-flash',
      label: 'Gemini 3.5 Flash',
      // Confirmed working via a real `generateContent` request (a real
      // `finishReason: "STOP"` response, `modelVersion:
      // "gemini-3.5-flash"`) — added because comparing Anthropic's
      // models against Flash-*Lite* specifically isn't a fair quality
      // comparison between providers, it's a fair comparison between a
      // full model and the cheapest possible tier of the other. Same
      // provisional-pricing caveat as Flash-Lite above: carrying 2.5
      // Flash's confirmed rate forward, not re-checked for the 3.5
      // generation specifically.
      inputPricePerMTok: 0.30,
      outputPricePerMTok: 2.50,
    ),
  ];

  /// Neither of these was reachable from the environment this was written
  /// in — Google's docs are blocked by its network egress policy — so
  /// unlike [AnthropicProvider]'s pair they were not confirmed against a
  /// live page the way every wire-shape detail above was.
  ///
  /// [apiKeyConsoleUrl] was corrected by the repo owner to `/api-keys`;
  /// the plural is the whole point, since the `/apikey` singular that a
  /// model is likely to recall is not the live path. [billingConsoleUrl]
  /// is still only the long-stable public URL and remains unconfirmed —
  /// flagged separately rather than covered by the same note, because
  /// "one of these was checked" is the kind of detail that quietly
  /// becomes "both were" otherwise.
  @override
  Uri get apiKeyConsoleUrl => Uri.parse('https://aistudio.google.com/api-keys');

  @override
  Uri get billingConsoleUrl =>
      Uri.parse('https://console.cloud.google.com/billing');

  @override
  List<String> get apiKeySteps => const [
    'Sign in to Google AI Studio and open API keys.',
    'Create a key — Gemini has a free tier, so you can start without '
        'enabling billing at all.',
    'Copy the key, paste it above, and press Test connection.',
    'Only if you later enable paid billing: set a budget in the Google '
        'Cloud console, per the note below.',
  ];

  Map<String, String> _headers(String apiKey) => {
    'x-goog-api-key': apiKey,
    'content-type': 'application/json',
  };

  @override
  Future<LlmJsonResponse> completeJson({
    required Dio client,
    required String apiKey,
    required String modelId,
    required String systemPrompt,
    required String userContent,
    required JsonSchema schema,
  }) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await client.post<Map<String, dynamic>>(
        '$_baseUrl/models/$modelId:generateContent',
        options: Options(headers: _headers(apiKey)),
        data: {
          'contents': [
            {
              'parts': [
                {'text': userContent},
              ],
            },
          ],
          'systemInstruction': {
            'parts': [
              {'text': systemPrompt},
            ],
          },
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': _walkSchema(schema),
          },
        },
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }

    final body = response.data;
    if (body == null) throw const LlmException(LlmFailure.malformedResponse);

    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const LlmException(LlmFailure.malformedResponse);
    }
    final candidate = candidates.first;
    if (candidate is! Map) {
      throw const LlmException(LlmFailure.malformedResponse);
    }

    // Only `"STOP"` has actually been observed (a successful structured
    // response). Every other value — a safety block, a recitation block,
    // hitting max_tokens, or anything else Gemini might report — is
    // bucketed as `refusal` rather than enumerated from memory: this
    // response won't contain valid JSON matching the schema regardless of
    // which non-STOP reason caused it, and `refusal` is the closest
    // existing failure that doesn't imply a wire-format problem on our
    // side (unlike `malformedResponse`).
    if (candidate['finishReason'] != 'STOP') {
      throw const LlmException(LlmFailure.refusal);
    }

    final content = candidate['content'];
    if (content is! Map) throw const LlmException(LlmFailure.malformedResponse);
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw const LlmException(LlmFailure.malformedResponse);
    }
    final textPart = parts.firstWhere(
      (p) => p is Map && p['text'] is String,
      orElse: () => null,
    );
    if (textPart is! Map) {
      throw const LlmException(LlmFailure.malformedResponse);
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(textPart['text'] as String) as Map<String, dynamic>;
    } catch (e) {
      throw LlmException(LlmFailure.malformedResponse, e);
    }

    final usage = body['usageMetadata'];
    if (usage is! Map) throw const LlmException(LlmFailure.malformedResponse);
    return LlmJsonResponse(
      data: data,
      usage: LlmUsage(
        inputTokens: (usage['promptTokenCount'] as num?)?.toInt() ?? 0,
        // `candidatesTokenCount` alone undercounts what's actually billed
        // at the output rate — confirmed by a real `gemini-3.5-flash`
        // response (a trivial one-word reply) that came back with
        // `candidatesTokenCount: 1` and a separate `thoughtsTokenCount:
        // 86`, additive into `totalTokenCount`. A thinking-capable model
        // bills its reasoning tokens as output, so both fields have to be
        // summed or the price shown in Settings is quietly wrong for any
        // model that thinks by default — the exact "an unrendered price
        // can be wrong indefinitely" failure mode this project's own
        // Opus-pricing lesson already burned once. Absent entirely on a
        // non-thinking response (confirmed for `gemini-3.5-flash-lite`'s
        // own captured response), so `?? 0` is a real default, not a
        // guess.
        outputTokens:
            ((usage['candidatesTokenCount'] as num?)?.toInt() ?? 0) +
            ((usage['thoughtsTokenCount'] as num?)?.toInt() ?? 0),
      ),
    );
  }

  @override
  Future<void> validateKey({
    required Dio client,
    required String apiKey,
  }) async {
    try {
      await client.get<void>(
        '$_baseUrl/models',
        options: Options(headers: _headers(apiKey)),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  LlmException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    final errorBody = e.response?.data;
    final error = errorBody is Map ? errorBody['error'] : null;

    // Confirmed: an invalid key returns HTTP 400 (not 401/403) with
    // `error.status: "INVALID_ARGUMENT"` and
    // `error.details[].reason: "API_KEY_INVALID"` — status-code-only
    // mapping (Anthropic's approach) would misclassify this as
    // `invalidRequest`. Only the exact reason confirmed by a real request
    // is matched; a same-shaped-but-different reason falls through to the
    // generic 4xx handling below rather than being guessed into this
    // bucket.
    if (error is Map) {
      final details = error['details'];
      final isKeyError =
          details is List &&
          details.any((d) => d is Map && d['reason'] == 'API_KEY_INVALID');
      if (isKeyError) return LlmException(LlmFailure.unauthorized, e);
    }

    if (status != null) {
      if (status == 429) return LlmException(LlmFailure.rateLimited, e);
      if (status >= 500) return LlmException(LlmFailure.overloaded, e);
      if (status >= 400) return LlmException(LlmFailure.invalidRequest, e);
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => LlmException(LlmFailure.timeout, e),
      _ => LlmException(LlmFailure.network, e),
    };
  }

  /// Walks the provider-agnostic [JsonSchema] into Gemini's
  /// `generationConfig.responseSchema` dialect — confirmed uppercase type
  /// names and string `enum` support via a real request.
  ///
  /// Deliberately omits `additionalProperties` on object nodes, unlike
  /// [AnthropicProvider]'s unconditional `false` — **confirmed**, not just
  /// documented, that Gemini's schema rejects the field outright as
  /// unrecognized (`400 INVALID_ARGUMENT`, "Cannot find field"). This is
  /// not a weaker version of Anthropic's guarantee, it's an absent one:
  /// Gemini has no schema-level way to close an object to a known key set
  /// at all. Any code that folds a Gemini response's object keys into app
  /// state (the per-experience/per-project id-keyed objects, specifically)
  /// must validate those keys against the known id set itself — the
  /// schema will not do it, for this provider only.
  Map<String, dynamic> _walkSchema(JsonSchema schema) => switch (schema) {
    JsonSchemaObject(:final properties, :final required) => {
      'type': 'OBJECT',
      'properties': properties.map((k, v) => MapEntry(k, _walkSchema(v))),
      'required': required,
    },
    JsonSchemaArray(:final items) => {
      'type': 'ARRAY',
      'items': _walkSchema(items),
    },
    JsonSchemaString() => {'type': 'STRING'},
    JsonSchemaStringEnum(:final values) => {'type': 'STRING', 'enum': values},
    JsonSchemaNumber() => {'type': 'NUMBER'},
    JsonSchemaBoolean() => {'type': 'BOOLEAN'},
  };
}
