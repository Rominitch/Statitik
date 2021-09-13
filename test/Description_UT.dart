import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/CardEffect.dart';
import 'package:statitikcard/services/models.dart';

void main() {
  test('CardDescription.decrypted', () {
    Language fr = Language(id: 1, image: "");
    Language en = Language(id: 2, image: "");
    Language jp = Language(id: 3, image: "");
    Type t5 = Type.Psy;

    Map<int, MultiLanguageString> map =
    {
      1: MultiLanguageString(["Monde","World","Sekai"]),

      2: MultiLanguageString(["Bonjour le <D:1> !","Hello <D:1> !","<D:1> Ohayô !"]),

      3: MultiLanguageString(["Je dis","I say","AA"]),

      4: MultiLanguageString(["<D:3> \"<D:2>\"","<D:3> \"<D:2>\"","<D:3> \"<D:2>\""]),

      5: MultiLanguageString(["<D:3> <E:${t5.index}>\"<D:2>\"", "", ""]),
    };

    // Simple string
    var d1 = CardDescription(1);
    expect(d1.decrypted(map, fr).finalString[0], map[1]!.name(fr));
    expect(d1.decrypted(map, en).finalString[0], map[1]!.name(en));
    expect(d1.decrypted(map, jp).finalString[0], map[1]!.name(jp));

    // Combined string
    var d2 = CardDescription(2);
    expect(d2.decrypted(map, fr).finalString[0], "Bonjour le Monde !");
    expect(d2.decrypted(map, en).finalString[0], "Hello World !");
    expect(d2.decrypted(map, jp).finalString[0], "Sekai Ohayô !");

    // Multi-recursive combined string
    var d4 = CardDescription(4);
    expect(d4.decrypted(map, fr).finalString[0], "Je dis \"Bonjour le Monde !\"");
    expect(d4.decrypted(map, en).finalString[0], "I say \"Hello World !\"");

    var d5 = CardDescription(5);
    var info = d5.decrypted(map, fr);
    expect(info.finalString[0], "Je dis ");
    expect(info.finalString[1], "\"Bonjour le Monde !\"");
    expect(info.itemsInside.length, 1);
    expect(info.itemsInside.first.runtimeType, Image);
  });

  test('CardDescription.toWidget', ()
  {
    Language fr = Language(id: 1, image: "");
    Map<int, MultiLanguageString> map =
    {
      1: MultiLanguageString(["Test %f", "", ""]),
      2: MultiLanguageString(["<E:1> %d <D:1>", "", ""]),
    };

    var d2 = CardDescription(2);
    d2.parameters = [1, 2.0];
    Widget w = d2.toWidget(map, fr);

    expect(w.runtimeType, RichText);
  });
}