import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/type_card.dart';
/*
class CardEffect {
  int?              title;       /// Title of capacity if exist.
  CardDescription?  description; /// Description if exists.

  int             power  = 0;   /// Zero = no attack.
  List<TypeCard>  attack = [];  /// Energy to attach for attack.

  CardEffect();
  CardEffect.fromBytes(ByteParser parser) {
    int idEffect = parser.extractInt16();
    if(idEffect != 0) {
      title = idEffect;
    }

    var newDescription = CardDescription.fromBytes(parser);
    if(newDescription.idDescription > 0) {
      description = newDescription;
    }

    power = parser.extractInt16();

    int nbAttack = parser.extractInt8();
    for(int i = 0; i < nbAttack; i +=1) {
      var t = TypeCard.values[parser.extractInt8()];
      if(t != TypeCard.unknown) {
        attack.add(t);
      }
    }
  }

  List<int> toBytes() {
    int idEffect      = title ?? 0;
    List<int> att = [attack.length];
    for (var element in attack) { att.add(element.index); }

    //int 16 = 65k value
    return <int>[ (idEffect & 0xFF00) >> 8,(idEffect & 0xFF)] +
        (description != null ? description!.toBytes() : [0, 0]) +
        [ (power & 0xFF00) >> 8, (power & 0xFF)] + att;
  }
}

class CardEffects {
  List<CardEffect> effects = [];

  static const int version = 1;

  CardEffects();

  CardEffects.fromEffects(this.effects);

  CardEffects.fromBytesArray(List<int> bytes) {
    if(bytes[0] != version) {
      throw StatitikException('Bad CardEffects version');
    }

    var parser = ByteParser(bytes.sublist(1));
    //var parser = ByteParser(gzip.decode(bytes.sublist(1)));

    int nbEffects = parser.extractInt8();
    for(int i=0; i < nbEffects; i+=1) {
      effects.add(CardEffect.fromBytes(parser));
    }
  }
  CardEffects.fromBytes(ByteParser parser) {
    if(parser.extractInt8() != version) {
      throw StatitikException('Bad CardEffects version');
    }
    //var parser = ByteParser(gzip.decode(bytes.sublist(1)));

    int nbEffects = parser.extractInt8();
    for(int i=0; i < nbEffects; i+=1) {
      effects.add(CardEffect.fromBytes(parser));
    }
  }

  void removeUseless() {
    effects.removeWhere((element) {
      return element.title == null && element.description == null;
    });
  }

  List<int> toBytes() {
    List<int> b = [version, effects.length];
    for (var element in effects) {
      b += element.toBytes();
    }
    return b;
  }
}
*/