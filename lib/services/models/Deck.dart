import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/CardTitleData.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
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
    cards.forEach((card) {
      bytes += ByteEncoder.encodeInt16(card.se.id);
      bytes += card.idCard.toBytes();
      bytes += card.count.toBytes();
    });
    return bytes;
  }

  void computeStats() {
    stats = DeckStats.from(cards);
  }
}

class DeckStats
{
  int                nbCards=0;
  List<int>          countByLevel = [];
  Map<TypeCard, int> countByType  = {};
  List<TypeCard>     energyTypes  = [];
  Map<int, int>      countPokemon = {};

  DeckStats();

  DeckStats.from(List<DeckCardInfo> cards) {
    countByLevel = List<int>.generate(Level.values.length, (index) => 0);
    // Parse cards
    for(var cardInfo in cards) {
      var count = cardInfo.count.count();
      nbCards += count;
      var card = cardInfo.se.cardFromId(cardInfo.idCard);
      // Check energy
      if(card.data.type == TypeCard.Energy && card.data.typeExtended != null) {
        if(!energyTypes.contains(card.data.typeExtended))
          energyTypes.add(card.data.typeExtended!);
      }
      // Check pokemon level
      if(card.data.level != Level.WithoutLevel) {
        countByLevel[card.data.level.index] += count;
      }

      // check pokemon
      if(card.data.type.index <= TypeCard.Incolore.index) {
        var info = card.data.title[0].name as PokemonInfo;
        if( countPokemon.containsKey(info.idPokedex) )
          countPokemon[info.idPokedex] = countPokemon[info.idPokedex]! + count;
        else
          countPokemon[info.idPokedex] = count;
      }

      if(countByType.containsKey(card.data.type)) {
        countByType[card.data.type] = countByType[card.data.type]! + count;
      } else {
        countByType[card.data.type] = count;
      }
    }
  }
}