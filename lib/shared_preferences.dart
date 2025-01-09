// ignore_for_file: constant_identifier_names
import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKeys {
  SERVER_URL("SERVER_URL");

  final String key;

  const PreferenceKeys(this.key);

  @override
  String toString() {
    return key;
  }
}

final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
