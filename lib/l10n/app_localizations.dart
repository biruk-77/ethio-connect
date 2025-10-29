import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';
import 'app_localizations_so.dart';
import 'app_localizations_ti.dart';
import '_app_localizations_delegate.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('am'),
    Locale('om'),
    Locale('so'),
    Locale('ti')
  ];

  // Common
  String get appName;
  String get welcome;
  String get login;
  String get logout;
  String get email;
  String get password;
  String get confirmPassword;
  String get forgotPassword;
  String get register;
  String get cancel;
  String get save;
  String get delete;
  String get edit;
  String get loading;
  String get error;
  String get success;
  String get retry;
  
  // Login Screen
  String get loginTitle;
  String get loginSubtitle;
  String get emailHint;
  String get passwordHint;
  String get loginButton;
  String get dontHaveAccount;
  String get signUp;
  String get orContinueWith;
  String get googleLogin;
  String get facebookLogin;
  
  // Validation Messages
  String get emailRequired;
  String get emailInvalid;
  String get passwordRequired;
  String get passwordTooShort;
  String get passwordsDoNotMatch;
  
  // Settings
  String get settings;
  String get language;
  String get theme;
  String get darkMode;
  String get lightMode;
  String get systemMode;
  
  // Languages
  String get english;
  String get amharic;
  String get oromo;
  String get somali;
  String get tigrinya;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en', 'om', 'so', 'ti'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
    case 'om': return AppLocalizationsOm();
    case 'so': return AppLocalizationsSo();
    case 'ti': return AppLocalizationsTi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Check that your locale is supported '
    'by your AppLocalizations class and that the locale is listed in the supportedLocales.'
  );
}
