
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/serie_type.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class SavedInstanceState
{
  bool showAllproduct = true;

  // Extension
  Language?      selectedLanguage;
  SubExtension?  subExtension;

  Map<SerieType, bool> serieFilters = {SerieType.normal: true, SerieType.promo: true, SerieType.deck: true};

  void cleanExtensionState() {
    selectedLanguage = null;
    subExtension     = null;
  }

  // Cards
}