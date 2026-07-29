import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeRarity {
  static const int rarityMaskWorldCard        = 1;
  static const int rarityMaskAsianCard        = 2;
  static const int rarityMaskOtherReverseCard = 4;
  static const int rarityMaskGoodCard         = 8;
  static const int rarityMaskRotateIcon       = 16;

  final int       _id;
  final IconData? iconId;
  final String    image;
  final String    letter;
  final int       configuration;
  final Color     color;
  // Name into DB is not useful here

  const PokeRarity.fromDB(this._id, this.iconId, this.letter, this.image, this.configuration, this.color);

  const PokeRarity.fromText(this._id,  this.letter, this.color) : iconId = null, image = "", configuration = 0;
  const PokeRarity.fromIcon(this._id,  this.iconId, this.letter, this.color):    image = "", configuration = 0;
  const PokeRarity.fromImage(this._id, this.image, this.color) : iconId = null, letter = "", configuration = 0;

  int  id() { return _id; }
  bool isEqual(int id)   { return _id == id; }
  bool rotate()          { return mask(configuration, rarityMaskRotateIcon); }
  bool isAsian()         { return mask(configuration, rarityMaskAsianCard); }
  bool isWorld()         { return mask(configuration, rarityMaskWorldCard); }
  bool isGood()          { return mask(configuration, rarityMaskGoodCard); }
  bool isOtherReversed() { return mask(configuration, rarityMaskOtherReverseCard); }

  static IconData? getIcon(int? id) {
    if(id == null) { return null; }
    switch(id) {
      case 0xe163: return Icons.circle;
      case 0xe606: return Icons.stop;
      case 0xe5f9: return Icons.star;
      case 0xe5fa: return Icons.star_outline;
      case 0xe3b4: return Icons.looks;
    }
    return Icons.help_outline;
  }


  List<Widget> icon({double? iconSize, double fontSize=12.0, double? textureSize=20.0}) {
    return [
      if(image.isNotEmpty)
        textureSize != null ? drawCachedImage('logo', image, height: textureSize)
            : Flexible(child:drawCachedImage('logo', image)),
      if(iconId != null)
        rotate() ? Transform.rotate(angle: pi / 4.0, child: Icon(iconId, size: iconSize))
            : Icon(iconId, size: iconSize),
      if(letter.isNotEmpty)
        Text(letter, style: TextStyle(fontSize: letter.length > 2 ? fontSize-3 : fontSize)),
    ];
  }

  PokeRarity.fromBytes(BinaryReader reader):
      _id    = reader.readInt16(),
      iconId = reader.readOptional( () => reader.readIconData() ),
      letter = reader.readString(),
      image  = reader.readString(),
      configuration = reader.readInt16(),
      color  = reader.readColor();

  void toBytes(BinaryWriter writer) {
    writer.writeInt16(_id);
    writer.writeOptional(iconId, () => writer.writeIconData(iconId!) );
    writer.writeString(letter);
    writer.writeString(image);
    writer.writeInt16(configuration);
    writer.writeColor(color);
  }
}