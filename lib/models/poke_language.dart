
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/tools/binary_manager.dart';

enum Language {
  en,
  fr,
  jp;

  static Language from(String s) {
    switch(s) {
      case "EN": return Language.en;
      case "FR": return Language.fr;
      case "JP": return Language.jp;
    }
    throw Exception("unknown");
  }

  static Language fromLocale(Locale l) {
    final code = l.toLanguageTag().split("-")[0].toUpperCase();
    switch(code) {
      case "EN": return Language.en;
      case "FR": return Language.fr;
      case "JP": return Language.jp;
    }
    if(!kReleaseMode) { throw Exception("unknown");}
    return Language.en;
  }
}

enum CardLocation {
  Asie,
  Monde;

  static CardLocation from(String s) {
    switch(s) {
      case "Asie": return CardLocation.Asie;
      case "Monde": return CardLocation.Monde;
    }
    throw Exception("unknown");
  }
}


class PokeLanguage {
  final String      _code;
  final Map<PokeIdentifier, String>  _labels;
  final CardLocation _location;

  // Not to savedSaved
  final Language id;

  AssetImage create()
  {
    return AssetImage('assets/langue/$_code.png');
  }

  Image barIcon([double? newHeight]) {
    return Image(
      image: create(),
      height: newHeight ?? AppBar().preferredSize.height * 0.4,
    );
  }

  const PokeLanguage.fromDB(this._code, this._labels, this._location, this.id);

  String db() { return  "nom_$_code"; }
  static String dbName(String code) { return  "nom_$code"; }

  PokeLanguage.fromBytes(this.id, BinaryReader reader):
    _code  = reader.readString(),
    _labels = reader.readMap<PokeIdentifier, String>(
        (r) => PokeIdentifier.fromBytes(r),
        (r, k) => r.readString()
    ),
    _location = CardLocation.values[reader.readInt16()];


  void toBytes(BinaryWriter w) {
    w.writeString(_code);
    w.writeMap<PokeIdentifier, String>(_labels,
        (w, key)   => toBytes(w),
        (w, value) => w.writeString(value)
    );
    w.writeInt16(_location.index);
  }

  String? label(PokeIdentifier id) {
    assert(_labels.containsKey(id), "$_code: Impossible to find Label: ${id.id()}");
    return _labels[id];
  }

  CardLocation location() { return _location; }

  String code() { return _code;}

  bool search(PokeIdentifier id, String searchPart) {
    return label(id)!.toLowerCase().contains(searchPart.toLowerCase());
  }

}