
import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';

enum PokeLevel {
  base,
  level1,
  level2,
  withoutLevel;

  static String getLevelText(BuildContext context, PokeLevel element) {
    switch(element) {
      case PokeLevel.base: return AppLocalizations.of(context)!.level_0;
      case PokeLevel.level1: return AppLocalizations.of(context)!.level_1;
      case PokeLevel.level2: return AppLocalizations.of(context)!.level_2;
      case PokeLevel.withoutLevel: return "";
    }
  }
}

