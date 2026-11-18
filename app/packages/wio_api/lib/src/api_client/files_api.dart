// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:http/http.dart' as _i7;
import 'package:tonik_util/tonik_util.dart' as _i5;
import 'package:wio_api/src/operation/get_file_state.dart' as _i2;
import 'package:wio_api/src/operation/put_file_chunk.dart' as _i3;
import 'package:wio_api/src/response_wrapper/get_file_state_response.dart'
    as _i6;
import 'package:wio_api/src/response_wrapper/put_file_chunk_response.dart'
    as _i8;
import 'package:wio_api/src/server/server.dart' as _i1;

/// Resumable upload of pictures and audio (D-96)
class FilesApi {
  FilesApi(_i1.Server server)
    : _getFileState = _i2.GetFileState(server.baseUrl, () => server.client),
      _putFileChunk = _i3.PutFileChunk(server.baseUrl, () => server.client);

  final _i2.GetFileState _getFileState;

  final _i3.PutFileChunk _putFileChunk;

  /// How much of a file the server holds in this workspace
  /// Files are kept per workspace; this never tells whether another workspace holds the same file. An unknown file answers 0 bytes.
  /// [sha256] Lower-case hex SHA-256 of the whole file.
  /// [wioAppVersion] Version of the app that sends the request (D-140), from its build. Only major.minor.patch is compared; +build is ignored (D-141). Missing: accepted. Malformed: 400 `invalid_request`. Below the server's minimum: 426 `upgrade_required` (D-142).
  _i4.Future<_i5.TonikResult<_i6.GetFileStateResponse, _i7.Response>>
  getFileState({
    required _i4.String sha256,
    _i4.String? wioAppVersion,
    _i5.TonikCancellation? cancellation,
  }) async => this._getFileState(
    sha256: sha256,
    wioAppVersion: wioAppVersion,
    cancellation: cancellation,
  );

  /// Upload one chunk of a file, resumable and idempotent
  /// Chunks of at most 4 MiB in order, each with `Content-Range`. When the last byte arrives the server checks the SHA-256 and answers 200; a mismatch discards the partial file (422). A chunk that does not start at the received size answers 409 with the size to resume from.
  /// [sha256] Lower-case hex SHA-256 of the whole file.
  /// [wioAppVersion] Version of the app that sends the request (D-140), from its build. Only major.minor.patch is compared; +build is ignored (D-141). Missing: accepted. Malformed: 400 `invalid_request`. Below the server's minimum: 426 `upgrade_required` (D-142).
  _i4.Future<_i5.TonikResult<_i8.PutFileChunkResponse, _i7.Response>>
  putFileChunk({
    required _i5.TonikFile body,
    required _i4.String sha256,
    required _i4.String contentRange,
    _i4.String? wioAppVersion,
    _i5.TonikCancellation? cancellation,
  }) async => this._putFileChunk(
    body: body,
    sha256: sha256,
    contentRange: contentRange,
    wioAppVersion: wioAppVersion,
    cancellation: cancellation,
  );
}
