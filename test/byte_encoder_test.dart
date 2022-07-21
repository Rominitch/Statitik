import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';

void main() {
  test('ByteEncoder', () {

    var string = [
      "My demo",
      "2/102",
      "",
    ];

    for( var s in string) {
      var bytes = ByteEncoder.encodeString16(s.codeUnits);
      var parser = ByteParser(bytes);

      expect(s, parser.decodeString16());
    }
  });
}