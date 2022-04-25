import 'package:statitikcard/services/models/CardIdentifier.dart';
import 'package:statitikcard/services/models/PokemonCardExtension.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class CardIntoSubExtensions {
  SubExtension         se;
  CardIdentifier       idCard;
  PokemonCardExtension card;

  CardIntoSubExtensions(SubExtension se, CardIdentifier idCard) :
    this.se = se, this.idCard = idCard,
    this.card = se.seCards.cardFromId(idCard);

  CardIntoSubExtensions.withAll(this.se, this.idCard, this.card);
}