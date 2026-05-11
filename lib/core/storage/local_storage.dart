import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LocalStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  static Future<void> saveToken(String token) async {
    await _prefs?.setString(AppConstants.tokenKey, token);
  }

  static String? getToken() {
    return _prefs?.getString(AppConstants.tokenKey);
  }

  static Future<void> removeToken() async {
    await _prefs?.remove(AppConstants.tokenKey);
  }

  // Role
  static Future<void> saveRole(String role) async {
    await _prefs?.setString(AppConstants.roleKey, role);
  }

  static String? getRole() {
    return _prefs?.getString(AppConstants.roleKey);
  }

  // User Data (JSON string)
  static Future<void> saveUser(String userJson) async {
    await _prefs?.setString(AppConstants.userKey, userJson);
  }

  static String? getUser() {
    return _prefs?.getString(AppConstants.userKey);
  }

  // Clear All (logout)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  // Cek apakah sudah login
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
}