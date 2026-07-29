
import 'package:flutter/material.dart';
import 'package:statitikcard/services/internationalization.dart';

enum PokeLevel {
  base,
  level1,
  level2,
  withoutLevel;

  static String getLevelText(BuildContext context, PokeLevel element) {
    const List<String> levelString = ['LEVEL_0', 'LEVEL_1', 'LEVEL_2', 'LEVEL_3'];
    return StatitikLocale.of(context).read(levelString[element.index]);
  }
}

