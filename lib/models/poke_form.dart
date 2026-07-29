
import 'package:statitikcard/models/poke_identifier.dart';

class PokeForm extends PokeIdentifier {
  PokeForm.fromDB(super._id);
  PokeForm.fromBytes(super.reader) : super.fromBytes();
}