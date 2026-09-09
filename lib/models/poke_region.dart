
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';

class PokeRegion extends PokeIdentifier {

  PokeRegion.fromDB(super._id);

  PokeRegion.fromBytes(super.reader) : super.fromBytes();

  String? applicableName(PokeLanguage l) {
    return l.label(PokeIdentifier.region(super.number(), false));
  }
}