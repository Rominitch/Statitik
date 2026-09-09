
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product.dart';
import 'package:statitikcard/services/environment.dart';

class PokeNavLanguage {
  final PokeCollection  collection;
  final PokeRendering   rendering;
  final PokeLanguage    language;

  const PokeNavLanguage(this.collection, this.rendering, this.language);
}

class PokeNavProductSelection
{
  PokeProduct?  selectedProduct;
  PokeLanguage? selectedLanguage;
  int?          selectedYear;

  final Function(PokeLanguage, PokeProduct) onSelection;

  PokeNavProductSelection(this.onSelection);
}

class PokeNavAdmin
{
  final PokeCollection  collection;
  final PokeRendering   rendering;
  final Database        database;
  final PokeLanguage    showLanguage; // Show all text : not for product/card

  PokeNavAdmin(this.collection, this.rendering, this.database, this.showLanguage);
}