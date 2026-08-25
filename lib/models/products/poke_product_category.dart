import 'package:statitikcard/models/poke_identifier.dart';

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