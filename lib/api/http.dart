import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutunes/api/constants.dart';
import 'package:flutunes/api/routes/system.dart';
import 'package:flutunes/api/routes/users.dart';
import 'package:flutunes/models/user.dart';
import 'package:flutunes/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:uuid/uuid.dart';

class Http {
  final Dio dio;
  String? accessToken;
  UserModel? currentUser;

  late final System system;
  late final Users users;

  Http({Dio? dio}) : dio = dio ?? Dio() {
    system = System(this);
    users = Users(this);
  }

  Future<Uri> baseUri() async {
    // TODO refactor to not call asyncPrefs all the time
    return Uri.parse(await asyncPrefs.getString(PreferenceKeys.SERVER_URL.key) ?? TEST_ROOT_URL);
  }

  static Future<String> _getUniqueDeviceId(String username) async {
    final String? deviceId = await asyncPrefs.getString("DEVICE_ID");
    if (deviceId == null) {
      String? realDeviceId = "12345";
      try {
        realDeviceId = await PlatformDeviceId.getDeviceId;
      } on MissingPluginException {
        // Likely coming from test mode, do nothing
      }

      String newDeviceId = "${realDeviceId ?? Uuid().v4()}-$username";
      await asyncPrefs.setString("DEVICE_ID", newDeviceId);
      return newDeviceId.hashCode.toString();
    }
    return deviceId.hashCode.toString();
  }

  Future<String> buildAuthHeader(
    String username, {
    String? client = "flutunes",
    String? device,
  }) async {
    return 'MediaBrowser ${accessToken != null ? 'Token="$accessToken" ' : ""}Client="$client", Device="$device", '
        'DeviceId="${await _getUniqueDeviceId(username)}", Version="$VERSION"';
  }

  Future<Response<dynamic>> request(
    String method,
    Uri uri, {
    Map<String, dynamic>? json,
  }) async {
    if (currentUser == null) {
      throw StateError("currentUser not set. Have you logged in yet?");
    }

    return await dio.requestUri(
      uri,
      data: json,
      options: Options(
        method: method,
        headers: {"Authorization": await buildAuthHeader(currentUser!.name)},
      ),
    );
  }
}
