import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';

class PokeProductCategory {
  PokeIdentifier _pid;
  bool           isContainer;

  PokeProductCategory(this._pid, this.isContainer);

  PokeIdentifier pid() {
    return _pid;
  }

  bool isEqual(PokeIdentifier pid) {
    return _pid == pid;
  }

  String name(PokeLanguage language) {
    return language.label(_pid)!;
  }
/*
  PokeProductCategory.fromBytes(ByteParser parser):
        idDB = parser.extractInt32(),
        name = parser.extractMultiLanguage()!,
        isContainer = parser.extractBool();

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(idDB)
        + ByteEncoder.encodeMultiLanguage(name)
        + ByteEncoder.encodeBool(isContainer);
  }
*/
}