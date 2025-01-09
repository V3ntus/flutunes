// ignore_for_file: constant_identifier_names
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKeys {
  SERVER_URL(String, "SERVER_URL"),
  ACCESS_TOKEN(String, "ACCESS_TOKEN"),
  LAST_LOGGED_IN_USERNAME(String, "LAST_LOGGED_IN_USERNAME"),
  SHOULD_AUTO_LOGIN(bool, "SHOULD_AUTO_LOGIN");

  final Type type;
  final String key;

  const PreferenceKeys(this.type, this.key);

  @override
  String toString() {
    return key;
  }
}

final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
