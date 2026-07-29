import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_card.dart';
import 'package:statitikcard/models/poke_card_design.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_set.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeCardInExpansion {
  PokeCard         card;
  PokeRarity       rarity;
  String           specialID = ""; /// For card without number or special (like energy, celebration card, ...)
  bool             isSecret = false;
  Map<PokeSet, List<PokeCardDesign>> setInfo;

  String numberOfCard(int id) {
    return specialID.isNotEmpty ? specialID : (id + 1).toString();
  }

  bool hasMultiSet() {
    return setInfo.length > 1;
  }

  PokeCardInExpansion(this.card, this.rarity, this.specialID, this.isSecret, this.setInfo);

  PokeCardInExpansion.fromBytes(BinaryReader reader, PokeCollection collection):
    card      = collection.card( PokeIdentifier.fromBytes(reader) )!,
    rarity    = collection.rarity(reader.readUint8())!,
    specialID = reader.readSmallString(),
    isSecret  = reader.readBool(),
    setInfo   = reader.readSmallMap(
      (reader) => collection.sets(PokeIdentifier.fromBytes(reader))!,
      (reader) => reader.readSmallList(
          (reader) => PokeCardDesign.fromBytes(reader, collection) ));

  void toBytes(BinaryWriter writer) {
    card.toBytesID(writer);
    writer.writeUint8(rarity.id());
    writer.writeSmallString( specialID );
    writer.writeBool(isSecret);
    writer.writeSmallMap(setInfo,
      (writer, set)  => set.toBytesID(writer),
      (writer, item) => writer.writeSmallList(
        item,
        (writer, design) => design.toBytes(writer)));
  }

  PokeCardInExpansion.empty(this.card, this.rarity, {this.specialID="", this.isSecret=false}) :
    setInfo = {};

  /*
  PokeCardInExpansion.creation(this.data, this.rarity, Map allSets, {jpDBId=0, this.specialID="", this.isSecret=false, bool isJapanese=false}) {
    var image = ImageDesign();
    if(jpDBId != 0) {
      image.jpDBId = jpDBId;
    }
    // Automatic fill base on current database ID
    if(isJapanese) {
      // Auto art
      image.cardDesign.art = rarity == Environment.instance.collection.rarities[16] ? ArtFormat.fullArt
          : rarity == Environment.instance.collection.rarities[14] ? ArtFormat.halfArt :  ArtFormat.normal;
      image.cardDesign.design = rarity == Environment.instance.collection.rarities[16] ? Design.full.index
          : rarity == Environment.instance.collection.rarities[14] ? Design.full.index :  0;
    }

    images.add([image]);
    computeDefaultSet(allSets);
    // Set default level
    if(!isPokemonCard(data.type)) {
      data.level = Level.withoutLevel;
    }
  }
  void computeDefaultSet(Map allSets) {
    if(Environment.instance.collection.japanRarity.contains(rarity)) {
      sets.add(allSets[0]);
    } else {
      if( rarity.id < 6 ) {
        sets.add(allSets[0]);
      } else {
        sets.add(allSets[1]);
      }

      if( rarity.id <= 6 ) {
        sets.add(allSets[2]);
      }
    }

    // Fill image list
    while(images.length < sets.length) {
      images.add([]);
    }
    assert(images.length == sets.length);
    assert(images.isNotEmpty,    "Card issue: ${data.toString()}");
    assert(images[0].isNotEmpty, "Card issue: ${data.toString()}");
  }

  PokemonCardExtension.fromBytesV3(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(_) {}
    images.add([ImageDesign()]);

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV4(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(_) {}

    var image = ImageDesign();
    image.image = parser.extractString16();
    images.add([image]);

    int otherData = parser.extractInt8();
    assert(otherData == 0); //Not used

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV5(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(_) {}

    var image = ImageDesign();
    image.image  = parser.extractString16();
    image.jpDBId = parser.extractInt32();
    images.add([image]);

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV6(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(_) {}

    var image = ImageDesign();
    image.image  = parser.extractString16();
    image.jpDBId = parser.extractInt32();
    images.add([image]);

    specialID = parser.extractString16();

    computeDefaultSet(allSets);
  }

  PokemonCardExtension.fromBytesV7(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e, callStack){
      printOutput("Card info unknown: $e\n$callStack");
    }

    var image = ImageDesign();
    image.image  = parser.extractSmallString16();
    image.jpDBId = parser.extractInt32();
    images.add([image]);

    specialID = parser.extractSmallString16();

    var nbSets = parser.extractInt8();
    for(int i = 0; i < nbSets; i +=1){
      sets.add(allSets[parser.extractInt8()]);
    }
    // Fill image list
    while(images.length < sets.length) {
      images.add([]);
    }
    isSecret = parser.extractInt8() == 1;

    assert(images.length == sets.length);
    assert(images.isNotEmpty && images[0].isNotEmpty);
  }

  PokemonCardExtension.fromBytesV8(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e, callStack){
      printOutput("Card info unknown: $e\n$callStack");
    }

    var nbImagesSet = parser.extractInt8();
    for(int id=0; id < nbImagesSet; id +=1) {
      List<ImageDesign> imageSets = [];
      var nbImagesDesign = parser.extractInt8();
      for(int id=0; id < nbImagesDesign; id +=1) {
        var image = ImageDesign();
        image.image  = parser.extractSmallString16();
        image.jpDBId = parser.extractInt32();
        image.cardDesign = CardDesign.fromBytesV1(parser);
        imageSets.add(image);
      }
      images.add(imageSets);
    }

    specialID = parser.extractSmallString16();

    var nbSets = parser.extractInt8();
    for(int i = 0; i < nbSets; i +=1){
      sets.add(allSets[parser.extractInt8()]);
    }
    isSecret = parser.extractInt8() == 1;

    assert(images.length == sets.length);
    assert(images.isNotEmpty && images[0].isNotEmpty);
  }

  PokemonCardExtension.fromBytesDB(ByteParser parser, Map collection, Map allSets, Map allRarities) :
        data   = collection[parser.extractInt16()],
        rarity = Environment.instance.collection.unknownRarity!
  {
    try {
      rarity = allRarities[parser.extractInt8()];
    }
    catch(e, callStack){
      printOutput("Card info unknown: $e\n$callStack");
    }

    var nbImagesSet = parser.extractInt8();
    for(int id=0; id < nbImagesSet; id +=1) {
      List<ImageDesign> imageSets = [];
      var nbImagesDesign = parser.extractInt8();
      for(int id=0; id < nbImagesDesign; id +=1) {
        var image = ImageDesign();
        image.image  = parser.extractSmallString16();
        image.jpDBId = parser.extractInt32();
        image.cardDesign = CardDesign.fromBytes(parser);
        imageSets.add(image);
      }
      images.add(imageSets);
    }

    specialID = parser.extractSmallString16();

    var nbSets = parser.extractInt8();
    for(int i = 0; i < nbSets; i +=1){
      sets.add(allSets[parser.extractInt8()]);
    }
    isSecret = parser.extractInt8() == 1;

    assert(images.length >= sets.length);
    assert(images.isNotEmpty && images[0].isNotEmpty);
  }

  List<int> toBytesDB(Map rCollection, Map rSet, Map rRarity) {
    assert(rCollection.isNotEmpty); // admin condition

    int idCard = rCollection[data];
    assert(idCard != 0);

    var specialImage = ByteEncoder.encodeString16(specialID.codeUnits);
    var setsInfo     = [sets.length];
    for(var s in sets) {
      setsInfo.add(rSet[s]);
    }

    List<int> imagesBytes = ByteEncoder.encodeInt8(images.length);
    for(var imageBySets in images) {
      imagesBytes += ByteEncoder.encodeInt8(imageBySets.length);
      for(var image in imageBySets) {
        imagesBytes += ByteEncoder.encodeSmallString16(image.image.codeUnits);
        imagesBytes += ByteEncoder.encodeInt32(image.jpDBId);
        imagesBytes += image.cardDesign.toBytes();
      }
    }

    return ByteEncoder.encodeInt16(idCard) +
        <int>[rRarity[rarity]] +
        imagesBytes +
        specialImage +
        setsInfo + <int>[isSecret ? 1 : 0];
  }


  List<Widget> imageRarity(PokeLangage l) {
    return getImageRarity(rarity, l, iconSize: 18.0);
  }
  */

  Widget imageType({bool generate=false, double? sizeIcon}) {
    return getImageType(card.type, generate: generate, sizeIcon: sizeIcon);
  }
  Widget? imageTypeExtended({bool generate=false, double? sizeIcon}) {
    return card.typeExtended != null ? getImageType(card.typeExtended!, generate: generate, sizeIcon: sizeIcon) : null;
  }
