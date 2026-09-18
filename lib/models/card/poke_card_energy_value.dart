import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeEnergyValue {
  PokeCardType energy;
  int  value;

  PokeEnergyValue(this.energy, this.value);

  PokeEnergyValue.fromBytes(BinaryReader reader) :
    energy = PokeCardType.values[reader.readInt8()],
    value = reader.readInt16()
  {
    if(value > 60) {
      printOutput("Error inside DB HERE");
      value = 0;
    }
  }

  void toBytes(BinaryWriter writer) {
    writer.writeInt8(energy.index);
    writer.writeInt16(value);
  }
}