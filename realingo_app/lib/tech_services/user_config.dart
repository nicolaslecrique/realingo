import 'package:shared_preferences/shared_preferences.dart';

class UserConfig {
  static Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String> getDefaultUserProgramUriOrNull() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("default_user_program_uri")) {
      return prefs.getString("default_user_program_uri");
    } else {
      return null;
    }
  }

  static Future<void> setDefaultUserProgramUri(String uri) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("default_user_program_uri", uri);
  }
}
