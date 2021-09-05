import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/cardDrawData.dart';

void main() {
  test('CodeDraw', () {
    List c = [ CodeDraw(3, 4, 1), CodeDraw(0, 0, 0), CodeDraw(0, 0, 1,), CodeDraw(1, 0, 0)];
    for(CodeDraw code in c) {
      CodeDraw codeS = CodeDraw.fromInt(code.toInt());
      expect(codeS.countNormal,      codeS.countNormal);
      expect(codeS.countReverse,     codeS.countReverse);
      expect(codeS.countHalo,        codeS.countHalo);
    }

    expect(8, c[0].count());
    expect(0, c[1].count());
    expect(1, c[2].count());
  });
}