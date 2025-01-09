import 'package:dio/dio.dart';
import 'package:flutunes/api/routes/_base.dart';
import 'package:flutunes/models/user.dart';
import 'package:flutunes/shared_preferences.dart';

class IncorrectCredentialsError extends Error {
  @override
  String toString() {
    return "Incorrect credentials";
  }
}

class Users extends BaseRoute {
  Users(super.client);

  Future<UserModel> authenticateByName(String username, String password) async {
    client.currentUser = UserModel(name: username, id: "", enableAutoLogin: false);
    final Response response = await client.request(
      "POST",
      (await client.baseUri()).replace(path: "/Users/AuthenticateByName"),
      json: {
        "Username": username,
        "Pw": password,
      },
    );

    if (response.statusCode == 401 || response.data["AccessToken"] == null) {
      client.currentUser = null;
      throw IncorrectCredentialsError();
    }

    client.accessToken = response.data["AccessToken"];
    await asyncPrefs.setString(PreferenceKeys.ACCESS_TOKEN.key, client.accessToken!);

    final authUser = UserModel.fromJson(response.data["User"]);
    await asyncPrefs.setString(PreferenceKeys.LAST_LOGGED_IN_USERNAME.key, authUser.name);
    await asyncPrefs.setBool(PreferenceKeys.SHOULD_AUTO_LOGIN.key, authUser.enableAutoLogin);

    client.currentUser = authUser;
    return authUser;
  }
}
