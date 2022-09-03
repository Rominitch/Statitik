
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class SavedInstanceState
{
  bool showAllproduct = true;

  // Extension
  Language?      selectedLanguage;
  SubExtension?  subExtension;

  void cleanExtensionState() {
    selectedLanguage = null;
    subExtension     = null;
  }

  // Cards
}