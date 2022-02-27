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

  SessionDraw(this.product, this.language, Map allSubExtensions):
    id = UniqueKey(),
    boosterDraws = product.buildBoosterDraw(allSubExtensions);

  SessionDraw.fromFile(this.id, ByteParser parser, mapLanguages, mapProducts, mapSubExtensions) :
    language = mapLanguages[parser.extractInt16()],
    product  = mapProducts[parser.extractInt16()],
    boosterDraws = []
    // Warning: idAchat is still undefined !
  {
    productAnomaly = parser.extractBool();

    // Add additional booster
    int countBooster = parser.extractInt16();

    // Fill booster draw
    for(int idBooster=1; idBooster <= countBooster; idBooster +=1) {

      int subExtCreationId = parser.extractInt16();
      var subExt = subExtCreationId == 0 ? null : mapSubExtensions[subExtCreationId];
      int nbCards = parser.extractInt8(); // Can change from db if not good !
      // Create booster from scratch
      var booster = new BoosterDraw(creation: subExt, id: idBooster, nbCards: nbCards);

      int subExtensionId = parser.extractInt16();
      if(subExtensionId != 0) {
        var se = mapSubExtensions[subExtensionId];
        var abnormal = parser.extractBool();
        var edc      = ExtensionDrawCards.fromBytes(se, parser.extractBytesArray());
        booster.fill(se, abnormal, edc);
      }
      boosterDraws.add(booster);
    }
  }

  List<int> toBytes() {
    List<int> bytes = [];
    bytes += ByteEncoder.encodeInt16(language.id);
    bytes += ByteEncoder.encodeInt16(product.idDB);
    bytes += ByteEncoder.encodeBool(productAnomaly);

    bytes += ByteEncoder.encodeInt16(boosterDraws.length);
    boosterDraws.forEach((element) {
      bytes += ByteEncoder.encodeInt16(element.creation != null ? element.creation!.id : 0);
      bytes += ByteEncoder.encodeInt8(element.nbCards);
      bytes += ByteEncoder.encodeInt16(element.subExtension == null ? 0 : element.subExtension!.id);

      if(element.subExtension != null) {
        // abnormal
        bytes += ByteEncoder.encodeBool(element.abnormal);
        // List code
        bytes += ByteEncoder.encodeBytesArray(element.cardDrawing!.toBytes());
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

  void revertAnomaly(Map allSubExtensions)
  {
    //Brutal reset
    boosterDraws = product.buildBoosterDraw(allSubExtensions);
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