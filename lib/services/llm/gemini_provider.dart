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
/// real `fetch()` from an arbitrary origin (plan.md's 4.4b "Actually
/// verified" note); general CORS support, not an allowlist.
///
/// Every wire-shape detail below (uppercase `type` casing, string `enum`
/// support, the `candidates[].content.parts[].text` response shape,
/// `usageMetadata` field names, and the `error.status`/`error.details[]
/// .reason` error envelope) was confirmed against real `generateContent`
/// responses, not recalled from training — see plan.md's 4.4b for the
/// exact requests/responses. `systemInstruction` is the one piece that
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
  /// 2026-08-21 (plan.md's 4.4b). `gemini-2.5-pro` omitted deliberately —
  /// confirmed via a real request that it has already been retired for
  /// new API keys (redirected to `gemini-3.5-flash-lite`), so a model list
  /// pulled once from `ListModels` is not enough to trust; only models
  /// actually exercised against `generateContent` belong here.
  @override
  List<LlmModelOption> get models => const [
    LlmModelOption(
      id: 'gemini-3.5-flash-lite',
      label: 'Gemini 3.5 Flash-Lite',
      // Pricing not yet re-checked for the 3.5 generation — the 4.4b
      // table covers the 2.5 family, which this id supersedes. Carrying
      // 2.5 Flash-Lite's rate forward as the closest known tier; treat
      // as provisional until confirmed against Google's pricing page for
      // the 3.5 models specifically.
      inputPricePerMTok: 0.10,
      outputPricePerMTok: 0.40,
    ),
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
        outputTokens: (usage['candidatesTokenCount'] as num?)?.toInt() ?? 0,
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
  /// names and string `enum` support via a real request (plan.md 4.4b).
  ///
  /// Deliberately omits `additionalProperties` on object nodes, unlike
  /// [AnthropicProvider]'s unconditional `false` — **confirmed** (plan.md
  /// 4.4b, not just documented) that Gemini's schema rejects the field
  /// outright as unrecognized (`400 INVALID_ARGUMENT`, "Cannot find
  /// field"). This is not a weaker version of Anthropic's guarantee, it's
  /// an absent one: Gemini has no schema-level way to close an object to a
  /// known key set at all. Any code that folds a Gemini response's object
  /// keys into app state (4.5's per-experience/per-project id-keyed
  /// objects, specifically) must validate those keys against the known id
  /// set itself — the schema will not do it, for this provider only.
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