/*
  bool hasAnotherRendering() {
    return !isValid() || hasMultiSet();
  }

  bool isForReport() {
    return Environment.instance.collection.goodCard.contains(rarity);
  }

  Widget? showImportantMarker(PokeLangage l, {double? height}) {
    for(final m in card.markers.markers()) {
      final widget = m.pokeMarker(l, m, height: height);
      if(widget != null) {
        return widget;
      }
    }
    return null;
  }

  bool isGoodCard() {
    return isValid() && Environment.instance.collection.goodCard.contains(rarity);
  }

  ImageDesign tryGetImage(CardImageIdentifier idImage) {
    assert(images.isNotEmpty);
    int finalIdSet   = idImage.idSet   < images.length             ? idImage.idSet   : 0;
    int finalIdImage = idImage.idImage < images[finalIdSet].length ? idImage.idImage : 0;

    assert(images[finalIdSet].isNotEmpty);
    return images[finalIdSet][finalIdImage];
  }

  ImageDesign? image(CardImageIdentifier idImage) {
    assert(images.isNotEmpty);
    if(idImage.idSet < images.length) {
      var v = images[idImage.idSet];
      if(idImage.idImage < v.length) {
        return v[idImage.idImage];
      }
    }
    return null;
  }

  void removeImage(CardImageIdentifier idImage) {
    if(idImage.idSet < images.length) {
      if( idImage.idImage < images[idImage.idSet].length ) {
        images[idImage.idSet].removeAt(idImage.idImage);
      }
    }
  }
 */
}