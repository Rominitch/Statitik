import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/models.dart';

void main() {
  test('Description', () {
    Language fr = Language(id: 1, image: "");
    Language en = Language(id: 2, image: "");

    Map<int, MultiLanguageString> map =
    {
      1: MultiLanguageString(["Monde","World","Sekai"]),

      2: MultiLanguageString(["Bonjour le <D:1> !","Hello <D:1> !","<D:1> Ohayô !"]),

    };

    // Simple string
    var d1 = CardDescription(1);
    expect(d1.decrypted(map, fr).finalString, map[1]!.name(fr));
    expect(d1.decrypted(map, en).finalString, map[1]!.name(en));

    // Combined string
    var d2 = CardDescription(2);
    expect(d2.decrypted(map, fr).finalString, "Bonjour le Monde !");
    expect(d2.decrypted(map, en).finalString, "Hello World !");
  });
}