import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/cardDrawData.dart';

void main() {
  test('CodeDraw', () {
    List c = [ CodeDraw.fromOld(3, 4, 1), CodeDraw.fromOld(0, 0, 0), CodeDraw.fromOld(0, 0, 1,), CodeDraw.fromOld(1, 0, 0)];
    List r = [[4, 4], [0, 0], [1, 0], [1, 0]];
    var result = r.iterator;
    for(CodeDraw code in c) {
      result.moveNext();

      CodeDraw codeS = CodeDraw.oldDecode(code.toInt());
      expect(2, codeS.countBySet.length);
      expect(result.current[0], codeS.countBySet[0]);
      expect(result.current[1], codeS.countBySet[1]);
    }

    expect(8, c[0].count());
    expect(0, c[1].count());
    expect(1, c[2].count());
    expect(1, c[3].count());
  });
}