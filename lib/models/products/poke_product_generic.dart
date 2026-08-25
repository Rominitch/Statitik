import 'package:flutter/material.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/products/poke_product_category.dart';

abstract class PokeProductGeneric
{
  PokeIdentifier       _pid;
  PokeProductCategory  category;
  DateTime             releaseDate;

  PokeProductGeneric(this._pid, this.category, this.releaseDate);

  Widget image();

  bool isEqual(PokeIdentifier pid) {
    return _pid.isEqual(pid);
  }

  PokeIdentifier pid() {
    return _pid;
  }
/*
  ProductGeneric.fromBytes(ByteParser parser, Collection collection) :
        idDB      = parser.extractInt32(),
        category  = parser.extractOptional((parser) => collection.categories[parser.extractInt32()]!),
        name      = parser.extractString16(),
        imageURL  = parser.extractString16(),
        releaseDate = parser.extractDateTime()
  ;

  List<int> toBytes() {
    return ByteEncoder.encodeInt32(idDB)
        + ByteEncoder.encodeOptional(category, () => ByteEncoder.encodeInt32(category!.idDB))
        + ByteEncoder.encodeString16(name.codeUnits)
        + ByteEncoder.encodeString16(imageURL.codeUnits)
        + ByteEncoder.encodeDateTime(releaseDate);
  }
*/
}
