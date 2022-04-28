import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/Draw/cardDrawData.dart';

void main() {
  test('OldCodeDraw', () {
    List c = [ CodeDraw.fromOld(2, 4, 1), CodeDraw.fromOld(0, 0, 0), CodeDraw.fromOld(0, 0, 1), CodeDraw.fromOld(1, 0, 0), CodeDraw.fromOld(0, 1, 0)];
    List r = [[3, 4], [0, 0], [1, 0], [1, 0], [0, 1]];

    int id = 0;
    var result = r.iterator;
    for(CodeDraw code in c) {
      result.moveNext();

      CodeDraw codeS = CodeDraw.fromOldCode(2, code.toInt());
      expect(2, codeS.nbSetsRegistred());
      expect(result.current[0], codeS.countBySet(0), reason: "$id");
      expect(result.current[1], codeS.countBySet(1), reason: "$id");

      var allValues = codeS.allCounts();
      expect(allValues.length, codeS.nbSetsRegistred());
      expect(result.current[0], allValues[0], reason: "$id");
      expect(result.current[1], allValues[1], reason: "$id");

      id += 1;
    }

    expect(7, c[0].count());
    expect(0, c[1].count());
    expect(1, c[2].count());
    expect(1, c[3].count());
    expect(1, c[4].count());
  });
}