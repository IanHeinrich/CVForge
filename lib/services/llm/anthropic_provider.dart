import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/models/llm/llm_usage.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';

/// The `anthropic-dangerous-direct-browser-access` header is what makes
/// the Messages API answer a browser's CORS preflight at all — the same
/// thing the TypeScript SDK sends behind `dangerouslyAllowBrowser`. This
/// is a real, documented, supported way to call the API directly from a
/// browser tab (see plan.md's 4.4 Step 0) — but it was verified here
/// against the public API docs, not against a live request with a real
/// key from an actual browser, since neither was available in this
/// session. Treat that live check as still outstanding until someone
/// with a key runs it once from the deployed app.
class AnthropicProvider implements LlmProvider {
  const AnthropicProvider();

  static const _baseUrl = 'https://api.anthropic.com/v1';
  static const _apiVersion = '2023-06-01';

  @override
  String get id => 'anthropic';

  @override
  String get displayName => 'Anthropic';

  // Rates checked 2026-08-21, per-million-token, USD. Anthropic's own
  // pricing page is the source of truth if these ever need re-checking.
  @override
  List<LlmModelOption> get models => const [
    LlmModelOption(
      id: 'claude-opus-5',
      label: 'Claude Opus 5',
      inputPricePerMTok: 15,
      outputPricePerMTok: 75,
    ),
    LlmModelOption(
      id: 'claude-sonnet-5',
      label: 'Claude Sonnet 5',
      inputPricePerMTok: 3,
      outputPricePerMTok: 15,
    ),
    LlmModelOption(
      id: 'claude-haiku-4-5',
      label: 'Claude Haiku 4.5',
      inputPricePerMTok: 1,
      outputPricePerMTok: 5,
    ),
  ];

  @override
  Uri get keySignupUrl =>
      Uri.parse('https://console.anthropic.com/settings/keys');

  Map<String, String> _headers(String apiKey) => {
    'x-api-key': apiKey,
    'anthropic-version': _apiVersion,
    'content-type': 'application/json',
    'anthropic-dangerous-direct-browser-access': 'true',
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
        '$_baseUrl/messages',
        options: Options(headers: _headers(apiKey)),
        data: {
          'model': modelId,
          'max_tokens': 16000,
          'thinking': {'type': 'adaptive'},
          'system': systemPrompt,
          'messages': [
            {'role': 'user', 'content': userContent},
          ],
          'output_config': {
            'format': {'type': 'json_schema', 'schema': _walkSchema(schema)},
          },
        },
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }

    final body = response.data;
    if (body == null) throw const LlmException(LlmFailure.malformedResponse);

    if (body['stop_reason'] == 'refusal') {
      throw const LlmException(LlmFailure.refusal);
    }

    final content = body['content'];
    if (content is! List || content.isEmpty) {
      throw const LlmException(LlmFailure.malformedResponse);
    }
    final textBlock = content.firstWhere(
      (block) => block is Map && block['type'] == 'text',
      orElse: () => null,
    );
    if (textBlock is! Map || textBlock['text'] is! String) {
      throw const LlmException(LlmFailure.malformedResponse);
    }

    final Map<String, dynamic> data;
    try {
      data = _decodeJsonObject(textBlock['text'] as String);
    } catch (e) {
      throw LlmException(LlmFailure.malformedResponse, e);
    }

    final usage = body['usage'];
    if (usage is! Map) throw const LlmException(LlmFailure.malformedResponse);
    return LlmJsonResponse(
      data: data,
      usage: LlmUsage(
        inputTokens: (usage['input_tokens'] as num?)?.toInt() ?? 0,
        outputTokens: (usage['output_tokens'] as num?)?.toInt() ?? 0,
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
    if (status == 401) return LlmException(LlmFailure.unauthorized, e);
    if (status == 429) return LlmException(LlmFailure.rateLimited, e);
    if (status != null && status >= 500) {
      return LlmException(LlmFailure.overloaded, e);
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return LlmException(LlmFailure.timeout, e);
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return LlmException(LlmFailure.network, e);
      default:
        return LlmException(LlmFailure.network, e);
    }
  }

  /// Walks the provider-agnostic [JsonSchema] into Anthropic's
  /// `output_config.format.schema` dialect. Every object node emits
  /// `additionalProperties: false` unconditionally — see [JsonSchema]'s
  /// own doc comment for why that isn't a field a caller can get wrong.
  Map<String, dynamic> _walkSchema(JsonSchema schema) => switch (schema) {
    JsonSchemaObject(:final properties, :final required) => {
      'type': 'object',
      'properties': properties.map((k, v) => MapEntry(k, _walkSchema(v))),
      'required': required,
      'additionalProperties': false,
    },
    JsonSchemaArray(:final items) => {
      'type': 'array',
      'items': _walkSchema(items),
    },
    JsonSchemaString() => {'type': 'string'},
    JsonSchemaStringEnum(:final values) => {'type': 'string', 'enum': values},
    JsonSchemaNumber() => {'type': 'number'},
    JsonSchemaBoolean() => {'type': 'boolean'},
  };

  Map<String, dynamic> _decodeJsonObject(String text) {
    final decoded = (jsonDecode(text));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object');
    }
    return decoded;
  }
}
