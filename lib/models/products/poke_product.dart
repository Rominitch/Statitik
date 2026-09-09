import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_card_subject.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product_booster.dart';
import 'package:statitikcard/models/products/poke_product_booster_count.dart';
import 'package:statitikcard/models/products/poke_product_card.dart';
import 'package:statitikcard/models/products/poke_product_category.dart';
import 'package:statitikcard/models/products/poke_product_generic.dart';
import 'package:statitikcard/models/products/poke_product_side.dart';
import 'package:statitikcard/services/tools.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeProduct extends PokeProductGeneric
{

  @Deprecated("too remove")
  String                  _name;

  // New
  Map<PokeProductBooster?, int> _boosters = {};
  Map<PokeProductSide, int>     sideProducts = {};
  List<PokeProductCard>         otherCards   = [];
  int                           nbRandomPerProduct = 0;
  CardLocation                  _location;
  List<PokeLanguage>            _excludeLanguage = [];

  List<PokeFullCardPokemon>     _honoredPokemon = [];
  List<PokeIdentifier>          _honoredOther   = []; // For trainer / stadium or what ever

  static const int version = 4;

  //PokeProduct.empty():
  //      boosters = [],
  //      super(-1, null, "", "", DateTime.now());
  PokeProduct.fromDB(super._pid, super.category, super.outDate, this._name):
    _location = CardLocation.Monde;

  PokeProduct(super._pid, super.category, super.outDate, this._name, this._boosters, this.sideProducts, this.otherCards, this.nbRandomPerProduct,
      this._location, this._excludeLanguage,
      this._honoredPokemon, this._honoredOther);

  Map<PokeProductBooster?, int> boosters()          { return _boosters; }
  List<PokeFullCardPokemon>     honoredPokemon()    { return _honoredPokemon; }
  List<PokeIdentifier>          honoredOther()      { return _honoredOther; }
  CardLocation                  location()          { return _location; }
  List<PokeLanguage>            excludeLanguage()   { return _excludeLanguage; }

  @Deprecated("too remove")
  String oldName() {return _name;}

  String name(PokeLanguage l) {
    List<String> name = [category.name(l)];
    for(final poke in _honoredPokemon) {
      name.add(poke.titleOfCard(l));
    }
    for(final other in _honoredOther) {
      name.add(l.label(other)!);
    }
    return name.join(" ");
  }

  static PokeProduct readData(PokeCollection collection,
              PokeIdentifier pid, PokeProductCategory category, DateTime out, String name,
              BinaryReader reader )
  {
    // Read header
    final currentVersion = reader.readUint8();
    if( currentVersion != version) {
      throw StatitikException(ErrorCode.unknown, "Unknown Product version: $currentVersion");
    }

    final internData = reader.readCompressBuffer();

    Map<PokeProductBooster?, int> boosters = internData.readSmallMap(
      (BinaryReader r) => r.readOptional( (BinaryReader r) => collection.booster(PokeIdentifier.fromBytes(r))! ),
      (BinaryReader r) => r.readUint8()
    );
    Map<PokeProductSide, int> sideProducts = internData.readSmallMap(
      (BinaryReader r) => collection.productSide(PokeIdentifier.fromBytes(r))!,
      (BinaryReader r) => r.readUint8()
    );

    List<PokeProductCard> otherCards = internData.readSmallList(
      (BinaryReader r) => PokeProductCard.fromBytes(r, collection)
    );
    int nbRandomPerProduct = internData.readUint8();

    final location = CardLocation.values[internData.readUint8()];
    final excludeLanguage = internData.readSmallList(
      (BinaryReader r) => collection.language(Language.values[r.readUint8()])
    );

    final honoredPokemon = internData.readSmallList(
      (BinaryReader r) => PokeFullCardPokemon.fromBytes(r,collection)
    );
    final honoredOther = internData.readSmallList(
      (BinaryReader r) => PokeIdentifier.fromBytes(r)
    );
    return PokeProduct(pid, category, out, name, boosters, sideProducts, otherCards, nbRandomPerProduct,
      location, excludeLanguage, honoredPokemon, honoredOther);
  }

  @Deprecated("To remove")
  void readOldData(BinaryReader reader, PokeCollection collection) {
    final currentVersion = reader.readInt8();
    if(currentVersion >= version) {
      throw StatitikException(ErrorCode.unknown, "Unknown Product version: $currentVersion");
    }

    // Is Zip ?
    try {
      final isZipped = reader.readInt8() == 1;
      BinaryReader dataReader;
      if(isZipped ) {
        final buffer = reader.readBuffer().toList(growable: false);
        dataReader = BinaryReader(Uint8List.fromList(gzip.decode(buffer)));
      } else {
        dataReader = reader;
      }

      // Ready to read data
      // Read boosters
      List<PokeProductBoosterCount>     boosters = [];
      var nbBoosters = dataReader.readUint8();
      for(int id=0; id < nbBoosters; id +=1){
        final idSe = dataReader.tmpReadInt16BIG();
        final (l, e) = collection.expansionFromOldDB(idSe);

        _location = l != null ? l.location() : CardLocation.Monde;
        final pb = PokeProductBoosterCount(idSe == 0 ? null : e!, dataReader.readUint8(), dataReader.readUint8());
        //printOutput("$name: ${pb.subExtension != null ? pb.subExtension!.name : "No se"}");
        boosters.add(pb);
      }

      for(final booster in boosters) {
        _boosters[collection.tmpBoosterFromExp(booster.expansion)] = booster.nbBoosters;
      }

      // Read other products
      var nbSideProducts = dataReader.readUint8();
      for(int id=0; id < nbSideProducts; id +=1){
        final pid = PokeIdentifier( 630000000 + dataReader.tmp_readInt32BIG());
        //final pid = PokeIdentifier( 630000000 + dataReader.tmpReadInt16BIG());
        var sideProduct = collection.productSide(pid)!;
        sideProducts[sideProduct] = dataReader.readUint8();
      }

      // Read other cards
      var nbOtherCards = dataReader.readUint8();
      for(int id=0; id < nbOtherCards; id +=1) {
        if( currentVersion<=2) {
          otherCards.add(PokeProductCard.fromV2Bytes(dataReader, collection));
        } else {
          otherCards.add(PokeProductCard.fromV3Bytes(dataReader, collection));
        }
      }

      if( currentVersion >= 2 ) {
        nbRandomPerProduct= dataReader.readUint8();
      }
      assert(dataReader.isFullyRead());
    }
    catch (_, e) {
      printOutput("Error with product: ${super.pid().id()} -> $_name\n$e");
      rethrow;
    }
  }

  void dataToBytes(BinaryWriter writer) {
    // Prepare internal data
    final internData = BinaryWriter();

    internData.writeSmallMap(_boosters,
      (BinaryWriter writer, key)   => writer.writeOptional(key, (w) => key!.toBytesID(w)),
      (BinaryWriter writer, value) => writer.writeUint8(value));
    internData.writeSmallMap(sideProducts,
      (writer, key) => key.pid().toBytesID(writer),
      (writer, value) => writer.writeUint8(value));

    internData.writeSmallList(otherCards, (writer, item) => item.toBytes(writer));

    internData.writeUint8(nbRandomPerProduct);

    internData.writeUint8(_location.index);
    internData.writeSmallList(_excludeLanguage,
      (writer, lang) => lang.id.index
    );

    internData.writeSmallList(_honoredPokemon, (writer, item) => item.toBytes(writer));
    internData.writeSmallList(_honoredOther,   (writer, item) => item.toBytesID(writer));

    // Return data
    writer.writeUint8(version);
    writer.writeCompressBuffer(internData);
  }

  @override
  Widget image({double? height=70.0, alternativeRendering, photoView=false}) {
    return PokeRendering.productImage(super.pid(), height: height, alternativeRendering: alternativeRendering, photoView: photoView);
  }

  int countBoosters() {
    int count=0;
    for (var value in _boosters.values) { count += value; }
    return count;
  }
/*
  List<BoosterDraw> buildBoosterDraw() {
    var list = <BoosterDraw>[];
    int id=1;
    for (var value in boosters) {
      for( int i=0; i < value.nbBoosters; i+=1) {
        list.add( PokeBoosterDraw(creation: value.expansion, id: id, nbCards: value.nbCardsPerBooster) );
        id += 1;
      }
    }
    return list;
  }
*/
  /// Validate before send request
  bool validate() {
    return _boosters.isNotEmpty;
  }

  bool isFiltered(PokeLanguage language) {
    return language.location() != _location
        || _excludeLanguage.contains(language);
  }
}

