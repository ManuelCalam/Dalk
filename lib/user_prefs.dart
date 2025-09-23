import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_provider.dart';

class UserPrefs {
  static const _key = "user_data";

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
