import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleModel extends ChangeNotifier {
  Locale? _locale;
  final SharedPreferences _prefs;

  LocaleModel(this._prefs) {
    var selectedLocale = _prefs.getString("selectLocaleLanguage");
    if (selectedLocale != null) {
      _locale = Locale(selectedLocale);
    } else {
      _locale = const Locale('en', 'US');
    }
  }

  Locale? get locale => _locale;

  void set(Locale? locale) {
    _locale = locale;
    _prefs.setString('selectLocaleLanguage', locale.toString());

    notifyListeners();
  }
}
