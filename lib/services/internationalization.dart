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
      'SE_T': 'Expansion\'s statistics',
      'SE_B0': 'Cards distribution',
      'SE_B1': 'Rate by card',
      'DC_B0': 'Welcome on draw registration wizard.\n\nThanks to fill properly data the most right possible in order to help community.',
      'DC_B1': 'Start',
      'DC_B2': 'Tips:',
      'DC_B3': 'Long press offer more options for cards or boosters !',
      'DC_B4': 'Sign In',
      'DC_B5': 'With signin, you can:',
      'DC_B6': 'Register your draw',
      'DC_B7': 'Compare your statistics with other members of community',
      'DC_B8': 'With signin, you must agree with :',
      'DC_B9': 'UID registration in our database',
      'S_B0': 'Expansion',
      'S_B1': 'No result',
      'S_B2': 'Start by selecting an expansion',
      'S_B3': 'Expansion data are not existing for now: statistics are limited.',
      'S_B4': 'Booster',
      'S_B5': '%d whose %d with anomaly',
      'S_B6': 'Distribution for %d cards',
      'S_B7': 'Details of expansion',
      'S_B8': 'Help us by record yours draws !',
      'S_B9': 'All products',
      'S_B10': 'Show difference',
      'S_B11': 'Shared',
      'S_B12': 'Energies\' distribution',
      'S_B13': '%d registred',
      'S_B14': 'My report',
      'yes':    'Yes',
      'cancel': 'Cancel',
      'warning': 'Warning',
      'delete': 'Delete',
      'deconnexion': 'Sign Out',
      'confirm': "Confirm",
      'retry': 'Retry',
      'ok': 'Ok',
      'loading': 'Loading...',
      'send': 'Send',
      'error': 'Error',
      'help': 'Help',
      'V_B0': 'Data will be reboot.',
      'V_B1': 'Do you want to continue ?',
      'V_B2': 'Booster\'s edition',
      'V_B3': 'Change expansion',
      'V_B4': 'Kind of card',
      'V_B5': 'SignIn with Google account',
      'O_B0': 'Remove your account',
      'O_B1': 'Refresh database',
      'O_B2': 'Debug mode',
      'O_B3': 'Thanks',
      'O_B4': 'Support',
      'O_B5': 'About',
      'O_B6': 'Respecting European rules, you have the right to oblivion.\n',
      'O_B7': 'UID removing inside our database is an irreversible action, you will not able to access to your draw.\n',
      'O_B8': 'Do you want to remove your account ?\n',
      'L_T0': 'Language',
      'LO_B0': 'Database connection is impossible.\nCheck your internet access.',
      'TB_B0': 'Booster is not conform ?',
      'TB_B1': 'Example: card\'s number is not correct',
      'TP_T0': 'Products',
      'TP_B0': 'Products are not available',
      'TP_B1': '''If your product is not registered, use many boosters or send us a message.

`Orange` products contain randomized boosters.''',
      'TP_B2': 'Select',
      'TR_B0': 'Error of product creation',
      'TR_B1': 'Registration validated',
      'TR_B2': 'Thanks for your contribution !',
      'TR_B3': 'Registration is not granted.\nCheck your internet access and retry !',
      'TR_B4': ' Check multiple expansions',
      'TR_B5': 'Product is not conform ?',
      'TR_B6': 'Example: My boosters\' number is not correct',
      'EP_B0': 'Please select an expansion\'s booster inside your product.',
      'EP_B1': 'Show names',
      'SU_B0': 'To demand improvement or register bugs:',
      'SU_B1': 'For others demands, contact us:',
      'SU_B2': 'You can also support us financially:',
      'TH_B0': 'A big thanks to members of Pokécardex for help :',
      'disclaimer_T0': 'Disclaimer',
      'disclaimer': ''' is not an official Pokémon application, it is not affiliated, endorsed or supported by Nintendo, GAME FREAK or The Pokémon Company.
Images and illustrations used are the property of their respective authors.
© 2021 Pokémon. © 1995–2021 Nintendo/Creatures Inc./GAME FREAK inc. Pokémon and Pokémon character names are trademarks of Nintendo.''',
      'DB_0': 'Impossible to connect.',
      'DB_1': 'Software is too old. Please update.',
      'RE_B0': 'Best cards',
      'RE_B1': 'Shared',
      'RE_B2': 'Report is saved into Pictures.',
      'CAT_1': 'Base',
      'CAT_2': 'Pack',
      'CAT_3': 'Coffret',
      'CAT_4': 'Pokebox',
      'CAT_5': 'Mini Tin',
      'CAT_6': 'Elite Training Box',
      'CAT_7': 'Chest',
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
      'DC_B5': 'En vous connectant, vous pouvez :',
      'DC_B6': 'Enregistrer vos tirages',
      'DC_B7': 'Comparer vos statistiques avec celles de la communauté',
      'DC_B8': 'En vous connectant, vous acceptez :',
      'DC_B9': 'la sauvegarde de votre UID dans notre base de données',
      'S_B0': 'Extension',
      'S_B1': 'Aucun résultat',
      'S_B2': 'Commencez en choisissant une extension',
      'S_B3': 'Les données de l\'extension ne sont pas encore présentes : les statistiques sont limitées.',
      'S_B4': 'Booster',
      'S_B5': '%d dont %d avec anomalie',
      'S_B6': 'Répartition pour %d cartes',
      'S_B7': 'Détails de l\'extension',
      'S_B8': 'Aidez-nous en enregistrant vos tirages !',
      'S_B9': 'Tous les produits',
      'S_B10': 'Afficher la différence',
      'S_B11': 'Partager',
      'S_B12': 'Répartition des énergies',
      'S_B13': '%d enregistrés',
      'S_B14': 'Mon rapport',
      'yes':    'Oui',
      'cancel': 'Annuler',
      'warning': 'Attention',
      'delete': 'Supprimer',
      'deconnexion': 'Deconnexion',
      'confirm': "Confirmer",
      'retry': 'Réessayer',
      'ok': 'Ok',
      'loading': 'Chargement...',
      'send': 'Envoyer',
      'error': 'Erreur',
      'help': 'Aide',
      'V_B0': 'Les données seront réinitialisées.',
      'V_B1': 'Voulez-vous continuer ?',
      'V_B2': 'Edition du booster',
      'V_B3': 'Changer l\'extension',
      'V_B4': 'Type de carte',
      'V_B5': 'Connexion avec Google',
      'O_B0': 'Suppression du compte',
      'O_B1': 'Actualiser la base de données',
      'O_B2': 'Mode debug',
      'O_B3': 'Remerciement',
      'O_B4': 'Support',
      'O_B5': 'A propos',
      'O_B6': 'Conformement à la réglementation en rigeur, vous avez le droit à l\'oubli.\n',
      'O_B7': 'La suppression de votre UID dans la base de données est irréversible, vous ne pourrez plus jamais accéder à vos tirages.\n',
      'O_B8': 'Voulez-vous supprimer votre compte ?\n',
      'L_T0': 'Langue',
      'LO_B0': 'Connexion à la base de données impossible.\nVérifier votre connexion.',
      'TB_B0': 'Le booster n\'est pas conforme ?',
      'TB_B1': 'Exemple: le nombre de cartes n\'est pas correct',
      'TP_T0': 'Produits',
      'TP_B0': 'Aucun produit n\'est disponible',
      'TP_B1': '''Si votre produit n\'est pas référencé, utiliser plusieurs boosters ou signaler-le nous.

Les produits `oranges` possèdent des boosters aléatoires.''',
      'TP_B2': 'Sélectionner',
      'TR_B0': 'Erreur de création du produit',
      'TR_B1': 'Enregistrement validé',
      'TR_B2': 'Merci pour votre participation !',
      'TR_B3': 'L\'envoi des données n\'a pu être fait.\nVérifier votre connexion et réessayer !',
      'TR_B4': ' Attention aux diverses extensions',
      'TR_B5': 'Le produit n\'est pas conforme ?',
      'TR_B6': 'Exemple: il n\'y a pas le bon nombre de boosters',
      'EP_B0': 'Veuillez choisir l\'extension d\'un booster de votre produit.',
      'EP_B1': 'Afficher les noms',
      'SU_B0': 'Pour des demandes d\'améliorations ou signaler des bugs:',
      'SU_B1': 'Pour d\'autres demandes, contactez-nous:',
      'SU_B2': 'Vous pouvez aussi nous soutenir financièrement:',
      'TH_B0': 'Un grand merci aux membres de Pokécardex pour leur aide et soutien :',
      'disclaimer_T0': 'Disclaimer',
      'disclaimer': ''' n\'est pas une application officielle Pokémon, elle n\'est en aucun cas affiliée, approuvée ou supportée par Nintendo, GAME FREAK ou The Pokémon Company.
Elle est à but non-lucratif, créé par et pour des fans de Pokémon.

Les personnages, le thème "Pokémon ®" et ses marques dérivées sont propriétés de © Nintendo, The Pokémon Company, Game Freak, Creatures.
Les images et illustrations utilisées sont la propriété de leurs auteurs respectifs.
© 2021 Pokémon. © 1995–2021 Nintendo/Creatures Inc./GAME FREAK inc. Pokémon et les noms des personnages Pokémon sont des marques de Nintendo.''',
      'DB_0': 'Impossible de se connecter à la base de données.',
      'DB_1': 'Le programme est trop vieux. Installez les mises à jour.',
      'NP_T0': 'Nouveau produit',
      'RE_B0': 'Meilleures cartes',
      'RE_B1': 'Partage',
      'RE_B2': 'Le rapport a été exporté dans Images.',
      'CAT_1': 'Base',
      'CAT_2': 'Pack',
      'CAT_3': 'Coffret',
      'CAT_4': 'Pokebox',
      'CAT_5': 'Mini Tin',
      'CAT_6': 'Coffret Dresseur d\'Elite',
      'CAT_7': 'Coffre',
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