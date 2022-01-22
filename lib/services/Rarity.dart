import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';

// NEVER CHANGED ORDER
enum Rarity {
  Commune,
  JC,
  PeuCommune,
  JU,
  Rare,
  JR,
  HoloRare,
  Magnifique,
  JA,
  Prism,
  Chromatique,
  JS,
  Turbo,
  V, // or GX /Ex
  JRR,
  VMax,
  JRRR,
  BrillantRare, //PB
  UltraRare,
  ChromatiqueRare,
  JSSR,
  Secret,
  JSR,
  ArcEnCiel,
  JHR,
  Gold,
  HoloRareSecret,
  JUR,
  Unknown,
  Empty,
  JCHR,
  JCSR,
  JPR,
  JK,
  // Add new HERE !
}

const List<Rarity> orderedRarity = const[
  Rarity.Empty, Rarity.Unknown,
  Rarity.Commune, Rarity.JC, Rarity.PeuCommune, Rarity.JU, Rarity.Rare, Rarity.JR,
  Rarity.HoloRare, Rarity.Magnifique, Rarity.JA, Rarity.Prism, Rarity.JPR,
  Rarity.Chromatique, Rarity.JK, Rarity.JS,  Rarity.Turbo,  Rarity.V, // or GX /Ex
  Rarity.JRR,  Rarity.VMax,  Rarity.JRRR,  Rarity.BrillantRare, //PB
  Rarity.UltraRare,  Rarity.ChromatiqueRare,  Rarity.JSSR,  Rarity.Secret, Rarity.JCHR,
  Rarity.JSR,  Rarity.ArcEnCiel,  Rarity.JHR, Rarity.JCSR, Rarity.Gold,  Rarity.HoloRareSecret,  Rarity.JUR,
];

const List<Color> rarityColors =
[
  Colors.green, Colors.green, Color(0xFF43A047), Color(0xFF43A047), Color(0xFF388E3C), Color(0xFF388E3C),   // C JC P JU R JR
  Colors.blue, Color(0xFF1E88E5), Color(0xFF1E88E5), Color(0xFF1976D2), Color(0xFF1565C0),                  // H M JA P C
  Colors.purple, Colors.purple, Colors.purple,                                               // Ch JS T
  Color(0xFF8E24AA), Color(0xFF8E24AA), Color(0xFF7B1FA2), Color(0xFF6A1B9A), Color(0xFF6A1B9A),            // V JRR Vm JRRR PB
  Colors.yellow, Colors.yellow, Color(0xFFFDD835), Color(0xFFFDD835), Color(0xFFFBC02D), Color(0xFFFBC02D), Color(0xFFF9A825), Color(0xFFF9A825), Color(0xFFF9A825),           // ChR JSSR S JSR A JHR G HS JUR
  Colors.black, Colors.green, // unknown, Empty
  Color(0xFFFDD835), Color(0xFFD8C835), Color(0xFF185192), Color(0xFF1565C0) // CHR CSR Pr JK
];

const List<Rarity> worldRarity = [Rarity.Empty, Rarity.Commune, Rarity.PeuCommune, Rarity.Rare,
  Rarity.HoloRare, Rarity.Magnifique, Rarity.Prism, Rarity.Chromatique, Rarity.Turbo,
  Rarity.V, Rarity.VMax, Rarity.BrillantRare, Rarity.UltraRare,
  Rarity.ChromatiqueRare, Rarity.Secret, Rarity.ArcEnCiel, Rarity.Gold, Rarity.HoloRareSecret
];
const List<Rarity> japanRarity = [Rarity.Empty, Rarity.JC, Rarity.JU, Rarity.JR, Rarity.JPR, Rarity.JRR,
  Rarity.JRRR, Rarity.JSR, Rarity.JHR, Rarity.JUR, Rarity.JCHR, Rarity.JCSR, Rarity.JA, Rarity.JK, Rarity.JS, Rarity.JSSR
];

const List<Rarity> goodCard = [
  Rarity.HoloRare,
  Rarity.Magnifique,
  Rarity.JA,
  Rarity.Prism,
  Rarity.JPR,
  Rarity.Chromatique,
  Rarity.JK,
  Rarity.JS,
  Rarity.Turbo,
  Rarity.V,
  Rarity.JRR,
  Rarity.VMax,
  Rarity.JRRR,
  Rarity.BrillantRare,
  Rarity.UltraRare,
  Rarity.ChromatiqueRare,
  Rarity.JSSR,
  Rarity.Secret,
  Rarity.JSR,
  Rarity.ArcEnCiel,
  Rarity.JHR,
  Rarity.Gold,
  Rarity.HoloRareSecret,
  Rarity.JUR,
  Rarity.JCHR,
  //Rarity.JCSR,
];

