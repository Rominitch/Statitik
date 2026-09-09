import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/tools/binary_manager.dart';
import 'package:statitikcard/widgets/image/image_with_cache.dart';

class PokeProductBooster
{
  final PokeIdentifier _pid;
  final int _nbCards;
  final int _nbEnergies;
  final int _nbDesigns;   // Nb of design = 4

  // Computed
  final PokeExpansion _expansion;

  static const int version = 1;

  const PokeProductBooster( this._pid, this._nbCards, this._nbEnergies, this._nbDesigns, this._expansion );

  PokeIdentifier pid()       { return _pid; }
  PokeExpansion expansion()  { return _expansion; }
  int           nbEnergies() { return _nbEnergies; }
  int           nbCards()    { return _nbCards; }
  int           nbDesigns()  { return _nbDesigns; }

  static PokeProductBooster read(PokeCollection collection, PokeIdentifier pid, BinaryReader reader) {
    final int currentVersion = reader.readUint8();
    if(version != currentVersion) {
      throw "Incompatible data";
    }
    final dataReader = reader.readCompressBuffer();

    final nbCards    = dataReader.readUint8();
    final nbEnergies = dataReader.readUint8();
    final nbDesigns  = dataReader.readUint8();
    final expansion  = collection.expansion(PokeIdentifier.expensionFrom(pid))!;

    return PokeProductBooster(pid, nbCards, nbEnergies, nbDesigns, expansion);
  }

  void toBytes(BinaryWriter writer) {
    final dataWriter = BinaryWriter();
    dataWriter.writeUint8(_nbCards);
    dataWriter.writeUint8(_nbEnergies);
    dataWriter.writeUint8(_nbDesigns);

    writer.writeUint8(version);
    writer.writeCompressBuffer(dataWriter);
  }

  void toBytesID(BinaryWriter writer) {
    _pid.toBytesID(writer);
  }

  bool isEqual(PokeIdentifier pid) {
    return _pid.isEqual(pid);
  }

  String boosterDesignImage(int design) {
    return "${_pid.id()}_$design";
  }

  ImageWithCache widget(BuildContext context, int idDesign, PokeLanguage l) {
    final image = boosterDesignImage(idDesign);
    return ImageWithCache.generator('PKBoosters/${l.code()}', [image],
      alternativeRendering: Column(children: [
        Text(AppLocalizations.of(context)!.s_b4, style: Theme.of(context).textTheme.headlineMedium),
        _expansion.image(l)
      ]));
  }
}