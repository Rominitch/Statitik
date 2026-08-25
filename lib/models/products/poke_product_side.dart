import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/products/poke_product_generic.dart';
import 'package:statitikcard/services/tools.dart';

class PokeProductSide extends PokeProductGeneric
{
  final PokeIdentifier _idName;

  PokeProductSide(super._pid, super.category, super.releaseDate, this._idName);

  //PokeProductSide.fromBytes(super.parser, super.collection) : super.fromBytes();

  @override
  Widget image({alternativeRendering})
  {
    return drawCachedImage('PKSideProducts', super.pid().id().toString(), height: 70, alternativeRendering: alternativeRendering);
  }
}