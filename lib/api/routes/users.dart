import 'package:dio/dio.dart';
import 'package:flutunes/api/routes/_base.dart';
import 'package:flutunes/models/user.dart';

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
    final Response response = await client.request("POST", (await client.baseUri()).replace(path: "/Users/AuthenticateByName"), json: {
      "Username": username,
      "Pw": password,
    });

    if (response.statusCode == 401) {
      client.currentUser = null;
      throw IncorrectCredentialsError();
    }

    client.accessToken = response.data["AccessToken"];
    final authUser = UserModel.fromJson(response.data["User"]);

    client.currentUser = authUser;
    return authUser;
  }
}
