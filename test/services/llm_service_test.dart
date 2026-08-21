import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_forge/models/llm/json_schema.dart';
import 'package:cv_forge/services/llm/llm_exception.dart';
import 'package:cv_forge/services/llm_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A minimal [HttpClientAdapter] test double — no real network access, no
/// extra mocking dependency. [handler] decides the response (or throws a
/// [DioException]) per call; [lastOptions]/[lastBody] capture what
/// [LlmService] actually sent, for request-shape assertions.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  RequestOptions? lastOptions;
  Map<String, dynamic>? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      if (bytes.isNotEmpty) {
        lastBody = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      }
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> body, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

const _fixtureSchema = JsonSchema.object(
  properties: {'headline': JsonSchema.string()},
  required: ['headline'],
);

void main() {
  group('LlmServiceTest -', () {
    test('completeJson throws noKey without ever calling the network '
        'when apiKey is empty', () async {
      final adapter = _FakeAdapter(
        (_) async => throw StateError('should not be called'),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      await expectLater(
        () => service.completeJson(
          providerId: 'anthropic',
          modelId: 'claude-opus-5',
          apiKey: '',
          systemPrompt: 'system',
          userContent: 'user',
          schema: _fixtureSchema,
        ),
        throwsA(
          isA<LlmException>().having(
            (e) => e.failure,
            'failure',
            LlmFailure.noKey,
          ),
        ),
      );
      expect(adapter.lastOptions, isNull);
    });

    test('completeJson happy path sends the right model, headers, and '
        'translated schema, and parses usage + the JSON text block', () async {
      final adapter = _FakeAdapter(
        (_) async => _jsonResponse({
          'stop_reason': 'end_turn',
          'content': [
            {'type': 'text', 'text': '{"headline":"Backend Engineer"}'},
          ],
          'usage': {'input_tokens': 120, 'output_tokens': 40},
        }, 200),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      final response = await service.completeJson(
        providerId: 'anthropic',
        modelId: 'claude-opus-5',
        apiKey: 'sk-ant-test',
        systemPrompt: 'be helpful',
        userContent: 'tailor this',
        schema: _fixtureSchema,
      );

      expect(response.data, {'headline': 'Backend Engineer'});
      expect(response.usage.inputTokens, 120);
      expect(response.usage.outputTokens, 40);

      final options = adapter.lastOptions!;
      expect(options.path, 'https://api.anthropic.com/v1/messages');
      expect(options.headers['x-api-key'], 'sk-ant-test');
      expect(options.headers['anthropic-version'], '2023-06-01');
      expect(
        options.headers['anthropic-dangerous-direct-browser-access'],
        'true',
      );

      final body = adapter.lastBody!;
      expect(body['model'], 'claude-opus-5');
      expect(body['max_tokens'], 16000);
      expect(body['thinking'], {'type': 'adaptive'});
      expect(body['output_config'], {
        'format': {
          'type': 'json_schema',
          'schema': {
            'type': 'object',
            'properties': {
              'headline': {'type': 'string'},
            },
            'required': ['headline'],
            'additionalProperties': false,
          },
        },
      });
    });

    test('completeJson maps stop_reason "refusal" to LlmFailure.refusal, '
        'not malformedResponse', () async {
      final adapter = _FakeAdapter(
        (_) async => _jsonResponse({'stop_reason': 'refusal'}, 200),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      await expectLater(
        () => service.completeJson(
          providerId: 'anthropic',
          modelId: 'claude-opus-5',
          apiKey: 'sk-ant-test',
          systemPrompt: 's',
          userContent: 'u',
          schema: _fixtureSchema,
        ),
        throwsA(
          isA<LlmException>().having(
            (e) => e.failure,
            'failure',
            LlmFailure.refusal,
          ),
        ),
      );
    });

    test('completeJson maps a 200 with no usable content block to '
        'malformedResponse', () async {
      final adapter = _FakeAdapter(
        (_) async =>
            _jsonResponse({'stop_reason': 'end_turn', 'content': []}, 200),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      await expectLater(
        () => service.completeJson(
          providerId: 'anthropic',
          modelId: 'claude-opus-5',
          apiKey: 'sk-ant-test',
          systemPrompt: 's',
          userContent: 'u',
          schema: _fixtureSchema,
        ),
        throwsA(
          isA<LlmException>().having(
            (e) => e.failure,
            'failure',
            LlmFailure.malformedResponse,
          ),
        ),
      );
    });

    for (final failureCase in [
      (status: 401, expected: LlmFailure.unauthorized),
      (status: 429, expected: LlmFailure.rateLimited),
      (status: 500, expected: LlmFailure.overloaded),
      (status: 503, expected: LlmFailure.overloaded),
    ]) {
      test(
        'a ${failureCase.status} response maps to ${failureCase.expected}',
        () async {
          final adapter = _FakeAdapter((options) async {
            throw DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: failureCase.status,
              ),
              type: DioExceptionType.badResponse,
            );
          });
          final dio = Dio()..httpClientAdapter = adapter;
          final service = LlmService(client: dio);

          await expectLater(
            () => service.completeJson(
              providerId: 'anthropic',
              modelId: 'claude-opus-5',
              apiKey: 'sk-ant-test',
              systemPrompt: 's',
              userContent: 'u',
              schema: _fixtureSchema,
            ),
            throwsA(
              isA<LlmException>().having(
                (e) => e.failure,
                'failure',
                failureCase.expected,
              ),
            ),
          );
        },
      );
    }

    for (final dioType in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.sendTimeout,
    ]) {
      test('a $dioType maps to LlmFailure.timeout', () async {
        final adapter = _FakeAdapter(
          (options) async =>
              throw DioException(requestOptions: options, type: dioType),
        );
        final dio = Dio()..httpClientAdapter = adapter;
        final service = LlmService(client: dio);

        await expectLater(
          () => service.completeJson(
            providerId: 'anthropic',
            modelId: 'claude-opus-5',
            apiKey: 'sk-ant-test',
            systemPrompt: 's',
            userContent: 'u',
            schema: _fixtureSchema,
          ),
          throwsA(
            isA<LlmException>().having(
              (e) => e.failure,
              'failure',
              LlmFailure.timeout,
            ),
          ),
        );
      });
    }

    test('a connectionError maps to LlmFailure.network', () async {
      final adapter = _FakeAdapter(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      await expectLater(
        () => service.completeJson(
          providerId: 'anthropic',
          modelId: 'claude-opus-5',
          apiKey: 'sk-ant-test',
          systemPrompt: 's',
          userContent: 'u',
          schema: _fixtureSchema,
        ),
        throwsA(
          isA<LlmException>().having(
            (e) => e.failure,
            'failure',
            LlmFailure.network,
          ),
        ),
      );
    });

    test('testConnection calls GET /v1/models and spends no tokens '
        '(no message body sent)', () async {
      final adapter = _FakeAdapter(
        (_) async => ResponseBody.fromString(
          jsonEncode({'data': []}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      await service.testConnection('anthropic', 'sk-ant-test');

      expect(adapter.lastOptions!.path, 'https://api.anthropic.com/v1/models');
      expect(adapter.lastOptions!.method, 'GET');
    });

    test('testConnection throws noKey for an empty key', () async {
      final adapter = _FakeAdapter(
        (_) async => throw StateError('should not be called'),
      );
      final dio = Dio()..httpClientAdapter = adapter;
      final service = LlmService(client: dio);

      await expectLater(
        () => service.testConnection('anthropic', ''),
        throwsA(
          isA<LlmException>().having(
            (e) => e.failure,
            'failure',
            LlmFailure.noKey,
          ),
        ),
      );
    });
  });
}
