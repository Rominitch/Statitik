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
      CardInfo([CardMarker.Restaure, CardMarker.RegenerationAlpha]),
    ];
    for(CardInfo code in c) {
      CardInfo codeS = CardInfo.from(code.toCode());
      expect(code.markers,     codeS.markers);
    }

    expect([0,20],        c[0].toCode());
    expect([0,0],         c[1].toCode());
    expect([0,4],         c[2].toCode());
    expect([0, 1025],     c[3].toCode());
    expect([0, 33555456], c[4].toCode());
  });
}