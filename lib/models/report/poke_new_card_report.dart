
import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_expansion.dart';

class PokeNewCardReport {
  PokeCardIdentifier  idCard;
  PokeCardDraw        state;

  PokeNewCardReport(this.idCard, this.state);

  int compareTo(PokeNewCardReport other) {
    return idCard.compareTo(other.idCard);
  }
}

class PokeNewCardsReport {
  Map<PokeExpansion, List<PokeNewCardReport>> result = {};

  void add(PokeExpansion subExtension, PokeNewCardReport code) {
    if( !result.containsKey(subExtension) ){
      result[subExtension] = [];
    }
    var list = result[subExtension]!;

    // Search for merge
    bool find=false;
    for(int id=0; id < list.length; id +=1) {
      if( list[id].idCard.isEqual(code.idCard) ) {
        list[id].state.add(code.state);

        find=true;
        break;
      }
    }

    // else Add new
    if(!find) {
      result[subExtension]!.add(code);
    }
  }

  void sort() {
    result.forEach((key, list) {
      list.sort((a, b) => a.compareTo(b));
    });
  }
}