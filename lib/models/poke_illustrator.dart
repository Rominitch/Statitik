
import 'package:statitikcard/models/poke_identifier.dart';

class PokeIllustrator extends PokeIdentifier{
  PokeIllustrator.fromDb(PokeIdentifier id) : super(id.id());
}