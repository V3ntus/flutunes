import 'package:flutunes/api/http.dart';
import 'package:flutunes/models/user.dart';

class JellyfinClient {
  final Http http;

  JellyfinClient({Http? http}) : http = http ?? Http();

  Future<UserModel> login(String username, String password) async {
    return http.users.authenticateByName(username, password);
  }
}
