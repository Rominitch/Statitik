import 'package:flutter/material.dart';

const double iconSize = 25.0;

// Fr type / rarity -> NEVER CHANGED ORDER
enum TypeCard {
  Plante,
  Feu,
  Eau,
  Electrique,
  Psy,
  Combat,
  Obscurite,
  Metal,
  Fee,
  Dragon,
  Incolore,
  Objet,
  Supporter,
  Stade,
  Energy,
  Unknown,
  Marker,
}
const List<TypeCard> orderedType = const[
  TypeCard.Unknown, TypeCard.Plante, TypeCard.Feu, TypeCard.Eau, TypeCard.Electrique, TypeCard.Psy,
  TypeCard.Combat, TypeCard.Obscurite, TypeCard.Metal, TypeCard.Fee,
  TypeCard.Dragon, TypeCard.Incolore, TypeCard.Objet, TypeCard.Supporter, TypeCard.Stade, TypeCard.Energy,
  TypeCard.Marker,
];

bool isPokemonCard(TypeCard type) {
  const List<TypeCard> notPokemon = [TypeCard.Objet, TypeCard.Supporter, TypeCard.Stade, TypeCard.Energy, TypeCard.Marker];
  return !notPokemon.contains(type);
}

const Map imageName = {
  TypeCard.Plante: 'plante',
  TypeCard.Feu: 'feu',
  TypeCard.Eau: 'eau',
  TypeCard.Electrique: 'electrique',
  TypeCard.Psy: 'psy',
  TypeCard.Combat: 'combat',
  TypeCard.Obscurite: 'obscure',
  TypeCard.Metal: 'metal',
  TypeCard.Incolore: 'incolore',
  TypeCard.Fee: 'fee',
  TypeCard.Dragon: 'dragon',
};

bool isPokemonType(type) {
  return type != TypeCard.Energy
      && type != TypeCard.Objet
      && type != TypeCard.Supporter
      && type != TypeCard.Stade
      && type != TypeCard.Marker;
}

const List<TypeCard> energies = [TypeCard.Plante,  TypeCard.Feu,  TypeCard.Eau,
  TypeCard.Electrique,  TypeCard.Psy,  TypeCard.Combat,  TypeCard.Obscurite,
  TypeCard.Metal, TypeCard.Fee,  TypeCard.Dragon, TypeCard.Incolore];

const List<Color> energiesColors = [Colors.green, Colors.red, Colors.blue,
  Colors.yellow, Color(0xFF8E24AA), Color(0xFFD84315), Color(0xFF311B92),
  Color(0xFF7D7D7D),  Colors.pinkAccent, Colors.orange, Colors.white70,
];

const List<Color> generationColor = [
  Colors.black, Colors.blue, Colors.red, Colors.green, Colors.brown,
  Colors.amber, Colors.brown, Colors.deepPurpleAccent, Colors.teal
];

List<Color> typeColors = energiesColors + [Color(0xFF1976D2), Color(0xFFC62828), Color(0xFFB9F6CA), Color(0xFFFFFF8D), Colors.black, Colors.greenAccent];

Widget energyImage(TypeCard type, {double sizeIcon = iconSize}) {
  assert (type != TypeCard.Unknown);
  var iconWidget;
  if (imageName[type].isNotEmpty) {
    iconWidget = Image(
      image: AssetImage('assets/energie/${imageName[type]}.png'),
      width: sizeIcon,
    );
  }
  return iconWidget;
}

List<Widget?> cachedImageType = List.filled(TypeCard.values.length, null);

Widget getImageType(TypeCard type, {bool generate=false, double? sizeIcon})
{
  var iconWidget;
  if(generate || cachedImageType[type.index] == null) {
    switch(type) {
      case TypeCard.Objet:
        iconWidget = Icon(Icons.build, color: Colors.blueAccent, size: sizeIcon);
        break;
      case TypeCard.Stade:
        iconWidget = Icon(Icons.landscape, color: Colors.green[700], size: sizeIcon);
        break;
      case TypeCard.Supporter:
        iconWidget = Icon(Icons.accessibility_new, color: Colors.red[900], size: sizeIcon);
        break;
      case TypeCard.Energy:
        iconWidget = Icon(Icons.battery_charging_full, size: sizeIcon);
        break;
      case TypeCard.Marker:
        iconWidget = Icon(Icons.bookmark_border, size: sizeIcon);
        break;
      case TypeCard.Unknown:
        iconWidget = Icon(Icons.help_outline, size: sizeIcon);
        break;
      default:
        iconWidget = energyImage(type, sizeIcon: sizeIcon ?? iconSize);
    }

    if(generate)
      return iconWidget;
    else
      cachedImageType[type.index] = iconWidget;

  }
  return cachedImageType[type.index]!;
}