import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/tools/binary_manager.dart';

class PokeEnergyValue {
  TypeCard energy;
  int  value;

  PokeEnergyValue(this.energy, this.value);

  PokeEnergyValue.fromBytesArray(List<int> bytes) :
        energy = TypeCard.values[bytes[0]],
        value = (bytes[1] << 8) | bytes[2];

  PokeEnergyValue.fromBytes(BinaryReader reader) :
        energy = TypeCard.values[reader.readInt8()],
        value = reader.readInt16();

  void toBytes(BinaryWriter writer) {
    writer.writeInt8(energy.index);
    writer.writeInt16(value);
  }
}