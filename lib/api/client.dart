import 'package:dio/dio.dart';
import 'package:flutunes/models/user.dart';
import 'package:flutunes/shared_preferences.dart';

const TEST_ROOT_URL = "http://jellyfin.test";
const BASE_HEADERS = {
  // TODO build a proper device signature, expect this in tests
  "Authorization": 'MediaBrowser Client="flutunes", Device="mobile", DeviceId="some-unique-id", Version="0.0.0"',
};

class JellyfinClient {
  String? accessToken;
  final Dio dio;

  JellyfinClient({Dio? dio}) : dio = dio ?? Dio(BaseOptions(headers: BASE_HEADERS)) {
    // TODO mock interceptors in tests
    // if (kDebugMode) dio?.interceptors.add(LogInterceptor(logPrint: (o) => debugPrint(o.toString())));
  }

  Future<String> serverUrl() async {
    return await asyncPrefs.getString("SERVER_URL") ?? TEST_ROOT_URL;
  }

  Future<UserModel> authenticateByName(String username, String password) async {
    final post = await dio.post(
      "${await serverUrl()}/Users/AuthenticateByName",
      data: {
        "Username": username,
        "Pw": password,
      },
    );
    final Map<String, dynamic> authResult = post.data;

    accessToken = authResult["AccessToken"]!;

    return UserModel.fromJson(authResult["User"]);
  }
}
