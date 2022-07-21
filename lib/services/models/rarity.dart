import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';

class Rarity {
  final int id;
  final IconData? iconId;
  final MultiLanguageString? value;
  final String image;
  final bool rotate;
  final Color color;

  const Rarity.fromText(this.id,  this.value, this.color) : iconId = null, image = "", rotate = false;
  const Rarity.fromIcon(this.id,  this.iconId, this.value, this.color, {this.rotate=false}): image = "";
  const Rarity.fromImage(this.id, this.image, this.color) : iconId = null, value = null, rotate = false;

  List<Widget> icon(Language l, {iconSize, fontSize=12.0, textureSize=20.0}) {
    var text = (value != null) ? value!.name(l) : "";
    return [
      if(image.isNotEmpty)
        textureSize != null ? drawCachedImage('logo', image, height: textureSize)
            : Flexible(child:drawCachedImage('logo', image)),
      if(iconId != null)
        rotate ? Transform.rotate(angle: pi / 4.0, child: Icon(iconId, size: iconSize))
               : Icon(iconId, size: iconSize),
      if(value != null)
        Text(text, style: TextStyle(fontSize: text.length > 2 ? fontSize-3 : fontSize)),
    ];
  }

  bool isValid() {
    return this == Environment.instance.collection.unknownRarity!;
  }
}

List<Widget> getImageRarity(Rarity rarity, Language l,{iconSize, textureSize=20.0, fontSize=12.0, generate=false}) {
  if(Environment.instance.collection.cachedImageRarity[l] == null) {
    Environment.instance.collection.cachedImageRarity[l] = {};
  }

  if(generate || Environment.instance.collection.cachedImageRarity[l]![rarity] == null) {
    List<Widget> rendering = rarity.icon(l, iconSize: iconSize, fontSize: fontSize, textureSize: textureSize);
    if(generate) {
      return rendering;
    } else {
      Environment.instance.collection.cachedImageRarity[l]![rarity] = rendering;
    }
  }
  return Environment.instance.collection.cachedImageRarity[l]![rarity]!;
}