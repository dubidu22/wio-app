import 'dart:convert';

import 'package:wio_api/wio_api.dart';

/// What the device keeps after signing in (D-124): one entry in the token
/// store, nothing of it in the local database, logs or error texts (D-134).
class Session {
  const Session({
    required this.token,
    required this.deviceId,
    required this.user,
    required this.workspace,
    required this.apiBase,
  });

  /// Reads the stored entry; null when it is not a session this app wrote.
  static Session? tryDecode(String stored) {
    try {
      final json = jsonDecode(stored) as Map<String, Object?>;
      return Session(
        token: json['token']! as String,
        deviceId: json['device_id']! as String,
        user: MeUser.fromJson(json['user']),
        workspace: MeWorkspace.fromJson(json['workspace']),
        apiBase: json['api_base']! as String,
      );
    } on Object {
      return null;
    }
  }

  /// The device token; sent only by AuthClient (D-133).
  final String token;
  final String deviceId;
  final MeUser user;
  final MeWorkspace workspace;

  /// The server this token belongs to.
  final String apiBase;

  String encode() => jsonEncode(<String, Object?>{
    'token': token,
    'device_id': deviceId,
    'user': user.toJson(),
    'workspace': workspace.toJson(),
    'api_base': apiBase,
  });

  /// The same token with names fresh from getMe (D-129).
  Session withMe(Me me) => Session(
    token: token,
    deviceId: me.deviceId,
    user: me.user,
    workspace: me.workspace,
    apiBase: apiBase,
  );

  /// Never prints the token (D-134).
  @override
  String toString() => 'Session(device: $deviceId)';
}
