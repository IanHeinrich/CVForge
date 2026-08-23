import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:cv_forge/models/drive/drive_file_snapshot.dart';

/// Which stage of a Drive API call failed — mirrors [BackupFailure]/
/// [PdfExtractionFailure]'s precedent so `DriveSyncService` can react
/// differently (reauth vs. retry vs. give up) instead of treating every
/// failure the same way.
enum DriveApiFailure {
  /// A 401/403 — the access token is missing, expired, or the grant was
  /// revoked. `DriveSyncService` maps this straight to
  /// `DriveSyncStatus.needsReauth`.
  needsReauth,

  /// The file (or, for [DriveApiClientService.fetchMetadata]/
  /// [DriveApiClientService.downloadFile], the id passed in) doesn't
  /// exist — e.g. the user deleted it from `appDataFolder` out of band,
  /// or disconnected the app from their Google Account settings, which
  /// deletes every appDataFolder file Drive-side.
  notFound,

  /// No response at all — offline, DNS failure, timeout. Worth retrying
  /// later without necessarily surfacing an error to the user immediately.
  network,

  /// Anything else — an unexpected status code or response shape.
  unknown,
}

/// Wraps whatever a failed Drive REST call threw, tagged with [failure] so
/// `DriveSyncService` can classify it without inspecting a raw
/// [DioException].
class DriveApiException implements Exception {
  const DriveApiException(this.failure, [this.cause]);

  final DriveApiFailure failure;
  final Object? cause;

  @override
  String toString() => 'DriveApiException(failure: $failure, cause: $cause)';
}

/// A thin wrapper over the four Google Drive v3 REST calls this feature
/// needs — deliberately not the `googleapis` package (a very large
/// dependency for four endpoints) and deliberately not aware of
/// `CvBackupBundle` itself: every method here takes/returns a plain
/// `Map<String, dynamic>`, the same decoded-JSON shape
/// `CvBackupBundle.fromJson`/`.toJson()` already produce, so this class
/// has no reason to import anything from `lib/models/` besides the small
/// [DriveFileSnapshot] metadata type. `DriveSyncService` owns the mapping
/// to/from `CvBackupBundle` itself.
///
/// Every call operates on the single, hidden `appDataFolder` file this
/// feature ever touches — never any of the user's real Drive files (the
/// `drive.appdata` scope structurally can't reach those at all).
///
/// Pure Dart, fully VM-testable — unlike `GoogleAuthService`, this needs
/// no `dart:js_interop` (an access token is just a bearer string by the
/// time it reaches here), so it's registered normally through
/// `app.dart`'s `@StackedApp` dependencies list.
class DriveApiClientService {
  /// [client] is a test seam — production code always uses the default.
  /// Shorter timeouts than `LlmService`'s: a Drive metadata/media call is
  /// a small JSON payload, not a long-running generation request.
  DriveApiClientService({Dio? client})
    : _client =
          client ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  final Dio _client;

  static const _fileName = 'cvforge-vault.json';
  static const _baseUrl = 'https://www.googleapis.com/drive/v3';
  static const _uploadBaseUrl = 'https://www.googleapis.com/upload/drive/v3';
  static const _metadataFields = 'id,version,modifiedTime';

