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
  String get displayName => 'Claude';

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

  /// Verified against Anthropic's live API docs on 2026-08-23, not
  /// recalled: the Console moved to `platform.claude.com`, so the older
  /// `console.anthropic.com` URLs a model is likely to remember are the
  /// wrong thing to send a user to. Re-check if either page 404s.
  @override
  Uri get apiKeyConsoleUrl =>
      Uri.parse('https://platform.claude.com/settings/keys');

  @override
  Uri get billingConsoleUrl =>
      Uri.parse('https://platform.claude.com/settings/billing');

  @override
  List<String> get apiKeySteps => const [
    'Sign in to the Claude Console and open Settings → API keys.',
    'Claude has no free API tier — add a small amount of prepaid credit '
        'under Settings → Billing before your first run.',
    'Create a key, then copy it. The Console shows it once and never '
        'again.',
    'Paste it above and press Test connection.',
  ];

  Map<String, String> _headers(String apiKey) => {
    'x-api-key': apiKey,
    'anthropic-version': _apiVersion,
    'content-type': 'application/json',
    'anthropic-dangerous-direct-browser-access': 'true',
  };

  /// Haiku 4.5 only supports the older manual `enabled`/`budget_tokens`
  /// thinking mode (or no thinking at all) — confirmed against Anthropic's
  /// docs: "If your model supports only extended thinking (Claude Sonnet
  /// 4.5, Claude Opus 4.5, Claude Haiku 4.5, and earlier Claude 4 models)
  /// ... type: 'adaptive' returns a 400 error." Sending `thinking:
  /// {"type": "adaptive"}` unconditionally, as every other model here
  /// wants, made every tailoring request against Haiku 4.5 fail with a
  /// 400 while `validateKey`'s GET (which never sends `thinking`) kept
  /// succeeding — the exact "test connection works, tailoring doesn't"
  /// split this set exists to prevent. Thinking is optional for a
  /// structured-JSON completion, so omitting it for these models is
  /// enough; there's no need to configure the older budget-based mode.
  static const _modelsWithoutAdaptiveThinking = {'claude-haiku-4-5'};

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
          if (!_modelsWithoutAdaptiveThinking.contains(modelId))
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

  /// 403 sits with 401: both mean "this key may not do this", which is the
  /// same thing for a user to act on. Everything else is the shared
  /// mapping.
  LlmException _mapDioException(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return LlmException(LlmFailure.unauthorized, e);
    }
    return mapLlmTransportError(e);
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
