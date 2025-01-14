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
    try {
      final Response response = await client.request(
        "POST",
        (await client.baseUri()).replace(path: "/Users/AuthenticateByName"),
        json: {
          "Username": username,
          "Pw": password,
        },
      );
      client.accessToken = response.data["AccessToken"];
      await asyncPrefs.setString(PreferenceKeys.ACCESS_TOKEN.key, client.accessToken!);

      final authUser = UserModel.fromJson(response.data["User"]);
      await asyncPrefs.setString(PreferenceKeys.USERNAME.key, authUser.name);
      await asyncPrefs.setString(PreferenceKeys.USER_ID.key, authUser.id);
      await asyncPrefs.setBool(PreferenceKeys.SHOULD_AUTO_LOGIN.key, authUser.enableAutoLogin);

      client.currentUser = authUser;
      return authUser;
    } on DioException catch (error) {
      if (error.response != null && (error.response!.statusCode == 401 || (error.response!.data is Map && error.response!.data["AccessToken"] == null))) {
        client.currentUser = null;
        throw IncorrectCredentialsError();
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<UserModel> me() async {
    final response = await client.request(
      "GET",
      (await client.baseUri()).replace(path: "/Users/Me"),
    );
    return UserModel.fromJson(response.data);
  }
}