class PokeProductRequested
{
  PokeProduct     product;
  final Color color;
  final int   count;

  PokeProductRequested(this.product, this.color, this.count);
}
/*
bool filter(PokeProduct product, Language l, SubExtension se, ProductCategory? category, Map userExtension, {bool onlyShowRandom=false}) {
  bool keep = product.language == l;
  // Filter language
  if( keep && category != null ) {
    keep = product.category == category;
  }
  // Keep user product only
  if( keep && userExtension.isNotEmpty ) {
    keep = userExtension.containsKey(product);
  }

  // Filter subextension
  if( keep ) {
    for(var booster in product.boosters) {
      if(!onlyShowRandom) {
        // Keep product of extension
        keep = booster.subExtension == se;
        if(keep) {
          break;
        }
      } else {
        if(se.seCards.notInsideRandom()) {
          keep = false;
        } else {
          if(userExtension.isNotEmpty) {
            // Search if user contains specific
            for (var subEx in userExtension[product]) {
              keep = se == subEx;
              if (keep) {
                break;
              }
            }
            if (keep) {
              break;
            }
          } else {
            // Search product with random
            for (var booster in product.boosters) {
              keep = booster.subExtension == null;
              if (keep) {
                break;
              }
            }
            // Keep product if after extension
            if (keep) {
              keep = (product.releaseDate.compareTo(se.out) >= 0);
            }
          }
        }
      }
    }
  }
  return keep;
}

Future<Map> filterProducts(Language l, SubExtension se, ProductCategory? category, {bool showAll=true, bool withUserCount=false, bool onlyWithUser=false, bool onlyLocalUser=false}) async
{
  printOutput("Filter: ${l.image} ${se.name} showRandom=$showAll computeUserCount=$withUserCount keepUserProduct=$onlyWithUser localUser=$onlyLocalUser");

  // Count all products
  Map<PokeProduct, int>                userCounts    = {};
  Map<PokeProduct, List<SubExtension>> userExtension = {};
  await Environment.instance.db.transactionR( (connection) async {
    if(withUserCount) {
      String query = "SELECT `idProduit`, COUNT(`idProduit`) as count"
          " FROM `UtilisateurProduit` "
          " GROUP BY `UtilisateurProduit`.`idProduit`;";
      var exts = await connection.query(query);
      for(var row in exts) {
        userCounts[Environment.instance.collection.products[row[0]]!] = row[1];
      }
    }

    if(onlyWithUser) {
      String query = "SELECT DISTINCT `idProduit`, `idSousExtension`"
          " FROM `UtilisateurProduit`, `TirageBooster`"
          " WHERE `UtilisateurProduit`.`idAchat` = `TirageBooster`.`idAchat`";
      if(onlyLocalUser) {
        query += " AND `UtilisateurProduit`.`idUtilisateur` = ${Environment.instance.user!.idDB};";
      }

      var exts = await connection.query(query);
      for(var row in exts) {
        var p = Environment.instance.collection.products[row[0]]!;
        if( !userExtension.containsKey(p)) {
          userExtension[p] = [];
        }

        userExtension[p]!.add( Environment.instance.collection.subExtensions[row[1]]! );
      }
    }
  });

  // Internal filter
  Map<ProductCategory, List<ProductRequested>> products = {};//.generate(Environment.instance.collection.categories.length, (index) { return []; });
  Environment.instance.collection.categories.forEach((key, category) { products[category] = [];});

  // Product of current extension
  for (var product in Environment.instance.collection.products.values) {
    // Add to list
    if(filter(product, l, se, category, userExtension)) {
      products[product.category]!.add(ProductRequested(product, Colors.grey.shade600, userCounts[product] ?? 0));
    }
  }
  if(showAll) {
    // Product of with random booster
    for (var product in Environment.instance.collection.products.values) {
      // Add to list
      if(filter(product, l, se, category, userExtension, onlyShowRandom: true)) {
        // Search product inside list
        bool find = false;
        for(var p in products[product.category]!) {
          find = (p.product == product);
          if(find) {
            break;
          }
        }
        // Add if missing
        if(!find) {
          products[product.category]!.add(PokeProductRequested(product, Colors.deepOrange.shade700, userCounts[product] ?? 0));
        }
      }
    }
  }
  return products;
}
*/