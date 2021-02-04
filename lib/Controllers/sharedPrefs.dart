import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<bool> saveUserName(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('userName', username);
  }

  static Future<bool> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('email', email);
  }

  static Future<bool> savePhoneNumber(String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('phoneNumber', phoneNumber);
  }

  static Future<bool> savePassword(String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('password', password);
  }

  static Future<bool> saveIsLogged(bool isLogged) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('isLogged', isLogged);
  }
}
