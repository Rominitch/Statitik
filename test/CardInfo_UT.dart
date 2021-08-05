import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/models.dart';

void main() {
  test('CardInfo', () {
    List c =
    [
      CardInfo([CardMarker.VMAX, CardMarker.MillePoint]),
      CardInfo([]),
      CardInfo([CardMarker.VMAX]),
      CardInfo([CardMarker.Escouade, CardMarker.Restaure]),
    ];
    for(CardInfo code in c) {
      CardInfo codeS = CardInfo.from(code.toCode());
      expect(code.markers,     codeS.markers);
    }

    expect(20,     c[0].toCode());
    expect(0,      c[1].toCode());
    expect(4,      c[2].toCode());
    expect(1025,   c[3].toCode());
  });
}