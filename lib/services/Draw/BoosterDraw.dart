import 'dart:async';

import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';

class BoosterDraw {
  late int id;
  final SubExtension? creation;    ///< Keep product extension.
  final int nbCards;               ///< Number of cards inside booster
  ///
  late ExtensionDrawCards? cardDrawing;   ///< All card select by extension.
  late SubExtension?       subExtension;  ///< Current extensions.
  int count = 0;
  bool abnormal = false;          ///< Packaging error

  // Event
  final StreamController onEnergyChanged = StreamController.broadcast();

  static const int _limitSet = 7;

  BoosterDraw({this.creation, required this.id, required this.nbCards})
  {
    assert(nbCards > 0);
    subExtension = creation;
    fillCard();
  }

  void closeStream() {
    onEnergyChanged.close();
  }

  bool isRandom() {
    return creation == null;
  }

  String nameCard(int id) {
    if(subExtension != null) {
      return subExtension!.seCards.numberOfCard(id);
    } else {
      return (id + 1).toString();
    }
  }

  void resetBooster() {
    count        = 0;
    abnormal     = false;
    cardDrawing  = null;
  }

  void resetExtensions() {
    resetBooster();
    cardDrawing  = null;
    subExtension = null;
  }

  void fillCard() {
    if(hasSubExtension()) {
      cardDrawing = ExtensionDrawCards.fromSubExtension(subExtension!);
    }
  }

  bool isFinished() {
    return abnormal ? count >=1 : count == nbCards;
  }

  bool hasSubExtension() {
    return subExtension != null;
  }

  bool canAdd() {
    return abnormal ? true : count < nbCards;
  }

  int countEnergy() {
    int count=0;
    for( CodeDraw c in cardDrawing!.drawEnergies ){
      count += c.count();
    }
    return count;
  }

  /// Toggle first card (but reset other)
  void toggleCard(List<CodeDraw> codes, int set, int limit) {
    var code = codes[0];
    // Remove alternative state
    codes.skip(1).forEach((otherCode) {
      count -= otherCode.count();
      otherCode.reset();
    });

    count -= code.count();
    if(code.isEmpty()) {
      if(canAdd()) {
        code.reset();
        code.increase(set, limit);
      }
    } else {
      code.reset();
    }
    count += code.count();
  }

  void toggle(CodeDraw code, int set) {
    count -= code.count();
    if(code.isEmpty()) {
      if(canAdd()) {
        code.reset();
        code.increase(set, _limitSet);
      }
    } else {
      code.reset();
    }
    count += code.count();
  }

  void increase(CodeDraw code, int set) {
    if(canAdd()) {
      count -= code.count();
      code.increase(set, _limitSet);
      count += code.count();
    }
  }

  void decrease(CodeDraw code, int set) {
    if(count > 0) {
      count -= code.count();
      code.decrease(set);
      count += code.count();
    }
  }

  void setOtherRendering(CodeDraw code, int set) {
    if(canAdd()) {
      count -= code.count();

      code.reset();
      code.increase(set, _limitSet);

      count += code.count();
    }
  }

  bool needReset() {
    return true;
  }

  void revertAnomaly() {
    resetBooster();
    fillCard();
  }

  Validator validationWorld(final Language language) {
    if(abnormal) {
      return Validator.Valid;
    }

    // Fr and US
    if(language.id == 1 || language.id == 2) {
      int energyAndMarker = 0;
      int goodCard        = 0;
      int alternativeSet  = 0; // Other than standard or standard brillant

      // Functor
      var addAlternativeCard = (CodeDraw code, PokemonCardExtension card) {
        alternativeSet += code.countBoosterReversePosition(card);
      };

      // No number
      int idCardNum = 0;
      cardDrawing!.drawNoNumber.forEach((element) {
        var localCount = element.count();
        if(localCount > 0) {
          var idCard = CardIdentifier.from([2, idCardNum]);
          var card = subExtension!.cardFromId(idCard);

          // Check alternative
          addAlternativeCard(element, card);
          // Check marker
          if( card.data.type == TypeCard.Marker) {
            energyAndMarker += localCount;
          }
        }
        idCardNum += 1;
      });

      // Energy
      idCardNum = 0;
      cardDrawing!.drawEnergies.forEach((element) {
        var localCount = element.count();
        if(localCount > 0) {
          var idCard = CardIdentifier.from([1, idCardNum]);
          var card = subExtension!.cardFromId(idCard);

          energyAndMarker += localCount;
          addAlternativeCard(element, card);
        }
        idCardNum += 1;
      });

      if (subExtension!.seCards.hasBoosterEnergy() && energyAndMarker != 1 && energyAndMarker != 2) {
        return Validator.ErrorEnergy;
      }

      // Parsing all cards after
      idCardNum = 0;
      cardDrawing!.drawCards.forEach((cards) {
        int idLocalCard = 0;
        cards.forEach((element) {
          var localCount = element.count();
          if(localCount > 0) {
            var idCard = CardIdentifier.from([0, idCardNum, idLocalCard]);
            var card = subExtension!.cardFromId(idCard);

            addAlternativeCard(element, card);
            if( card.isGoodCard() ) {
              goodCard += localCount;
            }
          }
          idLocalCard += 1;
        });
        idCardNum += 1;
      });

      if (subExtension!.seCards.hasAlternativeSet() && alternativeSet != 1 && alternativeSet != 2) {
        return Validator.ErrorReverse;
      }
      if (goodCard > 3) {
        return Validator.ErrorTooManyGood;
      }
    }
    return Validator.Valid;
  }

  void fill(SubExtension newSubExtension, bool abnormalBooster, ExtensionDrawCards edc)
  {
    subExtension = newSubExtension;
    abnormal     = abnormalBooster;

    // Fill with full SubExtension data
    fillCard();

    // Fill with saved data (always less data because zero are deleted)
    count = cardDrawing!.fillWith(edc);
  }
}