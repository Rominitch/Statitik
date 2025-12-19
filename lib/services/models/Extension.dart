import 'package:statitikcard/services/collection.dart';
import 'package:statitikcard/services/models/language.dart';

import 'bytes_coder.dart';

class Extension
{
  int      id;
  String   name;
  Language language;

  Extension(this.id, this.name, this.language);

  Extension.fromBytes(Collection collection, ByteParser parser):
        id       = parser.extractInt32(),
        name     = parser.extractString16(),
        language = collection.languages[parser.extractInt32()];

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(id)
        + ByteEncoder.encodeString16(name.codeUnits)
        + ByteEncoder.encodeInt32(language.id);
  }
}