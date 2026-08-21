import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/models/llm/llm_json_response.dart';
import 'package:cv_forge/models/llm/llm_model_option.dart';
import 'package:cv_forge/models/llm/llm_usage.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm/llm_provider.dart';

/// Anthropic's Messages API, called directly from the browser — the
/// `anthropic-dangerous-direct-browser-access` header is what makes it
/// answer a browser's CORS preflight, the same thing the TypeScript SDK
/// sends behind `dangerouslyAllowBrowser`.
class AnthropicProvider implements LlmProvider {
  const AnthropicProvider();

  static const _baseUrl = 'https://api.anthropic.com/v1';
  static const _apiVersion = '2023-06-01';

  @override
  String get id => 'anthropic';

  @override
  String get displayName => 'Anthropic';

  /// USD per million tokens, from Anthropic's published rates as of
  /// 2026-08-21. These are rendered in Settings rather than only stored,
  /// so a stale number is visible rather than silently wrong — which is
  /// the only reason to keep a hardcoded price table at all. Re-check
  /// against Anthropic's pricing page when adding or changing a model.
  @override
  List<LlmModelOption> get models => const [
    LlmModelOption(
      id: 'claude-opus-5',
      label: 'Claude Opus 5',
      inputPricePerMTok: 5,
      outputPricePerMTok: 25,
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
      data = jsonDecode(textBlock['text'] as String) as Map<String, dynamic>;
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
    if (status != null) {
      // 403 sits with 401: both mean "this key may not do this", which is
      // the same thing for a user to act on. Every other 4xx is a request
      // this client built wrongly — reporting that as a network failure
      // ("check your connection") sends the user to debug the wrong thing.
      if (status == 401 || status == 403) {
        return LlmException(LlmFailure.unauthorized, e);
      }
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
}
