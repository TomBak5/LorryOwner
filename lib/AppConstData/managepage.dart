import 'package:shared_preferences/shared_preferences.dart';

class ManagePageCalling {
  setOnBoarding(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("IsOnBoaring", value);
  }

  setLogin(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isLogin", value);
  }
}
