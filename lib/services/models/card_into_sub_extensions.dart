import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

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