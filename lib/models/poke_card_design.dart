import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeCardDesign {
  final PokeDesign    design;
  final ArtFormat     art;

  final String cardImage;
  final int    jpDBId;

  // Computed
  final String     finalImage ; /// Cached to retrieve final image when found

  const PokeCardDesign.empty(this.design):
    art = ArtFormat.normal,
    jpDBId = 0,
    cardImage = "",
    finalImage = "";


  PokeCardDesign.fromBytes(BinaryReader reader, PokeCollection collection) :
    design    = collection.design(PokeIdentifier.fromBytes(reader))!,
    art       = ArtFormat.values[reader.readUint8()],
    cardImage = reader.readSmallString(),
    jpDBId    = reader.readUint32(),
    finalImage = "";

  void toBytes(BinaryWriter writer) {
    design.toBytesID(writer);
    writer.writeUint8(art.index);
    writer.writeSmallString(cardImage);
    writer.writeUint32(jpDBId);
  }

  const PokeCardDesign.fromDB(this.design, this.art, this.cardImage, this.jpDBId) : finalImage = "";
}