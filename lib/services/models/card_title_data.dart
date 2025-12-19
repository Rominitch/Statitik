import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

class CardTitleData
{
  final MultiLanguageString _names;

  CardTitleData(this._names);

  CardTitleData.fromBytes(ByteParser parser):
      _names = parser.extractMultiLanguage()!;

  List<int> toBytes() {
    return ByteEncoder.encodeMultiLanguage(_names);
  }
  String fullname(Language l) {
    return _names.name(l);
  }

  String defaultName([String separator='\n']) {
    return _names.defaultName(separator);
  }

  String name(Language l) {
    return _names.name(l);
  }

  bool isPokemon() {
    return false;
  }

  bool search(Language? l, String searchPart) {
    return _names.search(l, searchPart);
  }
}

class PokemonInfo extends CardTitleData
{
  int         generation;
  int         idPokedex;

  PokemonInfo(super.names, this.generation, this.idPokedex);

  @override
  String fullname(Language l) {
    return "${name(l)} - n°$idPokedex";
  }

  @override
  bool isPokemon() {
    return true;
  }

  PokemonInfo.fromBytes(super.parser):
        generation = parser.extractInt8(),
        idPokedex  = parser.extractInt16(),
        super.fromBytes();

  @override
  List<int> toBytes() {
    return super.toBytes()
        + ByteEncoder.encodeInt8(generation)
        + ByteEncoder.encodeInt16(idPokedex);
  }
}
