import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userNameKey = 'user_name';
  static const String _userMobileKey = 'user_mobile';

  static AuthRepository? _instance;
  static AuthRepository get instance => _instance ??= AuthRepository._();
  AuthRepository._();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> login(String mobileOrEmail, String password, bool rememberMe) async {
    // Basic mock logic for now. 
    // In reality, this should check against saved credentials.
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool(_isLoggedInKey, true);
    }
  }

  Future<void> signup(String name, String mobile, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userMobileKey, mobile);
    await prefs.setBool(_isLoggedInKey, true); // Auto login after signup
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Farmer';
  }
}
