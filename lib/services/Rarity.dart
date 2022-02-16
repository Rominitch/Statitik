import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';

class Rarity {
  int id;
  int? iconId;
  String value="";
  String image="";
  bool rotate = false;
  Color color;

  Rarity.fromText(this.id,  this.value, this.color);
  Rarity.fromIcon(this.id,  this.iconId, this.value, this.color, {this.rotate=false});
  Rarity.fromImage(this.id, this.image, this.color);

  List<Widget> icon({iconSize, fontSize=12.0}) {
    return [
      if(image.isNotEmpty)  drawCachedImage('logo', image, height: iconSize ?? 20),
      if(iconId != null)
        rotate ? Transform.rotate(angle: pi / 4.0, child: Icon(IconData(iconId!, fontFamily: 'MaterialIcons'), size: iconSize))
               : Icon(IconData(iconId!, fontFamily: 'MaterialIcons'), size: iconSize),
      if(value.isNotEmpty)  Text(value, style: TextStyle(fontSize: fontSize)),
    ];
  }

  bool isValid() {
    return this == unknownRarity!;
  }
}

Rarity? unknownRarity;

// Generic list
List<Rarity> orderedRarity    = [];
List<Rarity> worldRarity      = [];
List<Rarity> japanRarity      = [];
List<Rarity> goodCard         = [];
List<Rarity> otherThanReverse = [];

Map<Rarity, List<Widget>?> cachedImageRarity = {};
List<Widget> getImageRarity(Rarity rarity, {iconSize, fontSize=12.0, generate=false}) {
  if(generate || cachedImageRarity[rarity] == null) {
    List<Widget> rendering = rarity.icon(iconSize: iconSize, fontSize: fontSize);
    if(generate)
      return rendering;
    else
      cachedImageRarity[rarity] = rendering;
  }
  return cachedImageRarity[rarity]!;
}