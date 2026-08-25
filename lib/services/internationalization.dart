/*
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {

    'fr': ,
  };

  String read(String code) {
    assert( _localizedValues.containsKey(locale.languageCode) );
    var dict = _localizedValues[locale.languageCode];
    if(dict != null) {
      var s = dict[code];
      return s ?? "";
    }
    return "";
  }

  void setLocale(Locale language) {
    locale = language;
    SharedPreferences.getInstance().then( (prefs) {
      prefs.setString('appLocale', language.languageCode);
    });
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    var prefs = await SharedPreferences.getInstance();
    String? languageLocale = prefs.getString('appLocale');
    return SynchronousFuture<AppLocalizations>(AppLocalizations(
        languageLocale != null ? Locale(languageLocale) : locale)
    );
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}*/