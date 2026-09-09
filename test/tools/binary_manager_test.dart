import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/tools/binary_manager.dart';

void main() {
    test('BinaryManager', () {
      final int i8  = 123;
      final int i16 = 1230;
      final int i32 = 456789;
      final double f32 = 3.14;
      final String s = "Bonjour";
      final List<String> ls = ["A", "B", "C"];
      final Map<String, int> msi = {
        "HP": 100,
        "MP": 50,
      };
      final DateTime date = DateTime(2026,07,17);

      final writer = BinaryWriter();

      writer.writeInt8(i8);
      writer.writeInt16(i16);
      writer.writeInt32(i32);
      writer.writeFloat32(f32);
      writer.writeString(s);

      writer.writeList<String>(
        ls,
            (w, item) => w.writeString(item),
      );

      writer.writeMap<String, int>(
        msi,
        (w, key) => w.writeString(key),
        (w, value) => w.writeInt16(value),
      );

      writer.writeDateTime(date);

      final bytes = writer.toBytes();

      expect( 65, bytes.length );

      final reader = BinaryReader(bytes);

      expect( i8,  reader.readInt8());
      expect( i16, reader.readInt16());
      expect( i32, reader.readInt32());
      expect( f32, closeTo(reader.readFloat32(), 1e-4));

      expect( s, reader.readString());

      expect( ls, reader.readList(
            (r) => r.readString(),
      ));

      expect(msi, reader.readMap(
        (r) => r.readString(),
        (r, k) => r.readInt16(),
      ));

      expect(date, reader.readDateTime());
    });
  }