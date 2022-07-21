import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatitikLocale {
  StatitikLocale(this.locale);

  Locale locale;

  static StatitikLocale of(BuildContext context) {
    return Localizations.of<StatitikLocale>(context, StatitikLocale)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'H_T0': 'PokéSpace',
      'H_T1': 'Expansions',
      'H_T2': 'Settings',
      'H_T3': 'Cards',
      'H_T4': 'Dashboard',
      'SE_T': 'Expansion\'s statistics',
      'SE_B0': 'Cards distribution',
      'SE_B1': 'Rate by card',
      'SE_B2': 'Number of cards:',
      'SE_B3': 'card',
      'SE_B4': 'secrets',
      'SE_B5': 'complete',
      'DC_B1': 'Add a draw',
      'DC_B2': 'Tips:',
      'DC_B3': 'Long press offers more options for cards or boosters !',
      'DC_B4': 'Sign In',
      'DC_B5': 'With signin, you can:',
      'DC_B6': 'Register your draw',
      'DC_B7': 'Compare your statistics with other members of community',
      'DC_B8': 'With signin, you must agree with :',
      'DC_B9': 'UID registration in our database',
      'DC_B10': 'Tutorial',
      'DC_B11': 'My draw',
      'DC_B12': 'Thanks to fill properly data the most right possible in order to help community.',
      'DC_B13': 'admin:',
      'DC_B14': 'draw',
      'DC_B15': 'My profile',
      'DC_B16': 'My cards',
      'DC_B17': 'My products',
      'DC_B18': 'My decks',
      'DC_B19': 'Continue my draw',
      'DC_B20': 'My saved draws',
      'DC_B21':  'Add your cards and products',
      'DC_B22':  'Visualize your collection and decks',
      'devSoon': 'For next version',
      'devBeta': 'BETA: In development',
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
      'S_B15': 'Show luck for one booster',
      'S_B16': 'Show number of obtained card',
      'S_B17': 'Main show',
      'S_B18': 'Comparison with my data',
      'S_B19': 'Show my luck',
      'S_B20': 'By set',
      'S_B21': 'By rarity',
      'S_B22': 'By type',
      'yes':   'Yes',
      'no':    'no',
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
      'V_B4': 'Set of card',
      'V_B5': 'SignIn with Google account',
      'V_B6': 'SignIn with phone',
      'O_B0': 'Remove your account',
      'O_B1': 'Refresh database',
      'O_B2': 'Debug mode',
      'O_B3': 'Thanks',
      'O_B4': 'Support',
      'O_B5': 'About',
      'O_B6': 'Respecting European rules, you have the right to oblivion.\n',
      'O_B7': 'UID removing inside our database is an irreversible action, you will not able to access to your draw.\n',
      'O_B8': 'Do you want to remove your account ?\n',
      'O_B9': 'Profile',
      'O_B10': 'Save image locally',
      'O_B11': 'Increase memory which are taken by app but limit data transfer',
      'O_B12': 'Current size: %f MB',
      'L_T0': 'Language',
      'LO_B0': 'Database connection is impossible.\nCheck your internet access.',
      'TB_B0': 'Booster is not conform ?',
      'TB_B1': 'Example: card\'s number is not correct',
      'TP_T0': 'Products',
      'TP_B0': 'Products are not available',
      'TP_B1': '''If your product is not registered, use many boosters or send us a message.

`Orange` products contain randomized boosters.''',
      'TP_B2': 'Select',
      'TP_B3': 'Add a new product',
      'TP_B4': 'Product name',
      'TP_B5': 'Bar code (optional)',
      'TR_B0': 'Error of product creation',
      'TR_B1': 'Registration validated',
      'TR_B2': 'Thanks for your contribution !',
      'TR_B3': 'Registration is not granted.\nCheck your internet access and retry !',
      'TR_B4': ' Check multiple expansions',
      'TR_B5': 'Product is not conform ?',
      'TR_B6': 'Example: My boosters\' number is not correct',
      'TR_B7': 'Do you want to lose your draw ?',
      'TR_B8': 'Stop and Save',
      'TR_B9': 'Save can\'t be done. Please verify writing rights and left memory space.',
      'TR_B10': 'We keep your draw.\nYou can find it inside your PokéSpace.',
      'TR_B11': 'Save',
      'TR_B12': 'Return to PokéSpace',
      'TR_B13': 'You don\'t have new card !',
      'TR_B14': 'Congratulation new cards have been found !',
      'TR_B15': 'Random cards into product:',
      'EP_B0': 'Please select an expansion\'s booster inside your product.',
      'EP_B1': 'Show names',
      'SU_B0': 'To demand improvement or register bugs:',
      'SU_B1': 'For others demands, contact us:',
      'SU_B2': 'You can also support us financially:',
      'TH_B0': 'A big thanks to members of Pokécardex for help :',
      'disclaimer_T0': 'Disclaimer',
      'disclaimer': ''' is not an official Pokémon application, it is not affiliated, endorsed or supported by Nintendo, GAME FREAK or The Pokémon Company.
Images and illustrations used are the property of their respective authors.\n
© 2022 Pokémon. © 1995–2022 Nintendo/Creatures Inc./GAME FREAK inc. Pokémon and Pokémon character names are trademarks of Nintendo.''',
      'DB_0': 'Impossible to connect.',
      'DB_1': 'Software is too old.\nPlease go to Play Store for update (can take time to detect).\n\nSorry for inconvenience.',
      'DB_2': 'Software / Database are in maintenance.\nPlease retry in one hour.\n\nSorry for inconvenience.',
      'RE_B0': 'Best cards',
      'RE_B1': 'Shared',
      'RE_B2': 'Report is saved into Pictures.',
      'SET_0': 'Standard set',
      'SET_1': 'Parallel set (Reverse)',
      'SET_2': 'Standard set foil',
      'LOG_1': 'Enter your SMS code',
      'LOG_2': 'Permission: "Access to number" failed',
      'LOG_3': 'Unknown authentication mode',
      'LOG_4': 'Internal error',
      'LOG_5': 'Authentication failed: %s',
      'LOG_6': 'Enter your phone number',
      'LOG_7': 'Phone number: +1 XX XX XX XX',
      'LOG_8': 'Authentication cancelled',
      'TUTO0_0': 'Tutorial: Add a draw',
      'TUTO0_1': 'I\'m ready',
      'TUTO0_2': "draw registration will be done in same time than opening.\n\nOpen your product and regroup yours boosters.\n",
      'TUTO0_3': "Step 1: Find your product",
      'TUTO0_4': "Select cards' language.",
      'TUTO0_5': "Select expansion of one booster of your product.",
      'TUTO0_6': "Registered product will be shown :\n- Grey products are specific about expansion\n- Orange products have randomised boosters\n",
      'TUTO0_7': "Your product exists",
      'TUTO0_8': "Select the product.",
      'TUTO0_9': "Your product doesn't exist",
      'TUTO0_10': "Solution 1: ",
      'TUTO0_11': "- Send a request using button",
      'TUTO0_12': "Your request will be analysed under 5 days",
      'TUTO0_13': "- Write on paper your draw result :\n   - Card's number (mark if parallel set/reverse)\n   - Energy's type",
      'TUTO0_14': "- Come back to register when product will be added.",
      'TUTO0_15': "Solution 2: ",
      'TUTO0_16': "- Add each booster separately\nExecute previous step by selecting booster's expansion and choose 'Booster' product",
      'TUTO0_17': "Step 2 : draw",
      'TUTO0_18': "Each sticker represent a booster.",
      'TUTO0_19': "Case 1: Single expansion product",
      'TUTO0_20': "Tool has fill boosters, you can directly select one.",
      'TUTO0_21': "Case 2: Randomized product",
      'TUTO0_22': "Select a sticker and choose expansion based booster to open.",
      'TUTO0_23': "In case of mistake, don't worry, you can make a 'long press' on sticker to change expansion.",
      'TUTO0_24': "Case 3: Product is not pas conform",
      'TUTO0_25': "If you have a booster of another expansion or number of boosters is not valid, select mode 'product non conform'.",
      'TUTO0_26': "Now, you can :\n  - change expansion,\n  - add or remove des stickers\nusing 'long press' on sticker.",
      'TUTO0_27': "Step 3 : Boosters' opening",
      'TUTO0_28': "You can open your booster.",
      'TUTO0_29': "Each sticker represent a card.",
      'TUTO0_30': "We advice to keep stack of your card by booster in order to find it more easily when error happens.",
      'TUTO0_31': "Simple touch",
      'TUTO0_32': "A simple touch allow to add one unite of set standard of this card.",
      'TUTO0_33': "Long press",
      'TUTO0_34': "A 'long press' allow to choose many cards and the set (standard ou parallel).",
      'TUTO0_35': "It's working with energy stickers too.",
      'TUTO0_36': "If the number of card inside booster is not valid, you can use mode 'Booster non conform'.",
      'TUTO0_37': "When all card selected, validation button appear :",
      'TUTO0_38': "OK : indicate all is fine",
      'TUTO0_39': "Warning parallel set : indicate than none parallel set/reverse card is selected.",
      'TUTO0_40': "Warning rare card : indicate than more one rare card is selected.",
      'TUTO0_41': "'Warning validator' is just a guide, you can press and validate.",
      'TUTO0_42': "Step 4 : Validation et send",
      'TUTO0_43': "Fill all boosters",
      'TUTO0_44': "Realize step 3 until all boosters are filled.\n'Send' button will appear.",
      'TUTO0_45': "You can come back inside booster panel if needed.",
      'TUTO0_46': "Press on Send.",
      'DH_B0':    "No draw",
      'NE_T0':    'News',
      'NCE_T0':   'Add card\'s',
      'NCE_B0':   'Add',
      'NCE_B1':   'Save',
      'NCE_B2':   'Auto',
      'NCE_B3':   'Actions',
      'NCE_B4':   'Add here',
      'NCE_B5':   'Remove',
      'NCE_B6':   'Next card',
      'NCE_B7':   'Other name',
      'NCE_B8':   'Do you want to lose your data ?',
      'CE_T0':    'Editor',
      'REG_0':    'No Area',
      'CA_T0':    'Cards',
      'CA_T1':    'Select by name',
      'CA_T2':    'Cards\' filter',
      'CA_T3':    'Effect\'s name',
      'CA_T4':    'Effect\'s description',
      'CA_B0':    'Pokémon',
      'CA_B1':    'Objects/Trainers',
      'CA_B2':    'Choose',
      'CA_B3':    'All cards',
      'CA_B4':    'Filters',
      'CA_B5':    'Search',
      'CA_B6':    'Number of cards : %d',
      'CA_B7':    'Cards by marker',
      'CA_B8':    'Cards by region',
      'CA_B9':    'Cards by type',
      'CA_B10':   'Cards by rarity',
      'CA_B11':   'Cards by expansion',
      'CA_B12':   'Filter by marker',
      'CA_B13':   'Regions',
      'CA_B14':   'Add an effect',
      'CA_B15':   'Type/Rarity',
      'CA_B16':   'Markers',
      'CA_B17':   'Effects',
      'CA_B18':   'Other card info',
      'CA_B19':   'Param 1:',
      'CA_B20':   'Param 2:',
      'CA_B21':   'Power:',
      'CA_B22':   'Card\'s name',
      'CA_B23':   'Choose an effect',
      'CA_B24':   'Choose a description',
      'CA_B25':   'Life:',
      'CA_B26':   'Retreat',
      'CA_B27':   'Resistance',
      'CA_B28':   'Weakness',
      'CA_B29':   'Not registered',
      'CA_B30':   'Database info:',
      'CA_B31':   'Replace:',
      'CA_B32':   'Change',
      'CA_B33':   'Remove orphan: %d',
      'CA_B34':   'Image',
      'CA_B35':   'Generality',
      'CA_B36':   'Card\'s effects',
      'CA_B37':   'Image',
      'CA_B38':   'Special ID',
      'CA_B39':   'Specific Expension',
      'CA_B40':   'Statistics',
      'CA_B41':   'image\'s edition',
      'MARK_0': 'Legende',
      'MARK_1': 'Restaure',
      'MARK_2': 'Mega',
      'MARK_3': 'Ultra',
      'MARK_4': 'Pokémon Tool',
      'MARK_5': 'Primal',
      'MARK_6': 'Team Flare',
      'MARK_7' : '\u0394 Plus',
      'MARK_8' : '\u0394 Evolution',
      'MARK_9' : '\u03A9 Barrier',
      'MARK_10' : '\u03A9 Barrage ',
      'MARK_11' : '\u03B1 Growth',
      'MARK_12' : '\u03B1 Recovery',
      'MARK_13' : 'Team Plasma',
      'MARK_14' : 'Cap Spe',
      'MARK_15' : 'Poke Power',
      'MARK_16' : 'Poke Body',
      'MARK_17' : '\u56DB',
      'MARK_18' : '\u03B4 Species',
      'MARK_19' : 'Team Rocket',
      'LOAD_0'  : 'Trainer preparation',
      'LOAD_1'  : 'Catching Pokémons',
      'LOAD_2'  : 'Prepare arena\'s masters',
      'LOAD_3'  : 'Clean PokéDex',
      'LOAD_4'  : 'Prepare Pokéballs',
      'LOAD_5'  : 'Prepare my trainer bag',
      'CAVIEW_B0': 'HP',
      'CAVIEW_B1': 'Retreat cost',
      'CAVIEW_B2': 'Resistance',
      'CAVIEW_B3': 'Weakness',
      'CAVIEW_B4': 'Generality',
      'CAVIEW_B5': 'Power',
      'CAVIEW_B6': 'Inside TCG',
      'CAVIEW_B7': 'Attack energy',
      'CAVIEW_B8': 'Attack power',
      'CAVIEW_B9': 'Card\'s Effects',
      'CAVIEW_B10':'Energy type',
      'CAVIEW_B11':'Images',
      'CAVIEW_B12':'Details',
      'LEVEL_0':   'Base',
      'LEVEL_1':   'Level 1',
      'LEVEL_2':   'Level 2',
      'STATE_1':   'Attack',
      'STATE_2':   'draw',
      'STATE_3':   'Flip a coin',
      'STATE_4':   'Poison',
      'STATE_5':   'Burn',
      'STATE_6':   'Sleep',
      'STATE_7':   'Paralyzed',
      'STATE_8':   'Search',
      'STATE_9':   'Heal',
      'STATE_10':  'Shuffle',
      'STATE_11':  'Confusion',
      'SE_TYPE_0': 'Normal',
      'SE_TYPE_1': 'Promo',
      'SE_TYPE_2': 'Deck',
      'SMENU_0': 'Cards',
      'SMENU_1': 'Global stats',
      'SMENU_2': 'draw',
      'SMENU_3': 'Product',
      'SEC_0':   'There is no information about this expansion',
      'SEC_1':   'It will be release at %s',
      'S_TOOL_T0': 'Add your opening',
      'S_TOOL_B0': '- Register boosters\' opening and products\n- Show your collection and advancement',
      'S_TOOL_T1': 'Display expansions',
      'S_TOOL_B1': '- Cards by expansions\n- Global Statistics\n- draw result',
      'S_TOOL_T2': 'Search Card',
      'S_TOOL_B2': '- by Pokemon\n- by characteristics\n-...',
      'S_TOOL_T3': 'Settings & Contact',
      'S_TOOL_B3': '- News\n- Contact\n- Settings',
      'S_TOOL_T4': 'Caption',
      'S_SERIE_0': 'Serie',
      'S_SERIE_1': 'Energies',
      'S_SERIE_2': 'Others',
      'SCB_T0':    'Completion',
      'SCB_B0':    'Booster\'s number to open',
      'SCB_B1':    'Minimum',
      'SCB_B2':    'Mean',
      'SCB_B3':    'Basic Set',
      'SCB_B4':    'Parallel Set',
      'SCB_B5':    'Complete Set',
      'SCB_B6':    'All cards',
      'SCB_B7':    'All cards without secrets',
      'SCB_B8':    'Missing rarity stats',
      'ADMIN_B0':  'Add product',
      'ADMIN_B1':  'Edit product',
      'ADMIN_B2':  'Edit Serie',
      'ADMIN_B3':  'Inspection',
      'ADMIN_B4':  'Clean',
      'ADMIN_B5':  'New demands',
      'ADMIN_B6':  'Add side product',
      'ADMIN_B7':  'Add expansion products',
      'ADMIN_B8':  'Rarities editor',
      'SPS_T0':    'Select product',
      'PSMC_B0':   'Add cards',
      'PSMC_B1':   'Standard cards',
      'PSMC_B2':   'Secret cards',
      'PSMC_B3':   'You haven\'t got cards !',
      'PSMC_B4':   'Add cards manually',
      'CS_B0':     'Jumbo',
      'CS_B1':     'Random',
      'PSMP_B0':   'Add new product',
      'PSMP_B1':   'No products registered',
      'PSPE_B0':   'Product edition',
      'PSPE_B1':   'Opened product',
      'PSPE_B2':   'Seal product',
      'PS_T0':     'Select products',
      'PS_B0':     'Booster/Box',
      'PS_B1':     'Others',
      'PS_B2':     'Add',
      'PS_B3':     'sleeve/portfolio',
      'PS_B4':     'Do you want add cards/other products inside your opened product ?',
      'PROD_KIND_0' : 'Booster',
      'PROD_KIND_1' : 'Display',
      'PROD_KIND_2' : 'Build & Battle',
      'PROD_KIND_3' : 'Build & Battle Stadium',
      'PROD_KIND_4' : 'ETB',
      'PROD_KIND_5' : 'ETB PokeCenter',
      'PROD_KIND_6' : 'ETB2',
      'PROD_KIND_7' : 'SimplePack',
      'PROD_KIND_8' : 'TriPack',
      'EPC_B0':       'First random card',
      'EPC_B1':       'Name',
      'TUTO_CAPTION_T0': 'Card\'s design',
      'TUTO_CAPTION_T1': 'Illustration',
      'TUTO_CAPTION_T2': 'Shining and rendering',
      'ART_N':           'Classic',
      'ART_HA':          'Half Art',
      'ART_FA':          'Full Art',
      'PSMD_B0':   'No deck !',
      'PSMD_B1':   'Create a deck',
      'PSMD_B2':   'My Deck',
      'PSMDC_T0':  'Deck Editor',
      'PSMDC_B0':  'Add card',
      'PSMDC_B1':  'Cards',
      'PSMDC_B2':  'Stats',
      'PSMDC_B3':  'Energies',
      'PSMDC_B4':  'Pokémons',
      'PSMDC_B5':  'Supporter',
      'PSMDC_B6':  'Tools and others',
      'PSMDC_B7':  'Add by expansion',
      'PSMDC_B8':  'Add by search',
      'PSMDC_B9':  'Please add card inside deck before',
      'PSMDC_B10':  'Pokémon Card',
      'PSMDC_B11':  'HP',
      'PSMDC_B12':  'Power',
      'PSMDC_B13':  'min',
      'PSMDC_B14':  'mean',
      'PSMDC_B15':  'max',
      'PSMDC_B16':  'Retreat',
      'PSMDC_B17':  'Weakness',
      'PSMDC_B18':  'Resistance',
      'PSMDC_B19':  'Data missing',
      'RARE_B0': 'Asian',
      'RARE_B1': 'World',
      'RARE_B2': 'Replace reverse',
      'RARE_B3': 'Good Card',
    },
    'fr': {
      'H_T0': 'PokéSpace',
      'H_T1': 'Extensions',
      'H_T2': 'Options',
      'H_T3': 'cartes',
      'H_T4': 'Dashboard',
      'SE_T': 'Statistiques de l\'extension',
      'SE_B0': 'Répartition des cartes',
      'SE_B1': 'Fréquence par carte',
      'SE_B2': 'Nombre de cartes :',
      'SE_B3': 'cartes',
      'SE_B4': 'secrètes',
      'SE_B5': 'totale',
      'DC_B1': 'Ajouter un tirage',
      'DC_B2': 'Astuces:',
      'DC_B3': 'L\' "appui long" vous offre plus d\'options pour vos cartes ou boosters !',
      'DC_B4': 'Connexion',
      'DC_B5': 'En vous connectant, vous pouvez :',
      'DC_B6': 'Enregistrer vos tirages',
      'DC_B7': 'Comparer vos statistiques avec celles de la communauté',
      'DC_B8': 'En vous connectant, vous acceptez :',
      'DC_B9': 'la sauvegarde de votre UID dans notre base de données',
      'DC_B10': 'Tutorial',
      'DC_B11': 'Mes tirages',
      'DC_B12': 'Merci de rentrer les informations les plus justes possibles afin d\'aider la communauté.',
      'DC_B13': 'admin:',
      'DC_B14': 'Tirage',
      'DC_B15': 'Mon profile',
      'DC_B16': 'Mes cartes',
      'DC_B17': 'Mes produits',
      'DC_B18': 'Mes decks',
      'DC_B19': 'Reprendre un tirage',
      'DC_B20': 'Mes tirages sauvegardés',
      'DC_B21':  'Ajouter vos cartes et produits',
      'DC_B22':  'Visualiser votre collection et votre progression',
      'devSoon': 'Dans une prochaine version',
      'devBeta': 'BETA: En développement',
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
      'S_B15': 'Afficher la chance par booster',
      'S_B16': 'Afficher le nombre de carte obtenue',
      'S_B17': 'Affichage général',
      'S_B18': 'Comparaison avec mes données',
      'S_B19': 'Afficher la chance',
      'S_B20': 'Par set',
      'S_B21': 'Par rareté',
      'S_B22': 'Par type',
      'yes':    'Oui',
      'no':     'Non',
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
      'V_B4': 'Set de la carte',
      'V_B5': 'Connexion avec Google',
      'V_B6': 'Connexion avec votre numero',
      'O_B0': 'Suppression du compte',
      'O_B1': 'Actualiser la base de données',
      'O_B2': 'Mode debug',
      'O_B3': 'Remerciement',
      'O_B4': 'Support',
      'O_B5': 'A propos',
      'O_B6': 'Conformement à la réglementation en rigeur, vous avez le droit à l\'oubli.\n',
      'O_B7': 'La suppression de votre UID dans la base de données est irréversible, vous ne pourrez plus jamais accéder à vos tirages.\n',
      'O_B8': 'Voulez-vous supprimer votre compte ?\n',
      'O_B9': 'Compte',
      'O_B10': 'Sauvegarder les images sur disque',
      'O_B11': 'Augmente la place du programme mais limite le transfer de données',
      'O_B12': 'Taille actuelle: %f Mo',
      'L_T0': 'Langue',
      'LO_B0': 'Connexion à la base de données impossible.\nVérifier votre connexion.',
      'TB_B0': 'Le booster n\'est pas conforme ?',
      'TB_B1': 'Exemple: le nombre de cartes n\'est pas correct',
      'TP_T0': 'Produits',
      'TP_B0': 'Aucun produit n\'est disponible',
      'TP_B1': '''Si votre produit n'est pas référencé, utiliser plusieurs boosters ou signaler-le nous.

Les produits `oranges` possèdent des boosters aléatoires.''',
      'TP_B2': 'Sélectionner',
      'TP_B3': 'Ajouter un produit',
      'TP_B4': 'Nom du produit',
      'TP_B5': 'Code barre (facultatif)',
      'TR_B0': 'Erreur de création du produit',
      'TR_B1': 'Enregistrement validé',
      'TR_B2': 'Merci pour votre participation !',
      'TR_B3': 'L\'envoi des données n\'a pu être fait.\nVérifiez votre connexion et réessayez !',
      'TR_B4': ' Attention aux diverses extensions',
      'TR_B5': 'Le produit n\'est pas conforme ?',
      'TR_B6': 'Exemple: il n\'y a pas le bon nombre de boosters',
      'TR_B7': 'Voulez-vous perdre votre tirage ?',
      'TR_B8': 'Stop et Sauvegarde',
      'TR_B9': 'La sauvegarde n\'a pas fonctionnée. Vérifier vos droits d\'écriture et l\'espace mémoire.',
      'TR_B10': 'Votre tirage est gardé au chaud.\nVous pouvez le retrouver dans votre PokéSpace.',
      'TR_B11': 'Sauvegarde',
      'TR_B12': 'Retour au PokéSpace',
      'TR_B13': 'Vous n\'avez pas obtenu de nouvelles cartes !',
      'TR_B14': 'Félicitation vous avez obtenu de nouvelles cartes !',
      'TR_B15': 'cartes aléatoires dans le produit :',
      'EP_B0': 'Veuillez choisir l\'extension d\'un booster de votre produit.',
      'EP_B1': 'Afficher les noms',
      'SU_B0': 'Pour des demandes d\'améliorations ou nous signaler des bugs:',
      'SU_B1': 'Pour d\'autres demandes, contactez-nous:',
      'SU_B2': 'Vous pouvez aussi nous soutenir financièrement:',
      'TH_B0': 'Un grand merci aux membres de Pokécardex pour leur aide et soutien :',
      'disclaimer_T0': 'Disclaimer',
      'disclaimer': ''' n'est pas une application officielle Pokémon, elle n'est en aucun cas affiliée, approuvée ou supportée par Nintendo, GAME FREAK ou The Pokémon Company.
Elle est à but non-lucratif, créé par et pour des fans de Pokémon.

Les personnages, le thème "Pokémon ®" et ses marques dérivées sont propriétés de © Nintendo, The Pokémon Company, Game Freak, Creatures.

Les images et illustrations utilisées sont la propriété de leurs auteurs respectifs.

© 2022 Pokémon. © 1995–2022 Nintendo/Creatures Inc./GAME FREAK inc. Pokémon et les noms des personnages Pokémon sont des marques de Nintendo.''',
      'DB_0': 'Impossible de se connecter à la base de données.',
      'DB_1': 'Le programme n\'est plus à jour.\nInstallez les mises à jour grâce au Play Store (peut mettre du temps a être détecté).\n\nExcusez nous pour la gêne occasionnée.',
      'DB_2': 'Le programme / base de données sont en maintenance.\nVeuillez réessayer dans une heure.\n\nExcusez nous pour la gêne occasionnée.',
      'NP_T0': 'Nouveau produit',
      'RE_B0': 'Meilleures cartes',
      'RE_B1': 'Partage',
      'RE_B2': 'Le rapport a été exporté dans Images.',
      'SET_0': 'Set standard',
      'SET_1': 'Set parallèle (Reverse)',
      'SET_2': 'Set standard holographique',
      'LOG_1': 'Entrer le code SMS',
      'LOG_2': 'Permission: "Accès au numéro" refusée',
      'LOG_3': 'Mode d\'authentification inconnu',
      'LOG_4': 'Erreur interne',
      'LOG_5': 'L\'authentification a échoué: %s',
      'LOG_6': 'Entrez votre numéro de téléphone (avec indicatif)',
      'LOG_7': 'Numéro de téléphone: +33 6 XX XX XX XX',
      'LOG_8': 'Authentification annulée',
      'TUTO0_0': 'Tutorial: Ajoutez un tirage',
      'TUTO0_1': 'Je suis prêt',
      'TUTO0_2': "L'enregistrement d'un tirage va se faire en même temps que votre ouverture.\n\nOuvrez votre produit et regroupez vos boosters.\n",
      'TUTO0_3': "Etape 1 : Trouvez votre produit",
      'TUTO0_4': "Selectionnez la langue des cartes.",
      'TUTO0_5': "Selectionnez l'extension d'un des boosters de votre produit.",
      'TUTO0_6': "La liste des produits enregistrés va apparaître :\n- Les produits en gris sont spécifiques à l'extension choisie\n- Les produits en orange ont des boosters randomisés\n",
      'TUTO0_7': "Votre produit est présent",
      'TUTO0_8': "Selectionnez votre produit.",
      'TUTO0_9': "Votre produit n'est pas présent",
      'TUTO0_10': "Solution 1: ",
      'TUTO0_11': "- Faire la demande d'ajout grâce au bouton ",
      'TUTO0_12': "Une demande est traitée en moins de 5 jours",
      'TUTO0_13': "- Notez sur un papier le tirage :\n   - Numero de carte (entourez si set parallèle/reverse)\n   - Le type d'énergie",
      'TUTO0_14': "- Revenez faire l'enregistrement quand le produit sera présent.",
      'TUTO0_15': "Solution 2: ",
      'TUTO0_16': "- Traitez chaque booster à l'unité\nRefaites les étapes précédentes en selectionnant l'extension du booster à traiter et choisissez le produit Booster",
      'TUTO0_17': "Etape 2 : Tirage",
      'TUTO0_18': "Chaque vignette représente un booster.",
      'TUTO0_19': "Cas 1: Les produits mono-extension",
      'TUTO0_20': "L'outil a prérempli les booster, vous pouvez directement en selectionner un.",
      'TUTO0_21': "Cas 2: Les produits randomisés",
      'TUTO0_22': "Sélectionnez une vignette et choisissez son extension en fonction du booster que vous allez ouvrir.",
      'TUTO0_23': "En cas d'erreur, pas de panique, vous pouvez faire un 'appui long' sur la vignette et changer son extension.",
      'TUTO0_24': "Cas 3: Le produit n'est pas conforme",
      'TUTO0_25': "Si vous avez un booster d'une extension différente ou que le nombre de booster n'est pas valide, selectionnez le mode 'produit non conforme'.",
      'TUTO0_26': "Vous pouvez a présent :\n  - changer le type d'extension,\n  - ajouter ou supprimer des vignettes\ngrâce à un 'appui long' sur la vignette.",
      'TUTO0_27': "Etape 3 : Ouverture du booster",
      'TUTO0_28': "Vous pouvez déballer les cartes de votre booster.",
      'TUTO0_29': "Chaque vignette représente une carte.",
      'TUTO0_30': "Nous vous conseillons de faire des piles par booster afin de les retrouver si vous avez une erreur lors de l'enregistrement.",
      'TUTO0_31': "Selection simple",
      'TUTO0_32': "Une simple selection permet de choisir une unité de cette carte.",
      'TUTO0_33': "Appui long",
      'TUTO0_34': "Un 'appui long' vous permet de choisir plusieurs cartes ainsi que le set (standard ou parallèle).",
      'TUTO0_35': "Cela marche aussi avec les énergies.",
      'TUTO0_36': "S'il n'y a pas le bon nombre de carte, vous pouvez passer en mode 'Booster non conforme'.",
      'TUTO0_37': "Une fois toutes les cartes sélectionnées, un bouton de validation apparaît :",
      'TUTO0_38': "OK : indique que tout va bien",
      'TUTO0_39': "Attention set parallèle : indique qu'aucune carte set parallèle/reverse n'est entrée.",
      'TUTO0_40': "Attention carte rare : indique que plus d'une carte rare a été enregistrée.",
      'TUTO0_41': "Vous pouvez toujours valider un mode 'Attention', ce n'est qu'un indicateur.",
      'TUTO0_42': "Etape 4 : Validation et envoi",
      'TUTO0_43': "Remplir tous les boosters",
      'TUTO0_44': "Répétez l'étape 3 jusqu'à remplir tous les boosters.\nUn bouton 'Envoyer' fera son apparition.",
      'TUTO0_45': "Vous pouvez revenir dans vos boosters si besoin.",
      'TUTO0_46': "Appuyez sur Envoyer.",
      'DH_B0':    "Aucun tirage",
      'NE_T0':    'Nouvelles',
      'NCE_T0':   'Ajout de carte',
      'NCE_B0':   'Ajouter',
      'NCE_B1':   'Envoyer',
      'NCE_B2':   'Auto',
      'NCE_B3':   'Actions',
      'NCE_B4':   'Ajouter ici',
      'NCE_B5':   'Supprimer',
      'NCE_B6':   'Suivant',
      'NCE_B7':   'Autre nom',
      'NCE_B8':   'Voulez-vous perdre vos données ?',
      'CE_T0':    'Editeur',
      'REG_0':    'Sans région',
      'SPE_0':    'Standard',
      'CA_T0':    'cartes',
      'CA_T1':    'Choisir un nom',
      'CA_T2':    'Filtrer les cartes',
      'CA_T3':    'Nom de l\'effet',
      'CA_T4':    'Description de l\'effet',
      'CA_B0':    'Pokémon',
      'CA_B1':    'Objets/Dresseurs',
      'CA_B2':    'Choisir',
      'CA_B3':    'Toutes les cartes',
      'CA_B4':    'Filtres',
      'CA_B5':    'Recherche',
      'CA_B6':    'Nombre de cartes : %d',
      'CA_B7':    'cartes par marqueur',
      'CA_B8':    'cartes par région',
      'CA_B9':    'cartes par type',
      'CA_B10':   'cartes par rareté',
      'CA_B11':   'cartes par extension',
      'CA_B12':   'Filtre par marqueur',
      'CA_B13':   'Régions',
      'CA_B14':   'Ajouter un effet',
      'CA_B15':   'Type/Rareté',
      'CA_B16':   'Marqueurs',
      'CA_B17':   'Effets',
      'CA_B18':   'Informations',
      'CA_B19':   'Param 1:',
      'CA_B20':   'Param 2:',
      'CA_B21':   'Puissance:',
      'CA_B22':   'Nom de la carte',
      'CA_B23':   'Choisir un effet',
      'CA_B24':   'Choisir une description',
      'CA_B25':   'Vie',
      'CA_B26':   'Retraite',
      'CA_B27':   'Résistance',
      'CA_B28':   'Faiblesse',
      'CA_B29':   'Inconnu',
      'CA_B30':   'Base:',
      'CA_B31':   'Remplacer:',
      'CA_B32':   'Change',
      'CA_B33':   'Supprimer les cartes seules: %d',
      'CA_B34':   'Image',
      'CA_B35':   'Généralité',
      'CA_B36':   'Effects de la carte',
      'CA_B37':   'Image',
      'CA_B38':   'Special ID',
      'CA_B39':   'Spécifique',
      'CA_B40':   'Statistiques',
      'CA_B41':   'Edition de l\'image',
      'MARK_0': 'Legende',
      'MARK_1': 'Restaure',
      'MARK_2': 'Mega',
      'MARK_3': 'Ultra',
      'MARK_4': 'Outil Pokémon',
      'MARK_5': 'Primo',
      'MARK_6': 'Team Flare',
      'MARK_7' : 'Plus \u0394',
      'MARK_8' : 'Evolution \u0394',
      'MARK_9' : 'Barrière \u03A9',
      'MARK_10' : 'Offensive \u03A9',
      'MARK_11' : 'Croissance \u03B1',
      'MARK_12' : 'Régénération \u03B1',
      'MARK_13' : 'Team Plasma',
      'MARK_14' : 'Cap Spe',
      'MARK_15' : 'Poke Power',
      'MARK_16' : 'Poke Body',
      'MARK_17' : '\u56DB',
      'MARK_18' : 'Espèce \u03B4',
      'MARK_19' : 'Team Rocket',
      'LOAD_0'  : 'Préparation des dresseurs',
      'LOAD_1'  : 'Capture les Pokémons',
      'LOAD_2'  : 'Prépare les maîtres d\'arènes',
      'LOAD_3'  : 'Nettoie le PokéDex',
      'LOAD_4'  : 'Prepare les Pokéballs',
      'LOAD_5'  : 'Prépare mon sac de dresseur',
      'CAVIEW_B0': 'HP',
      'CAVIEW_B1': 'Coût retraite',
      'CAVIEW_B2': 'Résistance',
      'CAVIEW_B3': 'Faiblesse',
      'CAVIEW_B4': 'Généralité',
      'CAVIEW_B5': 'Pouvoir',
      'CAVIEW_B6': 'Dans le JCC',
      'CAVIEW_B7': 'Energie d\'attaque',
      'CAVIEW_B8': 'Puissance d\'attaque',
      'CAVIEW_B9': 'Effets de la carte',
      'CAVIEW_B10':'Type d\'énergie',
      'CAVIEW_B11':'Images',
      'CAVIEW_B12':'Détails',
      'LEVEL_0':   'Base',
      'LEVEL_1':   'Niveau 1',
      'LEVEL_2':   'Niveau 2',
      'STATE_1':   'Attaque',
      'STATE_2':   'Tirer une carte',
      'STATE_3':   'Lancer une pièce',
      'STATE_4':   'Poison',
      'STATE_5':   'Brûlure',
      'STATE_6':   'Endormi',
      'STATE_7':   'Paralysé',
      'STATE_8':   'Recherche',
      'STATE_9':   'Soin',
      'STATE_10':  'Mélanger les cartes',
      'STATE_11':  'Confusion',
      'SE_TYPE_0': 'Normal',
      'SE_TYPE_1': 'Promo',
      'SE_TYPE_2': 'Deck',
      'SMENU_0': 'cartes',
      'SMENU_1': 'Statistiques',
      'SMENU_2': 'Tirages',
      'SMENU_3': 'Produits',
      'SEC_0':   'Aucune information sur cette extension',
      'SEC_1':   'Elle sortira à partir du %s',
      'S_SERIE_0': 'Série',
      'S_SERIE_1': 'Energies',
      'S_SERIE_2': 'Autres',
      'S_TOOL_T0': 'PokéSpace',
      'S_TOOL_B0': '- Enregistrer vos ouvertures de boosters et produits\n-Visualiser votre avancée dans la collection',
      'S_TOOL_T1': 'Visualiser les extensions',
      'S_TOOL_B1': '- cartes par extensions\n- Statistiques globales\n- Tirages',
      'S_TOOL_T2': 'Rechercher des cartes',
      'S_TOOL_B2': '- par Pokémon\n- par caractéristiques\n-...',
      'S_TOOL_T3': 'Options & Contact',
      'S_TOOL_B3': '- News\n- Contact\n- Options',
      'S_TOOL_T4': 'Légende',
      'SCB_T0':    'Estimation de completion',
      'SCB_B0':    'Nombre de boosters à ouvrir',
      'SCB_B1':    'Minimum',
      'SCB_B2':    'En moyenne',
      'SCB_B3':    'Set de base',
      'SCB_B4':    'Set parallèle',
      'SCB_B5':    'Set complet',
      'SCB_B6':    'Toutes les cartes',
      'SCB_B7':    'Toutes les cartes sauf les secrets',
      'SCB_B8':    'Les statistiques sur des raretés sont manquantes',
      'ADMIN_B0':  'Ajout de produit',
      'ADMIN_B1':  'Edit de produit',
      'ADMIN_B2':  'Edition de série',
      'ADMIN_B3':  'Inspection',
      'ADMIN_B4':  'Nettoyer',
      'ADMIN_B5':  'Nouvelles demandes',
      'ADMIN_B6':  'Ajout de produit annexe',
      'ADMIN_B7':  'Ajout de produit d\'extension',
      'ADMIN_B8':  'Edition des raretés',
      'SPS_T0':    'Selection de produit',
      'PSMC_B0':   'Ajouter des cartes',
      'PSMC_B1':   'cartes standards',
      'PSMC_B2':   'cartes secrètes',
      'PSMC_B3':   'Vous ne possèdez aucune carte !',
      'PSMC_B4':   'Ajouter des cartes manuellement',
      'CS_B0':     'Jumbo',
      'CS_B1':     'Aléatoire',
      'PSMP_B0':   'Ajouter un nouveau produit',
      'PSMP_B1':   'Aucun produit enregistré',
      'PSPE_B0':   'Edition du produit',
      'PSPE_B1':   'Produit ouvert',
      'PSPE_B2':   'Produit scellé',
      'PS_T0':     'Selection des produits',
      'PS_B0':     'Booster/Coffret',
      'PS_B1':     'Autres',
      'PS_B2':     'Ajouter',
      'PS_B3':     'sleeve/portfolio',
      'PS_B4':     'Voulez-vous ajouter les cartes et autres produits contenus dans les produits selectionnés ?',
      'PROD_KIND_0' : 'Booster',
      'PROD_KIND_1' : 'Display',
      'PROD_KIND_2' : 'Stratégies & Combats',
      'PROD_KIND_3' : 'Stade Stratégies & Combats',
      'PROD_KIND_4' : 'ETB',
      'PROD_KIND_5' : 'ETB PokeCenter',
      'PROD_KIND_6' : 'ETB 2',
      'PROD_KIND_7' : 'SimplePack',
      'PROD_KIND_8' : 'TriPack',
      'EPC_B0': 'Première carte aléatoire',
      'EPC_B1': 'Nom',
      'TUTO_CAPTION_T0': 'Design de la carte',
      'TUTO_CAPTION_T1': 'Illustration',
      'TUTO_CAPTION_T2': 'Brillance et rendu',
      'ART_N':           'Classique',
      'ART_HA':          'Half Art',
      'ART_FA':          'Full Art',
      'PSMD_B0':   'Aucun deck !',
      'PSMD_B1':   'Créer un deck',
      'PSMD_B2':   'Mon Deck',
      'PSMDC_T0':  'Editeur de Deck',
      'PSMDC_B0':  'Ajouter une carte',
      'PSMDC_B1':  'cartes',
      'PSMDC_B2':  'Statistiques',
      'PSMDC_B3':  'Energies',
      'PSMDC_B4':  'Pokémons',
      'PSMDC_B5':  'Dresseurs',
      'PSMDC_B6':  'Outils et autres',
      'PSMDC_B7':  'Ajouter par extension',
      'PSMDC_B8':  'Ajouter recherche',
      'PSMDC_B9':  'Aucune carte dans le deck',
      'PSMDC_B10':  'cartes Pokémon',
      'PSMDC_B11':  'PV',
      'PSMDC_B12':  'Puissance',
      'PSMDC_B13':  'min',
      'PSMDC_B14':  'moyenne',
      'PSMDC_B15':  'max',
      'PSMDC_B16':  'Retraite',
      'PSMDC_B17':  'Faiblesse',
      'PSMDC_B18':  'Résistance',
      'PSMDC_B19': 'Données manquantes',
      'RARE_B0': 'Asie',
      'RARE_B1': 'Monde',
      'RARE_B2': 'Remplace reverse',
      'RARE_B3': 'Bonne carte',
    },
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

class StatitikLocaleDelegate extends LocalizationsDelegate<StatitikLocale> {
  const StatitikLocaleDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<StatitikLocale> load(Locale locale) async {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of DemoLocalizations.
    var prefs = await SharedPreferences.getInstance();
    String? languageLocale = prefs.getString('appLocale');
    return SynchronousFuture<StatitikLocale>(StatitikLocale(
        languageLocale != null ? Locale(languageLocale) : locale)
    );
  }

  @override
  bool shouldReload(StatitikLocaleDelegate old) => false;
}