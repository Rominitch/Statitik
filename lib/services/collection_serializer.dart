import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:statitikcard/services/collection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/card_design.dart';
import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/rarity.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/sub_extension_cards.dart';

import 'models/bytes_coder.dart';
import 'models/card_set.dart';
import 'models/extension.dart';
import 'models/language.dart';
import 'models/marker.dart';

class CollectionSerializer {
  final double serializeVersion = 1.0;
  final String fileName = "Database";

  Future<String> databaseFileName() async {
     final path = await getApplicationDocumentsDirectory();
     return [path.path, fileName].join(Platform.pathSeparator);
  }

  Future<bool> serialize(int version, Collection collection) async {
    List<int> bodyBytes = [];

    Environment.instance.onProgression.add(0.0);
    bodyBytes += ByteEncoder.encodeDouble(serializeVersion);
    bodyBytes += ByteEncoder.encodeInt32(version);

    // Encode language
    Environment.instance.onProgression.add(0.01);
    bodyBytes += ByteEncoder.encodeMap<int, Language>(collection.languages,
        (id) => ByteEncoder.encodeInt32(id),
        (Language lang) => lang.toBytes()
    );

    // Encode sets
    Environment.instance.onProgression.add(0.02);
    bodyBytes += ByteEncoder.encodeMap<int, CardSet>(collection.sets,
        (id) => ByteEncoder.encodeInt32(id),
        (CardSet set) => set.toBytes()
    );
    // Encode rarities
    Environment.instance.onProgression.add(0.03);
    bodyBytes += ByteEncoder.encodeMap<int, Rarity>(collection.rarities,
            (id) => ByteEncoder.encodeInt32(id),
            (Rarity rarity) => rarity.toBytes()
    );
    Environment.instance.onProgression.add(0.04);
    bodyBytes += ByteEncoder.encodeBytesArray16(getIds(collection.japanRarity));
    bodyBytes += ByteEncoder.encodeBytesArray16(getIds(collection.worldRarity));
    bodyBytes += ByteEncoder.encodeBytesArray16(getIds(collection.goodCard));
    bodyBytes += ByteEncoder.encodeBytesArray16(getIds(collection.otherThanReverse));

    // Encode markers
    Environment.instance.onProgression.add(0.05);
    bodyBytes += ByteEncoder.encodeMap<int, CardMarker>(collection.markers,
      (id) => ByteEncoder.encodeInt32(id),
      (CardMarker m) => m.toBytes()
    );
    bodyBytes += ByteEncoder.encodeBytesArray16(getIds(collection.longMarkers));

    // Encode Extensions
    Environment.instance.onProgression.add(0.06);
    bodyBytes += ByteEncoder.encodeMap<int, Extension>(collection.extensions,
      (id) => ByteEncoder.encodeInt32(id),
      (Extension e) => e.toBytes()
    );

    // Encode Pokemons
    Environment.instance.onProgression.add(0.07);
    bodyBytes += ByteEncoder.encodeMap<int, PokemonInfo>(collection.pokemons,
      (id) => ByteEncoder.encodeInt32(id),
      (PokemonInfo e) => e.toBytes()
    );

    // Encode otherNames
    Environment.instance.onProgression.add(0.2);
    bodyBytes += ByteEncoder.encodeMap<int, CardTitleData>(collection.otherNames,
      (id) => ByteEncoder.encodeInt32(id),
      (CardTitleData e) => e.toBytes()
    );

    // Encode Region
    Environment.instance.onProgression.add(0.3);
    bodyBytes += ByteEncoder.encodeMap<int, Region>(collection.regions,
      (id) => ByteEncoder.encodeInt32(id),
      (Region e) => e.toBytes()
    );
    // Encode Forme
    Environment.instance.onProgression.add(0.35);
    bodyBytes += ByteEncoder.encodeMap<int, Forme>(collection.formes,
      (id) => ByteEncoder.encodeInt32(id),
      (Forme e) => e.toBytes()
    );
    // Encode CardDesignData
    Environment.instance.onProgression.add(0.4);
    bodyBytes += ByteEncoder.encodeMap<int, Map<int, CardDesignData>>(collection.designs,
      (int id) => ByteEncoder.encodeInt32(id),
      (Map<int, CardDesignData> map) => ByteEncoder.encodeMap<int, CardDesignData>(map,
        (id2) => ByteEncoder.encodeInt32(id2),
        (CardDesignData e) => e.toBytes())
    );
    // Encode CardDesignData
    Environment.instance.onProgression.add(0.41);
    bodyBytes += ByteEncoder.encodeArray16<CardDesign>(collection.validDesigns,
      (CardDesign e) => e.toBytes()
    );
    // Encode Kanji
    Environment.instance.onProgression.add(0.42);
    bodyBytes += ByteEncoder.encodeMap<String,String>(collection.convertKanji,
      (String id) => ByteEncoder.encodeString16(id.codeUnits),
      (String  e) => ByteEncoder.encodeString16(e.codeUnits)
    );
    // Encode Illustrators
    Environment.instance.onProgression.add(0.43);
    bodyBytes += ByteEncoder.encodeMap<int,Illustrator>(collection.illustrators,
      (id) => ByteEncoder.encodeInt32(id),
      (Illustrator e) => e.toBytes()
    );
    // Encode Descriptions
    Environment.instance.onProgression.add(0.44);
    bodyBytes += ByteEncoder.encodeMap<int,DescriptionData>(collection.descriptions,
      (id) => ByteEncoder.encodeInt32(id),
      (DescriptionData e) => e.toBytes()
    );
    // Encode Effects
    Environment.instance.onProgression.add(0.45);
    bodyBytes += ByteEncoder.encodeMap<int,MultiLanguageString>(collection.effects,
      (id) => ByteEncoder.encodeInt32(id),
      (MultiLanguageString e) => ByteEncoder.encodeMultiLanguage(e)
    );
    // Encode Cards
    Environment.instance.onProgression.add(0.46);
    bodyBytes += ByteEncoder.encodeMap<int,PokemonCardData>(collection.pokemonCards,
      (id) => ByteEncoder.encodeInt32(id),
      (PokemonCardData e) => e.toBytes()
    );
    // Encode CardExtensions
    Environment.instance.onProgression.add(0.6);
    bodyBytes += ByteEncoder.encodeMap<int,SubExtensionCards>(collection.cardsExtensions,
      (id) => ByteEncoder.encodeInt32(id),
      (SubExtensionCards e) => e.toBytes()
    );
    // Encode SubExtension
    Environment.instance.onProgression.add(0.7);
    bodyBytes += ByteEncoder.encodeMap<int,SubExtension>(collection.subExtensions,
      (id) => ByteEncoder.encodeInt32(id),
      (SubExtension e) => e.toBytes()
    );
    // Encode ProductCategory
    Environment.instance.onProgression.add(0.8);
    bodyBytes += ByteEncoder.encodeMap<int,ProductCategory>(collection.categories,
      (id) => ByteEncoder.encodeInt32(id),
      (ProductCategory e) => e.toBytes()
    );
    // Encode ProductSide
    Environment.instance.onProgression.add(0.9);
    bodyBytes += ByteEncoder.encodeMap<int,ProductSide>(collection.productSides,
      (id) => ByteEncoder.encodeInt32(id),
      (ProductSide e) => e.toBytes()
    );
    // Encode Product
    Environment.instance.onProgression.add(0.91);
    bodyBytes += ByteEncoder.encodeMap<int,Product>(collection.products,
      (id) => ByteEncoder.encodeInt32(id),
      (Product e) => e.toBytes()
    );

    final appPath = await databaseFileName();
    var file = File(appPath);
    final info = await file.writeAsBytes(gzip.encode(bodyBytes.toList(growable: false)));

    Environment.instance.onProgression.add(1.0);
    return info.exists();
  }

