import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

class ProductCategory {
  int                 idDB;
  MultiLanguageString name;
  bool                isContainer;

  ProductCategory(this.idDB, this.name, this.isContainer);

  ProductCategory.fromBytes(ByteParser parser):
    idDB = parser.extractInt32(),
    name = parser.extractMultiLanguage()!,
    isContainer = parser.extractBool();

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(idDB)
      + ByteEncoder.encodeMultiLanguage(name)
      + ByteEncoder.encodeBool(isContainer);
  }
}