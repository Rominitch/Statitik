import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';

enum SerieType {
  normal,
  promo,
  deck,
}

String serieType(BuildContext context, SerieType type) {
  switch(type)
  {
    case SerieType.normal: return AppLocalizations.of(context)!.se_type_0;
    case SerieType.promo:  return AppLocalizations.of(context)!.se_type_1;
    case SerieType.deck:   return AppLocalizations.of(context)!.se_type_2;
  }
}
