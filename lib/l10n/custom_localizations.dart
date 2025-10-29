import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Oromo Material Localizations
class OromoMaterialLocalizations extends DefaultMaterialLocalizations {
  const OromoMaterialLocalizations();

  @override
  String get openAppDrawerTooltip => 'Baafata app banuu';

  @override
  String get backButtonTooltip => 'Duubatti deebi\'u';

  @override
  String get closeButtonTooltip => 'Cufuu';

  @override
  String get deleteButtonTooltip => 'Haquu';

  @override
  String get moreButtonTooltip => 'Dabalata';

  @override
  String get searchFieldLabel => 'Barbaadi';

  @override
  String get okButtonLabel => 'TOLE';

  @override
  String get cancelButtonLabel => 'DHIISI';

  @override
  String get closeButtonLabel => 'CUFI';

  @override
  String get continueButtonLabel => 'ITI FUFI';

  @override
  String get copyButtonLabel => 'GARAGALCHI';

  @override
  String get cutButtonLabel => 'MURI';

  @override
  String get scanTextButtonLabel => 'Barreeffama scan godhi';

  @override
  String get lookUpButtonLabel => 'Ilaali';

  @override
  String get searchWebButtonLabel => 'Weeb keessaa barbaadi';

  @override
  String get shareButtonLabel => 'QOODDUU';

  @override
  String get pasteButtonLabel => 'MAXXANSI';

  @override
  String get selectAllButtonLabel => 'HUNDA FILI';

  @override
  String get viewLicensesButtonLabel => 'HAYYAMOOTA ILAALI';

  @override
  String get anteMeridiemAbbreviation => 'WD';

  @override
  String get postMeridiemAbbreviation => 'WB';

  @override
  String get timePickerDialogHelpText => 'YEROO FILI';

  @override
  String get timePickerHourLabel => 'Sa\'aatii';

  @override
  String get timePickerMinuteLabel => 'Daqiiqaa';

  @override
  String get invalidTimeLabel => 'Yeroo sirrii ta\'e galchi';

  @override
  String get dialModeButtonLabel => 'Gara akkaataa filannoo dial tti jijjiiri';

  @override
  String get inputTimeModeButtonLabel => 'Gara akkaataa galchaa barreeffamaa tti jijjiiri';

  @override
  String get datePickerHelpText => 'GUYYAA FILI';

  @override
  String get dateOutOfRangeLabel => 'Daangaa ala.';

  @override
  String get invalidDateFormatLabel => 'Bifa sirrii miti.';

  @override
  String get invalidDateRangeLabel => 'Hangii sirrii miti.';

  @override
  String get dateInputLabel => 'Guyyaa galchi';

  @override
  String get calendarModeButtonLabel => 'Gara kaalaandarii tti jijjiiri';

  @override
  String get inputDateModeButtonLabel => 'Gara galchaa tti jijjiiri';

  @override
  String get unspecifiedDate => 'Guyyaa';

  @override
  String get unspecifiedDateRange => 'Hangii guyyaa';

  @override
  String get dateSeparator => '/';

  @override
  String get saveButtonLabel => 'OLKAA\'I';

  @override
  String get dateRangeStartLabel => 'Guyyaa jalqabaa';

  @override
  String get dateRangeEndLabel => 'Guyyaa dhumaa';

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) => 'Guyyaa jalqabaa $formattedDate';

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) => 'Guyyaa dhumaa $formattedDate';

  @override
  String get selectedRowCountTitleOne => '1 wanta filatame';

  @override
  String selectedRowCountTitle(int selectedRowCount) {
    if (selectedRowCount == 0) return 'Wanti hin filatamne';
    if (selectedRowCount == 1) return '1 wanta filatame';
    return '$selectedRowCount wantoota filataman';
  }

  @override
  String get rowsPerPageTitle => 'Toora fuula tokkotti:';

  @override
  String tabLabel({required int tabIndex, required int tabCount}) {
    return 'Caancala $tabIndex kan $tabCount keessaa';
  }

  @override
  String get refreshIndicatorSemanticLabel => 'Haaromsi';

  @override
  String get expandedIconTapHint => 'Qunnamtii';

  @override
  String get collapsedIconTapHint => 'Babal\'isi';

  @override
  String remainingTextFieldCharacterCount(int remaining) {
    if (remaining == 0) return 'Arfiin hin hafe';
    if (remaining == 1) return '1 arfii hafe';
    return '$remaining arfiiwwan hafan';
  }
}

class OromoMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const OromoMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(const OromoMaterialLocalizations());
  }

  @override
  bool shouldReload(OromoMaterialLocalizationsDelegate old) => false;
}

