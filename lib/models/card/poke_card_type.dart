import 'package:flutter/material.dart';

const double iconSize = 25.0;

// Fr type / rarity -> NEVER CHANGED ORDER
enum PokeCardType {
  plante,
  feu,
  eau,
  electrique,
  psy,
  combat,
  obscurite,
  metal,
  fee,
  dragon,
  incolore,
  objet,
  supporter,
  stade,
  energy,
  unknown,
  marker,
  objetPokemon,
}
const List<PokeCardType> orderedType = [
  PokeCardType.unknown, PokeCardType.plante,    PokeCardType.feu,   PokeCardType.eau, PokeCardType.electrique, PokeCardType.psy,
  PokeCardType.combat,  PokeCardType.obscurite, PokeCardType.metal, PokeCardType.fee,
  PokeCardType.dragon,  PokeCardType.incolore,  PokeCardType.objet, PokeCardType.objetPokemon, PokeCardType.supporter, PokeCardType.stade, PokeCardType.energy,
  PokeCardType.marker,
];

bool isPokemonCard(PokeCardType type) {
  const List<PokeCardType> notPokemon = [PokeCardType.objet, PokeCardType.objetPokemon, PokeCardType.supporter, PokeCardType.stade, PokeCardType.energy, PokeCardType.marker];
  return !notPokemon.contains(type);
}

const Map imageName = {
  PokeCardType.plante: 'plante',
  PokeCardType.feu: 'feu',
  PokeCardType.eau: 'eau',
  PokeCardType.electrique: 'electrique',
  PokeCardType.psy: 'psy',
  PokeCardType.combat: 'combat',
  PokeCardType.obscurite: 'obscure',
  PokeCardType.metal: 'metal',
  PokeCardType.incolore: 'incolore',
  PokeCardType.fee: 'fee',
  PokeCardType.dragon: 'dragon',
};

bool isPokemonType(PokeCardType type) {
  return type != PokeCardType.energy
      && type != PokeCardType.objet
      && type != PokeCardType.objetPokemon
      && type != PokeCardType.supporter
      && type != PokeCardType.stade
      && type != PokeCardType.marker;
}

const List<PokeCardType> energies = [PokeCardType.plante,  PokeCardType.feu,  PokeCardType.eau,
  PokeCardType.electrique,  PokeCardType.psy,  PokeCardType.combat,  PokeCardType.obscurite,
  PokeCardType.metal, PokeCardType.fee,  PokeCardType.dragon, PokeCardType.incolore];

const List<Color> energiesColors = [Colors.green, Colors.red, Colors.blue,
  Colors.yellow, Color(0xFF8E24AA), Color(0xFFD84315), Color(0xFF311B92),
  Color(0xFF7D7D7D),  Colors.pinkAccent, Colors.orange, Colors.white70,
];

const List<Color> generationColor = [
  Colors.black, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
];

List<Color> typeColors = energiesColors + [const Color(0xFF1976D2), const Color(0xFFC62828), const Color(0xFFB9F6CA), const Color(0xFFFFFF8D),
  Colors.black, Colors.greenAccent, Colors.deepPurple];

Widget energyImage(PokeCardType type, {double sizeIcon = iconSize}) {
  assert (type != PokeCardType.unknown);
  Widget iconWidget;
  if (imageName[type].isNotEmpty) {
    iconWidget = Image(
      image: AssetImage('assets/energie/${imageName[type]}.png'),
      width: sizeIcon,
    );
  } else {
    iconWidget = const Icon(Icons.help_outline);
  }
  return iconWidget;
}

List<Widget?> cachedImageType = List.filled(PokeCardType.values.length, null);

Widget getImageType(PokeCardType type, {bool generate=false, double? sizeIcon})
{
  Widget iconWidget;
  if(generate || cachedImageType[type.index] == null) {
    switch(type) {
      case PokeCardType.objet:
        iconWidget = Icon(Icons.build, color: Colors.blueAccent, size: sizeIcon);
        break;
      case PokeCardType.objetPokemon:
        iconWidget = Icon(Icons.build, color: Colors.deepPurple, size: sizeIcon);
        break;
      case PokeCardType.stade:
        iconWidget = Icon(Icons.landscape, color: Colors.green[700], size: sizeIcon);
        break;
      case PokeCardType.supporter:
        iconWidget = Icon(Icons.accessibility_new, color: Colors.red[900], size: sizeIcon);
        break;
      case PokeCardType.energy:
        iconWidget = Icon(Icons.battery_charging_full, size: sizeIcon);
        break;
      case PokeCardType.marker:
        iconWidget = Icon(Icons.bookmark_border, size: sizeIcon);
        break;
      case PokeCardType.unknown:
        iconWidget = Icon(Icons.help_outline, size: sizeIcon);
        break;
      default:
        iconWidget = energyImage(type, sizeIcon: sizeIcon ?? iconSize);
    }

    if(generate) {
      return iconWidget;
    } else {
      cachedImageType[type.index] = iconWidget;
    }
  }
  return cachedImageType[type.index]!;
}