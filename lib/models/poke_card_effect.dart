import 'package:statitikcard/models/database/poke_db_description.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeEffectName extends PokeIdentifier {
  PokeEffectName.fromDB(super._id);

  PokeEffectName.fromBytes(super.reader) : super.fromBytes();
}

class PokeEffectDescription {
  PokeDbDescription  description;
  List<int>          parameters = []; ///< List of parameter to substitute

  List<DescriptionEffect> computeDescriptionEffects(PokeCollection collection, PokeLangage l) {
    List<DescriptionEffect> effects = [];
    return effects;
  }

  PokeEffectDescription.fromBytesOld(this.description, this.parameters);

  PokeEffectDescription.fromBytes(BinaryReader reader, PokeCollection collection):
    description = collection.description(PokeIdentifier.fromBytes(reader))!,
    parameters  = reader.readSmallList((reader) => reader.readInt32() );

  void toBytes(BinaryWriter writer) {
    description.toBytesID(writer);
    writer.writeSmallList(parameters, ((writer, item) => writer.writeInt32(item)));
  }
}

class PokeCardEffect {
  PokeEffectName?         title;       /// Title of capacity if exist.
  PokeEffectDescription?  description; /// Description if exists.

  int             power  = 0;   /// Zero = no attack.
  List<TypeCard>  attack = [];  /// Energy to attach for attack.

  PokeCardEffect();

  PokeCardEffect.fromBytes(BinaryReader reader, PokeCollection collection):
    title       = reader.readOptional(() => collection.effectName(PokeIdentifier.fromBytes(reader))),
    description = reader.readOptional(() => PokeEffectDescription.fromBytes(reader, collection)),
    power       = reader.readInt16(),
    attack      = reader.readSmallList(((reader) => TypeCard.values[reader.readInt8()]));
  
  PokeCardEffect.fromBytesOld(BinaryReader reader, PokeCollection collection) {
    int idEffect = reader.tmpReadInt16BIG();
    if(idEffect != 0) {
      title = collection.effectName(PokeIdentifier(idEffect + 800000000));
    }

    int oldId = reader.tmpReadInt16BIG();
    if(oldId > 0) {
      description = PokeEffectDescription.fromBytesOld(
        collection.description(PokeIdentifier(oldId + 700000000))!,
        reader.readSmallList((reader) => reader.tmpReadInt16BIG() ));
    }

    power = reader.readInt16();

    int nbAttack = reader.readInt8();
    for(int i = 0; i < nbAttack; i +=1) {
      var t = TypeCard.values[reader.readInt8()];
      if(t != TypeCard.unknown) {
        attack.add(t);
      }
    }
  }

  void toBytes(BinaryWriter writer) {
    writer.writeOptional(title, () => title!.toBytesID(writer));
    writer.writeOptional(description, () => description!.toBytes(writer));
    writer.writeInt16(power);
    writer.writeSmallList(attack, (writer, element) => writer.writeInt8(element.index) );
  }
}

class PokeCardEffects {
  List<PokeCardEffect> effects = [];

  static const int version = 1;

  PokeCardEffects();

  PokeCardEffects.fromEffects(this.effects);

  PokeCardEffects.fromBytesOld(BinaryReader reader, PokeCollection collection) {
    if(reader.readInt8() != version) {
      throw StatitikException('Bad CardEffects version');
    }
    effects = reader.readSmallList((reader) => PokeCardEffect.fromBytesOld(reader, collection));
  }
/*
  PokeCardEffects.fromBytesArray(List<int> bytes) {
    if(bytes[0] != version) {
      throw StatitikException('Bad CardEffects version');
    }

    var parser = ByteParser(bytes.sublist(1));
    //var parser = ByteParser(gzip.decode(bytes.sublist(1)));

    int nbEffects = parser.extractInt8();
    for(int i=0; i < nbEffects; i+=1) {
      effects.add(PokeCardEffect.fromBytes(parser));
    }
  }
 */
  PokeCardEffects.fromBytes(BinaryReader reader, PokeCollection collection) {
    if(reader.readInt8() != version) {
      throw StatitikException('Bad CardEffects version');
    }
    effects = reader.readSmallList((reader) => PokeCardEffect.fromBytes(reader, collection));
  }

  void removeUseless() {
    effects.removeWhere((element) {
      return element.title == null && element.description == null;
    });
  }

  void toBytes(BinaryWriter writer) {
    writer.writeInt8(version);
    writer.writeSmallList(effects, (writer, effect) => effect.toBytes(writer) );
  }
}