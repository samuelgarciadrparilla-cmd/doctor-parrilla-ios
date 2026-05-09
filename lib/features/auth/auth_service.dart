import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String keyUserPhone = 'user_phone';

  Future<String?> getSavedPhone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserPhone);
  }

  Future<void> savePhone(String phone) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUserPhone, phone);
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyUserPhone);
  }
}
