import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class CardIntoSubExtensions {
  SubExtension         se;
  CardIdentifier       idCard;
  PokemonCardExtension card;

  CardIntoSubExtensions(SubExtension currentSe, CardIdentifier currentIdCard) :
    se     = currentSe,
    idCard = currentIdCard,
    card   = currentSe.seCards.cardFromId(currentIdCard);

  CardIntoSubExtensions.withAll(this.se, this.idCard, this.card);
}