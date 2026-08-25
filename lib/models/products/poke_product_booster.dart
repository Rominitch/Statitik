import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeProductBooster
{
  PokeExpansion? expansion;
  int           nbBoosters;
  int           nbCardsPerBooster;

  PokeProductBooster(this.expansion, this.nbBoosters, this.nbCardsPerBooster);

  PokeProductBooster.fromBytes(BinaryReader reader, PokeCollection collection):
    expansion = reader.readOptional( () => collection.expansion(PokeIdentifier.fromBytes(reader))),
    nbBoosters = reader.readUint8(),
    nbCardsPerBooster = reader.readUint8();

  void toBytes(BinaryWriter writer) {
    writer.writeOptional(expansion, () => expansion!.toBytesID(writer));
    writer.writeUint8(nbBoosters);
    writer.writeUint8(nbCardsPerBooster);
  }

/*
  PokeProductBooster.fromBytes(ByteParser parser, Collection collection):
        subExtension = parser.extractOptional( (parser) => collection.subExtensions[parser.extractInt32()]!),
        nbBoosters = parser.extractInt8(),
        nbCardsPerBooster = parser.extractInt8();

  List<int> toBytes() {
    return ByteEncoder.encodeOptional(subExtension, () => ByteEncoder.encodeInt32(subExtension!.id))
        + ByteEncoder.encodeInt8(nbBoosters)
        + ByteEncoder.encodeInt8(nbCardsPerBooster);
  }
*/
}
