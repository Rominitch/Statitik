import 'package:flutter/material.dart';

const double iconSize = 25.0;

// Fr type / rarity -> NEVER CHANGED ORDER
enum TypeCard {
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
const List<TypeCard> orderedType = [
  TypeCard.unknown, TypeCard.plante, TypeCard.feu, TypeCard.eau, TypeCard.electrique, TypeCard.psy,
  TypeCard.combat, TypeCard.obscurite, TypeCard.metal, TypeCard.fee,
  TypeCard.dragon, TypeCard.incolore, TypeCard.objet, TypeCard.objetPokemon, TypeCard.supporter, TypeCard.stade, TypeCard.energy,
  TypeCard.marker,
];

bool isPokemonCard(TypeCard type) {
  const List<TypeCard> notPokemon = [TypeCard.objet, TypeCard.objetPokemon, TypeCard.supporter, TypeCard.stade, TypeCard.energy, TypeCard.marker];
  return !notPokemon.contains(type);
}

const Map imageName = {
  TypeCard.plante: 'plante',
  TypeCard.feu: 'feu',
  TypeCard.eau: 'eau',
  TypeCard.electrique: 'electrique',
  TypeCard.psy: 'psy',
  TypeCard.combat: 'combat',
  TypeCard.obscurite: 'obscure',
  TypeCard.metal: 'metal',
  TypeCard.incolore: 'incolore',
  TypeCard.fee: 'fee',
  TypeCard.dragon: 'dragon',
};

bool isPokemonType(type) {
  return type != TypeCard.energy
      && type != TypeCard.objet
      && type != TypeCard.objetPokemon
      && type != TypeCard.supporter
      && type != TypeCard.stade
      && type != TypeCard.marker;
}

const List<TypeCard> energies = [TypeCard.plante,  TypeCard.feu,  TypeCard.eau,
  TypeCard.electrique,  TypeCard.psy,  TypeCard.combat,  TypeCard.obscurite,
  TypeCard.metal, TypeCard.fee,  TypeCard.dragon, TypeCard.incolore];

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

Widget energyImage(TypeCard type, {double sizeIcon = iconSize}) {
  assert (type != TypeCard.unknown);
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

List<Widget?> cachedImageType = List.filled(TypeCard.values.length, null);

Widget getImageType(TypeCard type, {bool generate=false, double? sizeIcon})
{
  Widget iconWidget;
  if(generate || cachedImageType[type.index] == null) {
    switch(type) {
      case TypeCard.objet:
        iconWidget = Icon(Icons.build, color: Colors.blueAccent, size: sizeIcon);
        break;
      case TypeCard.objetPokemon:
        iconWidget = Icon(Icons.build, color: Colors.deepPurple, size: sizeIcon);
        break;
      case TypeCard.stade:
        iconWidget = Icon(Icons.landscape, color: Colors.green[700], size: sizeIcon);
        break;
      case TypeCard.supporter:
        iconWidget = Icon(Icons.accessibility_new, color: Colors.red[900], size: sizeIcon);
        break;
      case TypeCard.energy:
        iconWidget = Icon(Icons.battery_charging_full, size: sizeIcon);
        break;
      case TypeCard.marker:
        iconWidget = Icon(Icons.bookmark_border, size: sizeIcon);
        break;
      case TypeCard.unknown:
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