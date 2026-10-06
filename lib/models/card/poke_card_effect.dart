import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/database/poke_db_description.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeEffectName extends PokeIdentifier {
  PokeEffectName.fromDB(super._id);

  PokeEffectName.fromBytes(super.reader) : super.fromBytes();

  PokeIdentifier pid() {
    return this;
  }
}

class PokeEffectDescription {
  PokeDbDescription  description;
  List<int>          parameters = []; ///< List of parameter to substitute
  List<PokeDescriptionEffect> _effects;

  PokeEffectDescription(this.description, this.parameters, this._effects);

  @Deprecated("Migration Only")
  PokeEffectDescription.fromBytesOld(this.description, this.parameters): _effects=[];

  PokeEffectDescription.fromBytes(BinaryReader reader, PokeCollection collection):
    description = collection.description(PokeIdentifier.fromBytes(reader))!,
    parameters  = reader.readSmallList((reader) => reader.readUint32() ),
    _effects    = []
  {
    _effects = collection.computeDescriptionEffects(description);
  }

  void toBytes(BinaryWriter writer) {
    description.toBytesID(writer);
    writer.writeSmallList(parameters, ((writer, item) => writer.writeUint32(item)));
  }

  String fillWithParameters(String string) {
    String result = string;
    for (int i = 1; i < parameters.length + 1; i++) {
      result = result.replaceAll('{$i}', parameters[i-1].toString());
    }
    return result;
  }
}

class PokeCardEffect {
  PokeEffectName?         title;       /// Title of capacity if exist.
  PokeEffectDescription?  description; /// Description if exists.

  int                 power  = 0;   /// Zero = no attack.
  List<PokeCardType>  attack = [];  /// Energy to attach for attack.

  PokeCardEffect( this.title, this.description, this.power, this.attack );

  PokeCardEffect.fromBytes(BinaryReader reader, PokeCollection collection):
    title       = reader.readOptional((r) => collection.effectName(PokeIdentifier.fromBytes(r))),
    description = reader.readOptional((r) => PokeEffectDescription.fromBytes(r, collection)),
    power       = reader.readUint16(),
    attack      = reader.readSmallList(((reader) => PokeCardType.values[reader.readInt8()]));

  @Deprecated("Migration Only")
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

    power = reader.tmpReadInt16BIG();

    int nbAttack = reader.readInt8();
    for(int i = 0; i < nbAttack; i +=1) {
      var t = PokeCardType.values[reader.readInt8()];
      if(t != PokeCardType.unknown) {
        attack.add(t);
      }
    }

    // Update old ID
    if( description != null ) {
      // Combine and extract info
      RegExp exp = RegExp(r"(.*?)<(.?:[{\d+}|]+)>(.*)", unicode: true);
      int count = 0;

      final l = collection.language(Language.en);
      String toAnalyze = description!.description.name(l)!;
      while (toAnalyze.isNotEmpty) {
        var match = exp.firstMatch(toAnalyze);
        if (match != null) {
          toAnalyze = "";
          var code = match.group(2)!.split(":");
          assert(code.length == 2);
          if (code[0] == "D") {
            final data = collection.description(PokeIdentifier(int.parse(code[1])))!;
            toAnalyze += data.name(l)!;
          } else {
            int paramID = 0;
            try {
              if (code[0] == "R") {
                final subCode = code[1].split("|");

                paramID = int.parse(subCode[0].substring(1, subCode[0].length-1))-1;
                description!.parameters[paramID] = collection.pokemonFromOldDB(description!.parameters[paramID]);
                paramID = int.parse(subCode[1].substring(1, subCode[1].length-1))-1;
                description!.parameters[paramID] = description!.parameters[paramID] + 910000000;
              } else {
                paramID = int.parse(code[1].substring(1, code[1].length-1))-1;
                if (code[0] == "E") {

                } else if (code[0] == "P") {
                  description!.parameters[paramID] = collection.pokemonFromOldDB(description!.parameters[paramID]);
                } else if (code[0] == "A") {
                  description!.parameters[paramID] = description!.parameters[paramID] + 800000000;
                } else if (code[0] == "R") {

                } else {
                  throw StatitikException(ErrorCode.unknown, "Error of code");
                }
              }
            } catch ( _ ) {
              printOutput("PID: ${description!.description.pid().id()} - Impossible to read parameter ${code[0]} : $paramID ");
              rethrow;
            }
          }
          toAnalyze += match.group(3)!;
        } else {
          break;
        }
        count += 1;
        if (count > 30) throw StatitikException(ErrorCode.unknown, "Loop detector");
      }
    }
  }

  void toBytes(BinaryWriter writer) {
    writer.writeOptional(title, (w) => title!.toBytesID(w));
    writer.writeOptional(description, (w) => description!.toBytes(w));
    writer.writeUint16(power);
    writer.writeSmallList(attack, (writer, element) => writer.writeInt8(element.index) );
  }
}

class PokeCardEffects {
  List<PokeCardEffect> effects = [];

  static const int version = 1;

  PokeCardEffects();

  PokeCardEffects.fromEffects(this.effects);

  @Deprecated("Migration Only")
  PokeCardEffects.fromBytesOld(BinaryReader reader, PokeCollection collection) {
    if(reader.readInt8() != version) {
      throw StatitikException(ErrorCode.unknown, 'Bad CardEffects version');
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
      throw StatitikException(ErrorCode.unknown, 'Bad CardEffects version');
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