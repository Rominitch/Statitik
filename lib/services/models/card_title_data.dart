import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

class CardTitleData
{
  final MultiLanguageString _names;

  CardTitleData(this._names);

  String fullname(Language l) {
    return _names.name(l);
  }

  String defaultName([separator='\n']) {
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

  PokemonInfo(MultiLanguageString names, this.generation, this.idPokedex) :
        super(names);

  @override
  String fullname(Language l) {
    return "${name(l)} - n°$idPokedex";
  }

  @override
  bool isPokemon() {
    return true;
  }
}
