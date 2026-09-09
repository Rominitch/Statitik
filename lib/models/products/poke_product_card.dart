import 'package:statitikcard/models/draw/poke_card_draw.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeProductCard {
  late final PokeExpansion         expansion;
  late PokeCardIdentifier    idCard;
  late final AlternativeDesign     design;       /// Think more about it but keep space !
  late bool                  jumbo;
  late bool                  isRandom;
  late PokeCardDraw          counter;   /// Counter inside BY PRODUCT ONLY: Not limited to 7 !!

  static const int _jumboMask  = 1;
  static const int _randomMask = 2;

  PokeProductCard(this.expansion, this.idCard, this.design, this.jumbo, this.isRandom, this.counter);

  PokeCardInExpansion card() {
    return expansion.cards.cardFromId(idCard);
  }

  PokeProductCard.fromBytes(BinaryReader reader, PokeCollection collection):
    expansion = collection.expansion(PokeIdentifier.fromBytes(reader))!,
    idCard    = PokeCardIdentifier.fromBytes(reader),
    design    = AlternativeDesign.values[reader.readUint8()],
    jumbo     = reader.readBool(),
    isRandom  = reader.readBool(),
    counter   = PokeCardDraw.fromBytes(reader, collection);

  void toBytes(BinaryWriter writer) {
    expansion.toBytesID(writer);
    idCard.toBytes(writer);
    writer.writeUint8(design.index);
    writer.writeBool(jumbo);
    writer.writeBool(isRandom);
    counter.toBytes(writer);
  }

  PokeProductCard.fromV2Bytes(BinaryReader reader, PokeCollection collection)
  {
    final (l, e) = collection.expansionFromOldDB(reader.tmpReadInt16BIG());
    expansion = e!;
    design    = AlternativeDesign.values[reader.readUint8()];

    var code = reader.readUint8();
    jumbo     = mask(code, _jumboMask);
    isRandom  = mask(code, _randomMask);

    // Retrieve card
    idCard = PokeCardIdentifier.fromOldBytes(reader);

    // Restore counter
    counter = PokeCardDraw.fromPokeCardExtension(card());
    var count = reader.readUint8();
    final sets = card().orderedSets();

    for(int id=0; id < count; id +=1){
      if( id < sets.length) {
        counter.setCount(reader.readUint8(), sets[id]);
      }
    }
  }

  PokeProductCard.fromV3Bytes(BinaryReader reader, PokeCollection collection)
  {
    final (l, e) = collection.expansionFromOldDB(reader.tmpReadInt16BIG());
    expansion = e!;
    design    = AlternativeDesign.values[reader.readUint8()];

    var code = reader.readUint8();
    jumbo     = mask(code, _jumboMask);
    isRandom  = mask(code, _randomMask);
    //jumbo     = reader.readBool();
    //isRandom  = reader.readBool();
    idCard    = PokeCardIdentifier.fromOldBytes(reader);

    // Restore counter
    counter = PokeCardDraw.fromPokeCardExtension(card());
    var count = reader.readUint8();
    final sets = card().orderedSets();

    for(int id=0; id < count; id +=1){
      if( id < sets.length) {
        var nbImages = reader.readUint8();
        for(int idImage=0; idImage < nbImages; idImage+=1) {
          counter.setCount(reader.readUint8(), sets[id], idImage);
        }
      }
    }
    //counter = PokeCardDraw.fromOldDBBytes(reader, expansion.cards.cardFromId(idCard));
  }

/*
  PokeProductCard.fromBytesV1(ByteParser parser, Map mapSubExtensions):
        expansion = mapSubExtensions[parser.extractInt16()],
        design    = AlternativeDesign.values[parser.extractInt8()],
        jumbo     = false,
        isRandom  = false,
        counter   = CodeDraw.fromSet(1)
  {
    var code = parser.extractInt8();
    jumbo     = mask(code, _jumboMask);
    isRandom  = mask(code, _randomMask);

    // Retrieve card
    idCard = CardIdentifier.fromBytes(parser);
    card = expansion.cardFromId(idCard);

    // Restore counter
    counter = CodeDraw.fromPokeCardExtension(card);
    var count = parser.extractInt8();
    for(int id=0; id < count; id +=1){
      if( id < card.sets.length) {
        counter.setCount(parser.extractInt8(), id);
      }
    }
  }

  PokeProductCard.fromBytes(ByteParser parser, Collection collection):
        expansion = collection.subExtensions[parser.extractInt32()]!,
        idCard    = CardIdentifier.fromBytes(parser),
        design    = AlternativeDesign.values[parser.extractInt8()],
        jumbo     = parser.extractBool(),
        isRandom  = parser.extractBool(),
        counter   = CodeDraw.fromBytes(parser)
  {
    card = expansion.cardFromId(idCard);
  }

  List<int> toBytes() {
    assert(counter.nbSetsRegistred() > 0);
    return ByteEncoder.encodeInt16(expansion.id)
        + idCard.toBytes()
        + ByteEncoder.encodeInt8(design.index)
        + ByteEncoder.encodeBool(jumbo)
        + ByteEncoder.encodeBool(isRandom)
        + counter.toBytes();
  }

  PokeProductCard.fromBytesDB(ByteParser parser, Map mapSubExtensions):
        expansion = mapSubExtensions[parser.extractInt16()],
        design    = AlternativeDesign.values[parser.extractInt8()],
        jumbo     = false,
        isRandom  = false,
        counter   = CodeDraw.fromSet(1)
  {
    var code = parser.extractInt8();
    jumbo     = mask(code, _jumboMask);
    isRandom  = mask(code, _randomMask);

    // Retrieve card
    idCard = CardIdentifier.fromBytes(parser);
    card = expansion.cardFromId(idCard);

    // Restore counter
    counter = CodeDraw.fromBytes(parser);
  }

  List<int> toBytesDB() {
    assert(counter.nbSetsRegistred() > 0);
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt16(expansion.id);
    bytes += ByteEncoder.encodeInt8(design.index);
    int code = (jumbo ? _jumboMask : 0) | (isRandom ? _randomMask : 0);
    bytes += ByteEncoder.encodeInt8(code);

    // Encode card full Id
    var id = expansion.seCards.computeIdCard(card)!;
    bytes += id.toBytes();

    // Encode counter
    bytes += counter.toBytes();
    return bytes;
  }
*/
}