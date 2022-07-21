import 'dart:math';

import 'package:statitikcard/services/draw/card_draw_data.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';

class DeckCardInfo {
  SubExtension   se;
  CardIdentifier idCard;
  CodeDraw       count;

  DeckCardInfo(this.se, this.idCard, this.count);
}

class Deck
{
  String             name  = "";
  List<DeckCardInfo> cards = [];
  DeckStats          stats = DeckStats();

  static const int version = 1;

  Deck(this.name);

  Deck.fromBytes(ByteParser parser, Map subExtensions) {
    int currentVersion = parser.extractInt8();
    if(currentVersion != version) {
      throw StatitikException("Unknown Product version: $currentVersion");
    }
    name = parser.decodeString16();

    var nbCards = parser.extractInt8();
    for(int id=0; id < nbCards; id +=1) {
      var idSe = parser.extractInt16();
      var idCard = CardIdentifier.fromBytes(parser);

      cards.add(
        DeckCardInfo(subExtensions[idSe],
          idCard,
          CodeDraw.fromBytes(parser)
      ));
    }

    // Now compute all stats
    computeStats();
  }

  List<int> toBytes() {
    List<int> bytes = [version];
    bytes += ByteEncoder.encodeString16(name.codeUnits);
    bytes += ByteEncoder.encodeInt8(cards.length);
    for (var card in cards) {
      bytes += ByteEncoder.encodeInt16(card.se.id);
      bytes += card.idCard.toBytes();
      bytes += card.count.toBytes();
    }
    return bytes;
  }

  void computeStats() {
    stats = DeckStats.from(cards);
  }
}

class MMMState
{
  int minV;
  int sum;
  int count;
  int maxV;

  MMMState(int value) :
    minV = value, sum = value, maxV = value, count =1;

  void add(int value) {
    minV = min(minV, value);
    maxV = max(maxV, value);
    sum += value;
    count += 1;
  }
}

class DeckStats
{
  int                nbCards=0;
  List<int>          countByLevel = [];
  Map<TypeCard, int> countByType  = {};
  List<TypeCard>     energyTypes  = [];
  Map<int, int>      countPokemon = {};
  int                nbCardsPokemon=0;

  MMMState?          hpStats;
  MMMState?          retreatStats;
  List<TypeCard>     powerEnergies = [];
  Map<TypeCard, int> countWeakness = {};
  Map<TypeCard, int> countResistance = {};

  DeckStats();

  DeckStats.from(List<DeckCardInfo> cards) {
    countByLevel = List<int>.generate(Level.values.length, (index) => 0);
    // Parse cards
    for(var cardInfo in cards) {
      var count = cardInfo.count.count();
      nbCards += count;
      var card = cardInfo.se.cardFromId(cardInfo.idCard);
      // Check energy
      if(card.data.type == TypeCard.energy && card.data.typeExtended != null) {
        if(!energyTypes.contains(card.data.typeExtended)) {
          energyTypes.add(card.data.typeExtended!);
        }
      }
      // Check pokemon level
      if(card.data.level != Level.withoutLevel) {
        countByLevel[card.data.level.index] += count;
      }

      // check pokemon
      if(card.data.type.index <= TypeCard.incolore.index) {
        var info = card.data.title[0].name as PokemonInfo;
        nbCardsPokemon += count;
        if( countPokemon.containsKey(info.idPokedex) ) {
          countPokemon[info.idPokedex] = countPokemon[info.idPokedex]! + count;
        } else {
          countPokemon[info.idPokedex] = count;
        }

        // HP
        if(hpStats == null) {
          hpStats = MMMState(card.data.life);
        } else {
          hpStats!.add(card.data.life);
        }

        // Retreat
        if(retreatStats == null) {
          retreatStats = MMMState(card.data.retreat);
        } else {
          retreatStats!.add(card.data.retreat);
        }

        // Weakness
        if(card.data.weakness != null) {
          if( !countWeakness.containsKey(card.data.weakness!) ) {
            countWeakness[card.data.weakness!.energy] = 1;
          } else {
            countWeakness[card.data.weakness!.energy] = countWeakness[card.data.weakness!.energy]! + 1;
          }
        }

        // Resistance
        if(card.data.resistance != null) {
          if( !countResistance.containsKey(card.data.resistance!) ) {
            countResistance[card.data.resistance!.energy] = 1;
          } else {
            countResistance[card.data.resistance!.energy] = countResistance[card.data.resistance!.energy]! + 1;
          }
        }

        // Count energy in power
        for (var effect in card.data.cardEffects.effects) {
          for (var energy in effect.attack) {
            if( !powerEnergies.contains(energy) ) {
              powerEnergies.add(energy);
            }
          }
        }
      }

      if(countByType.containsKey(card.data.type)) {
        countByType[card.data.type] = countByType[card.data.type]! + count;
      } else {
        countByType[card.data.type] = count;
      }
    }
  }
}