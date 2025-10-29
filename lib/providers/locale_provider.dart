import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  
  Locale? get locale => _locale;
  
  LocaleProvider() {
    _loadLocaleFromPrefs();
  }
  
  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    _saveLocaleToPrefs();
    notifyListeners();
  }
  
  void clearLocale() {
    _locale = null;
    _clearLocaleFromPrefs();
    notifyListeners();
  }
  
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('am'),
    Locale('om'),
    Locale('so'),
    Locale('ti'),
  ];
  
  Future<void> _loadLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }
  
  Future<void> _saveLocaleToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_locale != null) {
      await prefs.setString('language_code', _locale!.languageCode);
    }
  }
  
  Future<void> _clearLocaleFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
  }
}