  List<int> getIds(dynamic list) {
    List<int> ids = [];
    for(final i in list) { ids.add(i.id); }
    return ids;
  }

  Future<int> decode(Collection collection) async {
    final int badDB = -1;
    final appPath = await databaseFileName();
    var file = File(appPath);
    final exists = await file.exists();
    if( !exists ) return badDB;

    // Extract data
    final info = await file.readAsBytes();
    ByteParser parser = ByteParser(gzip.decode(info.toList(growable: false)));

    final localVersion = parser.extractDouble();
    if (localVersion != serializeVersion) return badDB;

    final version = parser.extractInt32();

    // Extract language
    collection.languages = parser.extractMap<int, Language>(
            (parser) => parser.extractInt32(),
            (parser) => Language.fromBytes(parser)
    );
    // Extract sets
    collection.sets = parser.extractMap<int, CardSet>(
            (parser) => parser.extractInt32(),
            (parser) => CardSet.fromBytes(parser)
    );
    // Extract rarities
    collection.rarities = parser.extractMapWithOrder<int, Rarity>(
        (parser) => parser.extractInt32(),
        (parser) => Rarity.fromBytes(parser),
        collection.orderedRarity
    );
    collection.japanRarity      += extractIds<Rarity>(collection.rarities, parser.extractBytesArray16());
    collection.worldRarity      += extractIds<Rarity>(collection.rarities, parser.extractBytesArray16());
    collection.goodCard         += extractIds<Rarity>(collection.rarities, parser.extractBytesArray16());
    collection.otherThanReverse += extractIds<Rarity>(collection.rarities, parser.extractBytesArray16());
    assert(collection.rarities.isNotEmpty);
    collection.unknownRarity = collection.rarities[Collection.idUnknownRarity];

    // Extract markers
    collection.markers = parser.extractMap<int, CardMarker>(
      (parser) => parser.extractInt32(),
      (parser) => CardMarker.fromBytes(parser)
    );
    collection.longMarkers += extractIds<CardMarker>(collection.markers, parser.extractBytesArray16());

    // Extract Extensions
    collection.extensions = parser.extractMap<int, Extension>(
      (parser) => parser.extractInt32(),
      (parser) => Extension.fromBytes(collection, parser)
    );

    // Extract Pokemon
    collection.pokemons = parser.extractMap<int, PokemonInfo>(
            (parser) => parser.extractInt32(),
            (parser) => PokemonInfo.fromBytes(parser)
    );

    // Extract otherNames
    collection.otherNames = parser.extractMap<int, CardTitleData>(
            (parser) => parser.extractInt32(),
            (parser) => CardTitleData.fromBytes(parser)
    );

    // Extract Region
    collection.regions = parser.extractMap<int, Region>(
            (parser) => parser.extractInt32(),
            (parser) => Region.fromBytes(parser)
    );
    // Extract Forme
    collection.formes = parser.extractMap<int, Forme>(
            (parser) => parser.extractInt32(),
            (parser) => Forme.fromBytes(parser)
    );
    // Extract CardDesignData
    collection.designs = parser.extractMap<int, Map<int, CardDesignData>>(
            (parser) => parser.extractInt32(),
            (parser) => parser.extractMap<int, CardDesignData>(
                (parser) => parser.extractInt32(),
                (parser) => CardDesignData.fromBytes(parser)
            )
    );
    // Extract CardDesignData
    collection.validDesigns = parser.extractArray16<CardDesign>(
      (parser) => CardDesign.fromBytes(parser)
    );
    // Extract Kanji
    collection.convertKanji = parser.extractMap<String,String>(
            (parser) => parser.extractString16(),
            (parser) => parser.extractString16()
    );
    // Extract Illustrators
    collection.illustrators = parser.extractMap<int,Illustrator>(
            (parser) => parser.extractInt32(),
            (parser) => Illustrator.fromBytes(parser)
    );
    // Extract Descriptions
    collection.descriptions = parser.extractMap<int,DescriptionData>(
      (parser) => parser.extractInt32(),
      (parser) => DescriptionData.fromBytes(parser)
    );
    // Extract Effects
    collection.effects = parser.extractMap<int,MultiLanguageString>(
      (parser) => parser.extractInt32(),
      (parser) => parser.extractMultiLanguage()!
    );
    // Extract CardExtensions
    collection.cardsExtensions = parser.extractMap<int,SubExtensionCards>(
      (parser) => parser.extractInt32(),
      (parser) => SubExtensionCards.fromBytes(parser, collection)
    );
    // Extract SubExtension
    collection.subExtensions = parser.extractMap<int,SubExtension>(
      (parser) => parser.extractInt32(),
      (parser) => SubExtension.fromBytes(parser, collection)
    );
    // Extract ProductCategory
    collection.categories = parser.extractMap<int,ProductCategory>(
      (parser) => parser.extractInt32(),
      (parser) => ProductCategory.fromBytes(parser)
    );
    // Extract ProductSides
    collection.productSides = parser.extractMap<int,ProductSide>(
      (parser) => parser.extractInt32(),
      (parser) => ProductSide.fromBytes(parser, collection)
    );

    // Extract Product
    Environment.instance.onProgression.add(0.91);
    collection.products = parser.extractMap<int,Product>(
      (parser) => parser.extractInt32(),
      (parser) => Product.fromBytes(parser, collection)
    );

    return version;
  }

  List<TypeData> extractIds<TypeData>(Map map, List<int> ids) {
    List<TypeData> list = [];
    for(final id in ids) {
      list.add(map[id]);
    }
    return list;
  }
}