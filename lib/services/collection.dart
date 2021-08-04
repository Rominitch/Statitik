import 'package:statitikcard/services/models.dart';

class Collection
{
  Map languages = {};
  List extensions = [];
  Map subExtensions = {};
  Map listCards = {};
  int category=0;
  Map pokemons = {};
  Map otherNames = {};

  void clear() {
    languages.clear();
    extensions.clear();
    subExtensions.clear();
    listCards.clear();
    pokemons.clear();
    category=0;
  }

  void addLanguage(Language l) {
    languages[l.id] = l;
  }

  void addExtension(Extension e) {
    extensions.add(e);
  }
  void addSubExtension(SubExtension e) {
    subExtensions[e.id] = e;
  }
  void addListCards(ListCards l, int id) {
    listCards[id] = l;
  }

  List<Extension> getExtensions(Language language) {
    List<Extension> l = [];
    for(Extension e in extensions) {
      if (e.idLanguage == language.id) {
        l.add(e);
      }
    }
    return l;
  }

  List<SubExtension> getSubExtensions(Extension e) {
    List<SubExtension> l = [];
    for(SubExtension se in subExtensions.values) {
      if (se.idExtension == e.id) {
        l.add(se);
      }
    }
    return l;
  }

  SubExtension? getSubExtensionID(int id) {
    return subExtensions[id];
  }

  ListCards? getListCardsID(int id) {
    return listCards[id];
  }

  void addPokemon(PokemonInfo p, int id) {
    pokemons[id] = p;
  }
  void addNamed(NamedInfo p, int id) {
    otherNames[id] = p;
  }

  PokemonInfo getPokemonID(int id) {
    return id > 0 ? pokemons[id] : null;
  }

  NamedInfo getNamedID(int id) {
    return id >= 10000 ? otherNames[id] : null;
  }
}