
import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/tools/binary_manager.dart';

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


class PokeLangage {
  final String      _code;
  final Map<PokeIdentifier, String>  _labels;
  final CardLocation _location;

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

  const PokeLangage.fromDB(this._code, this._labels, this._location);

  String db() { return  "nom_$_code"; }
  static String dbName(String code) { return  "nom_$code"; }

  PokeLangage.fromBytes(BinaryReader reader):
    _code  = reader.readString(),
    _labels = reader.readMap<PokeIdentifier, String>(
        (r) => PokeIdentifier.fromBytes(r),
        (r) => r.readString()
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