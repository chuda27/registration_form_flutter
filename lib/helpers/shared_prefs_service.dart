import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String getString(String key) {
    return prefs.getString(key) ?? '';
  }
}
