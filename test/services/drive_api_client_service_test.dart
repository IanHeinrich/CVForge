import 'dart:convert';
import 'dart:typed_data';

import 'package:cv_forge/models/drive/drive_file_snapshot.dart';
import 'package:cv_forge/services/drive_api_client_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Same minimal [HttpClientAdapter] test double as `llm_service_test.dart`
/// — no real network access, no extra mocking dependency. [handler]
/// decides the response (or throws a [DioException]) per call;
/// [lastOptions]/[lastBody] capture what [DriveApiClientService] actually
/// sent, for request-shape assertions.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  RequestOptions? lastOptions;
  String? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      if (bytes.isNotEmpty) lastBody = utf8.decode(bytes);
    }
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object body, int statusCode) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  group('DriveApiClientServiceTest -', () {
    test(
      'findFile returns null when appDataFolder has no matching file',
      () async {
        final adapter = _FakeAdapter(
          (_) async => _jsonResponse({'files': <Object?>[]}, 200),
        );
        final service = DriveApiClientService(
          client: Dio()..httpClientAdapter = adapter,
        );

        final result = await service.findFile('token');

        expect(result, isNull);
        expect(adapter.lastOptions?.headers['Authorization'], 'Bearer token');
        expect(adapter.lastOptions?.queryParameters['spaces'], 'appDataFolder');
      },
    );

    test(
      'findFile parses the first match, including a string-encoded version',
      () async {
        final adapter = _FakeAdapter(
          (_) async => _jsonResponse({
            'files': [
              {
                'id': 'file-1',
                'version': '42',
                'modifiedTime': '2026-01-02T03:04:05.000Z',
              },
            ],
          }, 200),
        );
        final service = DriveApiClientService(
          client: Dio()..httpClientAdapter = adapter,
        );

        final result = await service.findFile('token');

        expect(
          result,
          DriveFileSnapshot(
            fileId: 'file-1',
            version: 42,
            modifiedTime: DateTime.utc(2026, 1, 2, 3, 4, 5),
          ),
        );
      },
    );

    test('createFile sends a multipart/related body with the appDataFolder '
        'parent', () async {
      final adapter = _FakeAdapter(
        (_) async => _jsonResponse({
          'id': 'new-file',
          'version': '1',
          'modifiedTime': '2026-01-01T00:00:00.000Z',
        }, 200),
      );
      final service = DriveApiClientService(
        client: Dio()..httpClientAdapter = adapter,
      );

      final result = await service.createFile('token', {'app': 'cv-forge'});

      expect(result.fileId, 'new-file');
      expect(result.version, 1);
      expect(adapter.lastOptions?.queryParameters['uploadType'], 'multipart');
      expect(
        adapter.lastOptions?.headers['Content-Type'],
        contains('multipart/related'),
      );
      expect(adapter.lastBody, contains('appDataFolder'));
      expect(adapter.lastBody, contains('cv-forge'));
    });

    test(
      'updateFile PATCHes uploadType=media with a plain JSON body',
      () async {
        final adapter = _FakeAdapter(
          (_) async => _jsonResponse({
            'id': 'file-1',
            'version': '2',
            'modifiedTime': '2026-01-01T00:00:00.000Z',
          }, 200),
        );
        final service = DriveApiClientService(
          client: Dio()..httpClientAdapter = adapter,
        );

        final result = await service.updateFile('token', 'file-1', {'a': 1});

        expect(result.version, 2);
        expect(adapter.lastOptions?.method, 'PATCH');
        expect(adapter.lastOptions?.queryParameters['uploadType'], 'media');
        expect(jsonDecode(adapter.lastBody!), {'a': 1});
      },
    );

    test('downloadFile returns the decoded JSON body', () async {
      final adapter = _FakeAdapter(
        (_) async => _jsonResponse({'vault': null, 'drafts': <Object?>[]}, 200),
      );
      final service = DriveApiClientService(
        client: Dio()..httpClientAdapter = adapter,
      );

      final result = await service.downloadFile('token', 'file-1');

      expect(result, {'vault': null, 'drafts': <Object?>[]});
      expect(adapter.lastOptions?.queryParameters['alt'], 'media');
    });

    test('fetchAccountEmail reads user.emailAddress', () async {
      final adapter = _FakeAdapter(
        (_) async => _jsonResponse({
          'user': {'emailAddress': 'person@example.com'},
        }, 200),
      );
      final service = DriveApiClientService(
        client: Dio()..httpClientAdapter = adapter,
      );

      final email = await service.fetchAccountEmail('token');

      expect(email, 'person@example.com');
    });

    test('a 401 response maps to DriveApiFailure.needsReauth', () async {
      final adapter = _FakeAdapter(
        (options) async => throw DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
          type: DioExceptionType.badResponse,
        ),
      );
      final service = DriveApiClientService(
        client: Dio()..httpClientAdapter = adapter,
      );

      await expectLater(
        () => service.fetchMetadata('token', 'file-1'),
        throwsA(
          isA<DriveApiException>().having(
            (e) => e.failure,
            'failure',
            DriveApiFailure.needsReauth,
          ),
        ),
      );
    });

    test('a 404 response maps to DriveApiFailure.notFound', () async {
      final adapter = _FakeAdapter(
        (options) async => throw DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 404),
          type: DioExceptionType.badResponse,
        ),
      );
      final service = DriveApiClientService(
        client: Dio()..httpClientAdapter = adapter,
      );

      await expectLater(
        () => service.fetchMetadata('token', 'file-1'),
        throwsA(
          isA<DriveApiException>().having(
            (e) => e.failure,
            'failure',
            DriveApiFailure.notFound,
          ),
        ),
      );
    });

    test('a connection error maps to DriveApiFailure.network', () async {
      final adapter = _FakeAdapter(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        ),
      );
      final service = DriveApiClientService(
        client: Dio()..httpClientAdapter = adapter,
      );

      await expectLater(
        () => service.fetchMetadata('token', 'file-1'),
        throwsA(
          isA<DriveApiException>().having(
            (e) => e.failure,
            'failure',
            DriveApiFailure.network,
          ),
        ),
      );
    });
  });
}