const List<Rarity> otherThanReverse = const [
  Rarity.Magnifique,
  Rarity.Chromatique,
  Rarity.ChromatiqueRare,
];

const List<Rarity> baseSet = const [
  Rarity.Commune,
  Rarity.JC,
  Rarity.PeuCommune,
  Rarity.JU,
  Rarity.Rare,
  Rarity.JR,
  Rarity.HoloRare,
  Rarity.Magnifique,
  Rarity.V, // or GX /Ex
  Rarity.JRR,
  Rarity.VMax,
  Rarity.JRRR
];

List<List<Widget>?> cachedImageRarity = List.filled(Rarity.values.length, null);

List<Widget> getImageRarity(Rarity rarity, {iconSize, fontSize=12.0, generate=false}) {
  if(generate || cachedImageRarity[rarity.index] == null) {
    List<Widget> rendering;
    //star_border
    switch(rarity) {
      case Rarity.Commune:
        rendering = [Icon(Icons.circle, size: iconSize)];
        break;
      case Rarity.PeuCommune:
        rendering = [Transform.rotate(
            angle: pi / 4.0,
            child: Icon(Icons.stop, size: iconSize))];
        break;
      case Rarity.Rare:
        rendering = [Icon(Icons.star, size: iconSize,)];
        break;
      case Rarity.Prism:
        rendering = [Icon(Icons.star, size: iconSize), Text('P', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Chromatique:
        rendering = [Icon(Icons.star, size: iconSize), Text('CH', style: TextStyle(fontSize: fontSize-2.0))];
        break;
      case Rarity.ChromatiqueRare:
        rendering = [Icon(Icons.star_border, size: iconSize), Text('CH', style: TextStyle(fontSize: fontSize-2.0))];
        break;
      case Rarity.V:
        rendering = [Icon(Icons.star_border, size: iconSize)];
        break;
      case Rarity.VMax:
        rendering = [Icon(Icons.star, size: iconSize), Text('X', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Turbo:
        rendering = [Icon(Icons.star, size: iconSize), Text('T', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.HoloRare:
        rendering = [Icon(Icons.star, size: iconSize), Text('H', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.BrillantRare:
        rendering = [Icon(Icons.star, size: iconSize), Text('PB', style: TextStyle(fontSize: fontSize-2.0))];
        break;
      case Rarity.UltraRare:
        rendering = [Icon(Icons.star, size: iconSize), Text('U', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Magnifique:
        rendering = [Icon(Icons.star, size: iconSize), Text('M', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Secret:
        rendering = [Icon(Icons.star_border, size: iconSize), Text('S', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.HoloRareSecret:
        rendering = [Icon(Icons.star_border, size: iconSize), Text('H', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.ArcEnCiel:
        rendering = [Icon(Icons.looks, size: iconSize)];
        break;
      case Rarity.Gold:
        rendering = [Icon(Icons.local_play, size: iconSize, color: Colors.yellow[300])];
        break;
      case Rarity.Unknown:
        rendering = [Icon(Icons.help_outline, size: iconSize)];
        break;

      case Rarity.JC:
        rendering = [Text('C', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JU:
        rendering = [Text('U', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JR:
        rendering = [Text('R', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JRR:
        rendering = [Text('RR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JRRR:
        rendering = [Text('RRR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JSR:
        rendering = [Text('SR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JHR:
        rendering = [Text('HR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JUR:
        rendering = [Text('UR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JA:
        rendering = [drawCachedImage('logo', 'a', height: iconSize ?? 20)];
        break;
      case Rarity.JK:
        rendering = [Text('K', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JS:
        rendering = [Text('S', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JSSR:
        rendering = [Text('SSR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JCHR:
        rendering = [Text('CHR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JCSR:
        rendering = [Text('CSR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.JPR:
        rendering = [Text('PR', style: TextStyle(fontSize: fontSize))];
        break;
      case Rarity.Empty:
        rendering = [Text('')];
        break;
      default:
        rendering = [Icon(Icons.help_outline, size: iconSize)];
        assert(false);
    //throw Exception("Unknown rarity: $rarity");
    }
    if(generate)
      return rendering;
    else
      cachedImageRarity[rarity.index] = rendering;
  }
  return cachedImageRarity[rarity.index]!;
}