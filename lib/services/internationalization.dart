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
      'H_T0': 'Draw',
      'H_T1': 'Statistics',
      'H_T2': 'Settings',
      'SE_T': 'Statistiques de l\'extension',
      'SE_B0': 'Répartition des cartes',
      'SE_B1': 'Fréquence par carte',
      'DC_B0': 'Bienvenue sur l\'enregistrement des tirages.\n\nMerci de rentrer les informations les plus justes possibles afin d\'aider la communauté.',
      'DC_B1': 'Commencer',
      'DC_B2': 'Astuces:',
      'DC_B3': 'Le clique long vous offre plus d\'options pour vos cartes ou boosters !',
      'DC_B4': 'Connexion',
      'DC_B5': 'En vous connectant, vous pouvez:',
      'DC_B6': 'Enregistrer vos tirages',
      'DC_B7': 'Comparer vos statistiques avec celles de la communauté',
      'DC_B8': 'En vous connectant, vous acceptez :',
      'DC_B9': 'la sauvegarde de votre UID dans notre base de données',
    },
    'fr': {
      'H_T0': 'Tirage',
      'H_T1': 'Statistiques',
      'H_T2': 'Options',
      'SE_T': 'Statistiques de l\'extension',
      'SE_B0': 'Répartition des cartes',
      'SE_B1': 'Fréquence par carte',
      'DC_B0': 'Bienvenue sur l\'enregistrement des tirages.\n\nMerci de rentrer les informations les plus justes possibles afin d\'aider la communauté.',
      'DC_B1': 'Commencer',
      'DC_B2': 'Astuces:',
      'DC_B3': 'Le clique long vous offre plus d\'options pour vos cartes ou boosters !',
      'DC_B4': 'Connexion',
      'DC_B5': 'En vous connectant, vous pouvez:',
      'DC_B6': 'Enregistrer vos tirages',
      'DC_B7': 'Comparer vos statistiques avec celles de la communauté',
      'DC_B8': 'En vous connectant, vous acceptez :',
      'DC_B9': 'la sauvegarde de votre UID dans notre base de données',
      'S_B0': 'Extension',
      'S_B1': 'Aucun résultat',
      'S_B2': 'Sélectionner une extension',
      'S_B3': 'Les données de l\'extension ne sont pas encore présentes: les statistiques sont limitées.',
      'S_B4': 'Booster',
      'S_B5': '%d dont %d avec anomalie',
      'S_B6': 'Répartition pour 10 cartes',
      'S_B7': 'Détails de l\'extension',
    },
  };

  String read(String code) {
    assert( _localizedValues.containsKey(locale.languageCode) );
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