  /// The signed-in Google account's email, for "Connected as …" copy —
  /// costs no extra OAuth scope beyond `drive.appdata` (`about.get`
  /// accepts it).
  Future<String?> fetchAccountEmail(String accessToken) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '$_baseUrl/about',
        queryParameters: const {'fields': 'user'},
        options: _authOptions(accessToken),
      );
      final user = response.data?['user'] as Map<String, dynamic>?;
      return user?['emailAddress'] as String?;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Looks up this feature's one file by name within `appDataFolder`.
  /// Returns `null` when it doesn't exist yet (first connect on this
  /// Google account) — not an error.
  Future<DriveFileSnapshot?> findFile(String accessToken) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '$_baseUrl/files',
        queryParameters: {
          'spaces': 'appDataFolder',
          'q': "name='$_fileName' and trashed=false",
          'fields': 'files($_metadataFields)',
          'pageSize': 1,
        },
        options: _authOptions(accessToken),
      );
      final files = (response.data?['files'] as List?) ?? const [];
      if (files.isEmpty) return null;
      return _snapshotFromJson(files.first as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Creates this feature's file in `appDataFolder` for the first time —
  /// [json] is sent as a `multipart/related` body (Drive's own upload
  /// convention for setting metadata and content together), not the
  /// simpler `uploadType=media` [updateFile] uses, since a create call is
  /// also the one place `name`/`parents` get set.
  Future<DriveFileSnapshot> createFile(
    String accessToken,
    Map<String, dynamic> json,
  ) async {
    const boundary = 'cvforge_backup_boundary';
    final metadata = jsonEncode({
      'name': _fileName,
      'parents': ['appDataFolder'],
    });
    final content = jsonEncode(json);
    final body =
        '--$boundary\r\n'
        'Content-Type: application/json; charset=UTF-8\r\n\r\n'
        '$metadata\r\n'
        '--$boundary\r\n'
        'Content-Type: application/json\r\n\r\n'
        '$content\r\n'
        '--$boundary--';
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '$_uploadBaseUrl/files',
        queryParameters: const {
          'uploadType': 'multipart',
          'fields': _metadataFields,
        },
        data: body,
        options: Options(
          headers: {
            ..._authOptions(accessToken).headers!,
            'Content-Type': 'multipart/related; boundary=$boundary',
          },
        ),
      );
      return _snapshotFromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Downloads and decodes the file's content — `alt=media` returns the
  /// raw bytes rather than a metadata object, and since this file was
  /// always written as `application/json`, Dio decodes it straight to a
  /// `Map` rather than handing back a raw byte/string body to parse here.
  Future<Map<String, dynamic>> downloadFile(
    String accessToken,
    String fileId,
  ) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '$_baseUrl/files/$fileId',
        queryParameters: const {'alt': 'media'},
        options: _authOptions(accessToken),
      );
      return response.data!;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Overwrites the file's content in place — `uploadType=media` only
  /// touches content, never `name`/`parents`, which is exactly right
  /// here since neither ever changes after [createFile].
  Future<DriveFileSnapshot> updateFile(
    String accessToken,
    String fileId,
    Map<String, dynamic> json,
  ) async {
    try {
      final response = await _client.patch<Map<String, dynamic>>(
        '$_uploadBaseUrl/files/$fileId',
        queryParameters: const {
          'uploadType': 'media',
          'fields': _metadataFields,
        },
        data: jsonEncode(json),
        options: Options(
          headers: {
            ..._authOptions(accessToken).headers!,
            'Content-Type': 'application/json',
          },
        ),
      );
      return _snapshotFromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Metadata only, no content download — what `DriveSyncService`'s
  /// startup/idle reconciliation checks first, so it can tell "nothing
  /// changed remotely" from "another device wrote since our last sync"
  /// without paying for a full download every time.
  Future<DriveFileSnapshot> fetchMetadata(
    String accessToken,
    String fileId,
  ) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '$_baseUrl/files/$fileId',
        queryParameters: const {'fields': _metadataFields},
        options: _authOptions(accessToken),
      );
      return _snapshotFromJson(response.data!);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Options _authOptions(String accessToken) =>
      Options(headers: {'Authorization': 'Bearer $accessToken'});

  DriveFileSnapshot _snapshotFromJson(Map<String, dynamic> json) =>
      DriveFileSnapshot(
        fileId: json['id'] as String,
        // Google's int64-as-string wire convention — [version] can
        // exceed 2^53 over a file's lifetime, so it's never a bare JSON
        // number.
        version: _parseVersion(json['version']),
        modifiedTime: DateTime.parse(json['modifiedTime'] as String),
      );

  int _parseVersion(Object? value) =>
      value is String ? int.parse(value) : (value as num).toInt();

  DriveApiException _mapError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return DriveApiException(DriveApiFailure.needsReauth, e);
    }
    if (status == 404) return DriveApiException(DriveApiFailure.notFound, e);
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DriveApiException(DriveApiFailure.network, e);
      default:
        return DriveApiException(DriveApiFailure.unknown, e);
    }
  }
}
