import 'package:flutter/material.dart';

enum Design {
  Basic,
  Holographic,
  ArcEnCiel,
  Gold,
}

Widget icon(Design design) {
  switch(design) {
    case Design.Basic:
      return Icon(Icons.article_outlined);
    case Design.Holographic:
      return Icon(Icons.article);
    case Design.ArcEnCiel:
      return Icon(Icons.looks);
    case Design.Gold:
      return Icon(Icons.stars_rounded, color: Colors.yellow.shade700);
    default:
      return Icon(Icons.help_outline);
  }
}