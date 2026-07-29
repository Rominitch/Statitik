
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_langage.dart';

class PokeRegion extends PokeIdentifier {

  PokeRegion.fromDB(super._id);

  PokeRegion.fromBytes(super.reader) : super.fromBytes();

  String? applicableName(PokeLangage l) {
    return l.label(PokeIdentifier.region(super.number(), false));
  }
}