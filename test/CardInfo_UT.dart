import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/models.dart';

void main() {
  test('CardInfo', () {
    List c =
    [
      CardInfo(PokeRegion.Galar, PokeSpecial.FormeEau, [CardMarker.VMAX, CardMarker.MillePoint]),
      CardInfo(PokeRegion.Nothing, PokeSpecial.Nothing, []),
      CardInfo(PokeRegion.Kanto, PokeSpecial.Nothing, [CardMarker.VMAX]),
      CardInfo(PokeRegion.Alola, PokeSpecial.FormeFroid, [CardMarker.Escouade, CardMarker.Restaure]),
    ];
    for(CardInfo code in c) {
      CardInfo codeS = CardInfo.from(code.toCode());
      expect(code.region,      codeS.region);
      expect(code.markers,     codeS.markers);
      expect(code.special,     codeS.special);
    }

    expect(5144,   c[0].toCode());
    expect(0,      c[1].toCode());
    expect(1025,   c[2].toCode());
    expect(262455, c[3].toCode());
  });

  test('Encoding', () {
    var c = CodeCardInfo( 3456, 55668);
    List<int> b = [];
    c.encode(b);

    var d = CodeCardInfo.fromByte(b, 0);
    expect(c.name,  d.name);
    expect(c.info,  d.info);
  });
}