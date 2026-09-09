import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product_generic.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/widgets/image/image_with_cache.dart';

class PokeProductSide extends PokeProductGeneric
{
  final PokeIdentifier _idName;

  PokeProductSide(super._pid, super.category, super.releaseDate, this._idName);

  //PokeProductSide.fromBytes(super.parser, super.collection) : super.fromBytes();

  @override
  Widget image({alternativeRendering})
  {
    return PokeRendering.sideProductImage(super.pid(), alternativeRendering: alternativeRendering);
  }

  String name(PokeLanguage language) {
    return language.label(_idName)!;
  }

  PokeIdentifier idName() { return _idName; }
}