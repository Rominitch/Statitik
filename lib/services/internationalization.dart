import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StatitikLocale {
  StatitikLocale(this.locale);

  final Locale locale;

  static StatitikLocale of(BuildContext context) {
    return Localizations.of<StatitikLocale>(context, StatitikLocale);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'T0': 'Draw',
      'T1': 'Statistics',
      'T2': 'Settings',
    },
    'fr': {
      'T0': 'Tirage',
      'T1': 'Statistiques',
      'T2': 'Options',
    },
  };

  String read(String code) {
    return _localizedValues[locale.languageCode][code];
  }
}

class StatitikLocaleDelegate extends LocalizationsDelegate<StatitikLocale> {
  const StatitikLocaleDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<StatitikLocale> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    return SynchronousFuture<StatitikLocale>(StatitikLocale(locale));
  }

  @override
  bool shouldReload(StatitikLocaleDelegate old) => false;
}