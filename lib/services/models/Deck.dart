import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/BytesCoder.dart';
import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';

class DeckCardInfo {
  SubExtension   se;
  CardIdentifier idCard;
  int            count;

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
          parser.extractInt8()
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
      bytes += ByteEncoder.encodeInt16(card.count);
    });
    return bytes;
  }

  void computeStats() {

  }
}

class DeckStats
{
  List<int>          countByLevel = [];
  Map<TypeCard, int> countByType  = {};

  DeckStats();
}