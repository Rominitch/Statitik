import 'package:statitikcard/services/models/models.dart';

class ProductCategory {
  int                 idDB;
  MultiLanguageString name;
  bool                isContainer;

  ProductCategory(this.idDB, this.name, this.isContainer);
}