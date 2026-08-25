
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/models/poke_card_design.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeDbCardsBlob {
  static int version = 10;

  static List<CodeNaming> convertNaming(String? naming) {
    List<CodeNaming> codes = [];
    // Extract code naming
    if(naming != null) {
      naming.split("|").forEach((element) {
        if(element.isNotEmpty) {
          var item = element.split(":");
          assert(item.length == 2);
          codes.add(CodeNaming(int.parse(item[0]), item[1]));
        }
      });
    }
    return codes;
  }
  static String? convertCode(List<CodeNaming> codes) {
    // Extract code naming
    if(codes.isNotEmpty) {
      List<String> nCodes = [];
      for(final c in codes) {
        nCodes.add("${c.idStart}:${c.naming}");
      }
      return nCodes.join("|");
    }
    return null;
  }

  static List<List<PokeCardInExpansion>> convertCard(Blob? data, PokeCollection collection) {
    List<List<PokeCardInExpansion>> cards = [];
    if(data != null) {
      final r = BinaryReader(Uint8List.fromList(data.toBytes()));
      final currentVersion = r.readInt8();
      if(currentVersion == version){
        var reader = BinaryReader(Uint8List.fromList(
            gzip.decode(r.readBuffer().toList(growable: false))));
        return readCards(currentVersion, reader, collection);
      }
      else if (8 <= currentVersion && currentVersion < version) {
        var reader = BinaryReader(Uint8List.fromList(
            gzip.decode(r.readBuffer().toList(growable: false))));
        // Extract card
        while (reader.canParse()) {
          List<PokeCardInExpansion> numberedCard = [];
          int nbTitle = reader.readInt8();
          assert(nbTitle > 0); // Strange ?
          for (int cardId = 0; cardId < nbTitle; cardId += 1) {
            numberedCard.add(read(currentVersion, reader, collection));
          }
          cards.add(numberedCard);
        }
      } else {
        throw StatitikException(ErrorCode.unknown,
            "SubExtensionCards: need migration ($currentVersion < $version)");
      }
    }
    return cards;
  }

  static List<List<PokeCardInExpansion>> readCards(int currentVersion, BinaryReader r, PokeCollection collection) {
    return r.readList((reader) => reader.readSmallList((reader) => read(currentVersion, reader, collection)));
  }

  static List<PokeCardInExpansion> convertOther(Blob? data, PokeCollection collection)
  {
    List<PokeCardInExpansion> cards = [];
    if(data != null) {
      final r = BinaryReader(Uint8List.fromList(data.toBytes()));
      final currentVersion = r.readInt8();
      if ( currentVersion == version ) {
        var reader = BinaryReader(Uint8List.fromList(
            gzip.decode(r.readBuffer().toList(growable: false))));
        return readOther(currentVersion, reader, collection);
      } else if ( 8 <= currentVersion && currentVersion < version ) {
        var reader = BinaryReader(Uint8List.fromList(
            gzip.decode(r.readBuffer().toList(growable: false))));
        while (reader.canParse()) {
          cards.add(read(currentVersion, reader, collection));
        }
      } else {
        throw StatitikException(ErrorCode.unknown, "Other: need migration ($currentVersion < $version");
      }
    }
    return cards;
  }

  static List<PokeCardInExpansion> readOther(int currentVersion,BinaryReader r, PokeCollection collection)
  {
    return r.readList((reader) => read(currentVersion, reader, collection));
  }

  static PokeCardInExpansion read(int version, BinaryReader r, PokeCollection collection)
  {
    switch(version) {
      case 8:  return readV8(r, collection);
      case 9:  return readV9(r, collection);
      case 10: return readV10(r, collection);
    }
    throw Exception("Bad card");
  }

  static PokeCardInExpansion readV8(BinaryReader r, PokeCollection collection)
  {
    final card   = collection.card( PokeIdentifier(r.tmpReadInt16BIG()) );
    final rarity = collection.rarity(r.readInt8())!;

    List<List<PokeCardDesign>> images = [];

    var nbImagesSet = r.readInt8();
    for(int id=0; id < nbImagesSet; id += 1)
    {
      List<PokeCardDesign> imageSets = [];
      var nbImagesDesign = r.readInt8();
      for(int id=0; id < nbImagesDesign; id += 1)
      {
        final image  = r.tmpReadOldString16();
        final jpDBId = r.tmp_readInt32BIG();

        final designCode  = r.readInt8();
        final patternCode = r.readInt8();

        final cardDesign = collection.designOld(designCode,patternCode)!;
        final art        = ArtFormat.normal;

        imageSets.add(PokeCardDesign.fromDB(cardDesign, art, image, jpDBId));
      }
      images.add(imageSets);
    }

    final specialID = r.tmpReadOldString16();
    List<PokeSet> sets = [];
    var nbSets = r.readInt8();
    for(int i = 0; i < nbSets; i += 1){
      sets.add(collection.setsOld(r.readInt8())!);
    }

    assert(images.length >= sets.length);
    assert(images.isNotEmpty && images[0].isNotEmpty);

    Map<PokeSet, List<PokeCardDesign>> imageSets = {};
    final itImage = images.iterator;
    for(final set in sets) {
      itImage.moveNext();
      imageSets[set] = itImage.current;
    }
    final isSecret = r.readBool();

    return PokeCardInExpansion(card!, rarity, specialID, isSecret, imageSets );
  }

  static PokeCardInExpansion readV9(BinaryReader r, PokeCollection collection)
  {
    final card   = collection.card( PokeIdentifier(r.tmpReadInt16BIG()) );
    final rarity = collection.rarity(r.readInt8())!;

    List<List<PokeCardDesign>> images = [];

    var nbImagesSet = r.readInt8();
    for(int id=0; id < nbImagesSet; id += 1)
    {
      List<PokeCardDesign> imageSets = [];
      var nbImagesDesign = r.readInt8();
      for(int id=0; id < nbImagesDesign; id += 1)
      {
        final image  = r.tmpReadOldString16();
        final jpDBId = r.tmp_readInt32BIG();

        final designCode  = r.readInt8();
        final patternCode = r.readInt8();
        final artCode     = r.readInt8();

        final cardDesign = collection.designOld(designCode,patternCode)!;//Design.fromBytes(r);
        final art = ArtFormat.values[artCode];

        imageSets.add(PokeCardDesign.fromDB(cardDesign, art, image, jpDBId));
      }
      images.add(imageSets);
    }

    final specialID = r.tmpReadOldString16();
    List<PokeSet> sets = [];
    var nbSets = r.readInt8();
    for(int i = 0; i < nbSets; i += 1){
      sets.add(collection.setsOld(r.readInt8())!);
    }

    assert(images.length >= sets.length);
    assert(images.isNotEmpty && images[0].isNotEmpty);

    Map<PokeSet, List<PokeCardDesign>> imageSets = {};
    final itImage = images.iterator;
    for(final set in sets) {
      itImage.moveNext();
      imageSets[set] = itImage.current;
    }
    final isSecret = r.readBool();

    return PokeCardInExpansion(card!, rarity, specialID, isSecret, imageSets );
  }

  static PokeCardInExpansion readV10(BinaryReader r, PokeCollection collection)
  {
    return PokeCardInExpansion.fromBytes(r, collection);
  }

  static void writeCard(BinaryWriter w, List<List<PokeCardInExpansion>> cards) {
    final localWrite = BinaryWriter();
    localWrite.writeList(cards, (writer, item) => writer.writeSmallList(item, (writer, card) => card.toBytes(writer)));

    w.writeInt8(version);
    w.writeGZip(localWrite);
  }

  static void writeOther(BinaryWriter w, List<PokeCardInExpansion> other) {
    final localWrite = BinaryWriter();
    localWrite.writeList(other, (writer, card) => card.toBytes(writer));

    w.writeInt8(version);
    w.writeGZip(localWrite);
  }
}