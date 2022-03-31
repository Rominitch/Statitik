import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/MultiLanguageString.dart';

class Rarity {
  final int id;
  final IconData? iconId;
  final MultiLanguageString? value;
  final String image;
  final bool rotate;
  final Color color;

  const Rarity.fromText(this.id,  this.value, this.color) : this.iconId = null, this.image = "", this.rotate = false;
  const Rarity.fromIcon(this.id,  this.iconId, this.value, this.color, {this.rotate=false}): this.image = "";
  const Rarity.fromImage(this.id, this.image, this.color) : this.iconId = null, this.value = null, this.rotate = false;

  List<Widget> icon(Language l, {iconSize, fontSize=12.0}) {
    return [
      if(image.isNotEmpty)
        (iconSize != null) ? drawCachedImage('logo', image, height: iconSize ?? 20)
                           : Expanded(child: drawCachedImage('logo', image)),
      if(iconId != null)
        rotate ? Transform.rotate(angle: pi / 4.0, child: Icon(iconId, size: iconSize))
               : Icon(iconId, size: iconSize),
      if(value != null)  Text(value!.name(l), style: TextStyle(fontSize: fontSize)),
    ];
  }

  bool isValid() {
    return this == Environment.instance.collection.unknownRarity!;
  }
}

List<Widget> getImageRarity(Rarity rarity, Language l,{iconSize, fontSize=12.0, generate=false}) {
  if(Environment.instance.collection.cachedImageRarity[l] == null) {
    Environment.instance.collection.cachedImageRarity[l] = {};
  }

  if(generate || Environment.instance.collection.cachedImageRarity[l]![rarity] == null) {
    List<Widget> rendering = rarity.icon(l, iconSize: iconSize, fontSize: fontSize);
    if(generate)
      return rendering;
    else
      Environment.instance.collection.cachedImageRarity[l]![rarity] = rendering;
  }
  return Environment.instance.collection.cachedImageRarity[l]![rarity]!;
}