import 'package:statitikcard/services/models/multi_language_string.dart';

class ProductCategory {
  int                 idDB;
  MultiLanguageString name;
  bool                isContainer;

  ProductCategory(this.idDB, this.name, this.isContainer);
}