// Oromo Cupertino Localizations
class OromoCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const OromoCupertinoLocalizations();

  @override
  String get alertDialogLabel => 'Akeekkachiisa';

  @override
  String get anteMeridiemAbbreviation => 'WD';

  @override
  String get postMeridiemAbbreviation => 'WB';

  @override
  String get copyButtonLabel => 'Garagalchi';

  @override
  String get cutButtonLabel => 'Muri';

  @override
  String get pasteButtonLabel => 'Maxxansi';

  @override
  String get selectAllButtonLabel => 'Hunda Fili';

  @override
  String get datePickerDateOrderString => 'mdy';

  @override
  String get datePickerDateTimeOrderString => 'date_time_dayPeriod';

  @override
  String get modalBarrierDismissLabel => 'Dhiisi';

  @override
  String get searchTextFieldPlaceholderLabel => 'Barbaadi';

  @override
  String get todayLabel => 'Har\'a';
}

class OromoCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const OromoCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'om';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const OromoCupertinoLocalizations());
  }

  @override
  bool shouldReload(OromoCupertinoLocalizationsDelegate old) => false;
}

// Somali Material Localizations
class SomaliMaterialLocalizations extends DefaultMaterialLocalizations {
  const SomaliMaterialLocalizations();

  @override
  String get openAppDrawerTooltip => 'Fur qorshaha app-ka';

  @override
  String get backButtonTooltip => 'Dib u noqo';

  @override
  String get closeButtonTooltip => 'Xir';

  @override
  String get okButtonLabel => 'HAYE';

  @override
  String get cancelButtonLabel => 'JOOJI';

  @override
  String get closeButtonLabel => 'XIR';

  @override
  String get continueButtonLabel => 'SOCO';

  @override
  String get copyButtonLabel => 'KOOBII';

  @override
  String get cutButtonLabel => 'JAR';

  @override
  String get pasteButtonLabel => 'DHIG';

  @override
  String get selectAllButtonLabel => 'DHAMMAAN DOORO';
}

class SomaliMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const SomaliMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(const SomaliMaterialLocalizations());
  }

  @override
  bool shouldReload(SomaliMaterialLocalizationsDelegate old) => false;
}

class SomaliCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const SomaliCupertinoLocalizations();

  @override
  String get alertDialogLabel => 'Digniin';

  @override
  String get copyButtonLabel => 'Koobii';

  @override
  String get cutButtonLabel => 'Jar';

  @override
  String get pasteButtonLabel => 'Dhig';

  @override
  String get selectAllButtonLabel => 'Dhammaan Dooro';

  @override
  String get modalBarrierDismissLabel => 'Jooji';

  @override
  String get searchTextFieldPlaceholderLabel => 'Raadi';

  @override
  String get todayLabel => 'Maanta';
}

class SomaliCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const SomaliCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'so';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const SomaliCupertinoLocalizations());
  }

  @override
  bool shouldReload(SomaliCupertinoLocalizationsDelegate old) => false;
}

// Tigrinya Material Localizations
class TigrinyaMaterialLocalizations extends DefaultMaterialLocalizations {
  const TigrinyaMaterialLocalizations();

  @override
  String get openAppDrawerTooltip => 'ናይ መተግበሪ መስኮት ክፈት';

  @override
  String get backButtonTooltip => 'ናብ ድሕሪት ተመለስ';

  @override
  String get closeButtonTooltip => 'ዕጸው';

  @override
  String get okButtonLabel => 'እወ';

  @override
  String get cancelButtonLabel => 'ሰርዝ';

  @override
  String get closeButtonLabel => 'ዕጸው';

  @override
  String get continueButtonLabel => 'ቀጽል';

  @override
  String get copyButtonLabel => 'ቅዳሕ';

  @override
  String get cutButtonLabel => 'ቁረጽ';

  @override
  String get pasteButtonLabel => 'ለጽቅ';

  @override
  String get selectAllButtonLabel => 'ኩሉ ምረጽ';
}

class TigrinyaMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const TigrinyaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture<MaterialLocalizations>(const TigrinyaMaterialLocalizations());
  }

  @override
  bool shouldReload(TigrinyaMaterialLocalizationsDelegate old) => false;
}

class TigrinyaCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const TigrinyaCupertinoLocalizations();

  @override
  String get alertDialogLabel => 'መጠንቀቕታ';

  @override
  String get copyButtonLabel => 'ቅዳሕ';

  @override
  String get cutButtonLabel => 'ቁረጽ';

  @override
  String get pasteButtonLabel => 'ለጽቅ';

  @override
  String get selectAllButtonLabel => 'ኩሉ ምረጽ';

  @override
  String get modalBarrierDismissLabel => 'ሰርዝ';

  @override
  String get searchTextFieldPlaceholderLabel => 'ደልይ';

  @override
  String get todayLabel => 'ሎሚ';
}

class TigrinyaCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const TigrinyaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ti';

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<CupertinoLocalizations>(const TigrinyaCupertinoLocalizations());
  }

  @override
  bool shouldReload(TigrinyaCupertinoLocalizationsDelegate old) => false;
}
