import 'package:flutunes/api/http.dart';
import 'package:flutunes/models/user.dart';
import 'package:flutunes/shared_preferences.dart';

class JellyfinClient {
  final Http http;

  JellyfinClient({Http? http}) : http = http ?? Http();

  Future<UserModel> login(
      String serverUrl, String username, String password) async {
    await asyncPrefs.setString(PreferenceKeys.SERVER_URL.key, serverUrl);
    return http.users.authenticateByName(username, password);
  }
}
