import 'package:flutter/material.dart';

import 'package:statitikcard/services/cardDrawData.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';

class SessionDraw
{
  int               idAchat=-1; // To manage draw after save into database

  Language          language;
  Product           product;
  bool              productAnomaly=false;
  List<BoosterDraw> boosterDraws;
  Key               id; // Make unique file

  SessionDraw({required this.product, required this.language}):
        id = UniqueKey(),
        boosterDraws = product.buildBoosterDraw();

  SessionDraw.fromFile(this.id, ByteParser parser) :
    language = Environment.instance.collection.languages[parser.extractInt16()],
    product  = Environment.instance.collection.products[parser.extractInt16()],
    boosterDraws = []
  {
    productAnomaly = parser.extractBool();
    boosterDraws = product.buildBoosterDraw();
    boosterDraws.forEach((element) {
      int subExtensionId = parser.extractInt16();
      if(subExtensionId != 0) {
        element.subExtension = Environment.instance.collection.subExtensions[subExtensionId];
        element.abnormal = parser.extractBool();

        element.cardDrawing = ExtensionDrawCards.fromBytes(parser.extractBytesArray());

        // Energies
        element.energiesBin.clear();
        var energyCodes = parser.extractBytesArray();
        energyCodes.forEach((code) {
          element.energiesBin.add(CodeDraw.fromCode(code));
        });
      }
    });
  }

  List<int> toBytes() {
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt16(language.id);
    bytes += ByteEncoder.encodeInt16(product.idDB);
    bytes += ByteEncoder.encodeBool(productAnomaly);

    bytes += ByteEncoder.encodeInt16(boosterDraws.length);
    boosterDraws.forEach((element) {
      if(element.subExtension == null) {
        bytes += ByteEncoder.encodeInt16(element.subExtension!.id);
        // abnormal
        bytes += ByteEncoder.encodeBool(element.abnormal);
        // List code
        bytes += ByteEncoder.encodeBytesArray(element.cardDrawing!.toBytes());
        // Energies
        List<int> energyCode = [];
        for(CodeDraw c in element.energiesBin) {
          energyCode.add(c.toInt());
        }
        bytes += ByteEncoder.encodeBytesArray(energyCode);
      } else {
        bytes += ByteEncoder.encodeInt16(0);
      }
    });
    return bytes;
  }

  void closeStream() {
    boosterDraws.forEach((booster) {
      booster.closeStream();
    });
  }

  void addNewBooster() {
    BoosterDraw booster = boosterDraws.last;

    boosterDraws.add(new BoosterDraw(creation: booster.subExtension, id: booster.id+1, nbCards: booster.nbCards) );
  }

  void deleteBooster(int id) {
    if( id >= boosterDraws.length || id < 0 )
      throw StatitikException("Impossible de trouver le booster $id");
    // Delete
    boosterDraws.removeAt(id);
    // Change Label ID
    id = 1;
    boosterDraws.forEach((BoosterDraw element) {element.id = id; id += 1; });
  }

  bool canDelete() {
    return boosterDraws.length > 1;
  }

  void revertAnomaly()
  {
    //Brutal reset
    boosterDraws = product.buildBoosterDraw();
    productAnomaly = false;
  }

  bool needReset() {
    bool editedBooster = false;
    for(BoosterDraw b in boosterDraws){
      if(b.creation != null && b.creation != b.subExtension)
        editedBooster |= true;
    }

    return editedBooster || boosterDraws.length != product.countBoosters();
  }
}