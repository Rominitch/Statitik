import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/type_card.dart';

void main() {
  test('CardDescription.decrypted', () {
    Language fr = Language(id: 1, image: "");
    Language en = Language(id: 2, image: "");
    Language jp = Language(id: 3, image: "");
    TypeCard t5 = TypeCard.psy;

    Map<int, DescriptionData> map =
    {
      1: DescriptionData.fromDb(MultiLanguageString(["Monde","World","Sekai"]),0),

      2: DescriptionData.fromDb(MultiLanguageString(["Bonjour le <D:1> !","Hello <D:1> !","<D:1> Ohayô !"]),0),

      3: DescriptionData.fromDb(MultiLanguageString(["Je dis","I say","AA"]),0),

      4: DescriptionData.fromDb(MultiLanguageString(["<D:3> \"<D:2>\"","<D:3> \"<D:2>\"","<D:3> \"<D:2>\""]),0),

      5: DescriptionData.fromDb(MultiLanguageString(["<D:3> <E:${t5.index}>\"<D:2>\"", "", ""]),0),
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
    expect(info.finalString[1], "E:4");
    expect(info.finalString[2], "\"Bonjour le Monde !\"");
  });

  test('CardDescription.toWidget', ()
  {
    Language fr = Language(id: 1, image: "");
    Language en = Language(id: 2, image: "");
    Map<int, DescriptionData> map =
    {
      1: DescriptionData.fromDb(MultiLanguageString(["Test {1}", "", ""]),0),
      2: DescriptionData.fromDb(MultiLanguageString(["<E:1> {1} <D:1>", "", ""]),0),
      3: DescriptionData.fromDb(MultiLanguageString(["<E:{1}>{2}", "{2}<E:{1}>", ""]),0),
      4: DescriptionData.fromDb(MultiLanguageString(["<P:{1}>", "", ""]),0),
    };

    Map<int, PokemonInfo> mapPoke =
    {
      25: PokemonInfo(MultiLanguageString(["Pikachu", "Pikachu", "Pikachu"]), 1, 25),
    };

    var d2 = CardDescription(2);
    d2.parameters = [1, 2.0];
    Widget w = d2.toWidget(map, mapPoke, fr);

    expect(w.runtimeType, RichText);
    int count = 0;
    (w as RichText).text.visitChildren((span) { count += 1; return true; });
    expect(count, 2);

    // Test Dynamic Energy and parameter order
    var d3 = CardDescription(3);
    d3.parameters = [1, 2];
    var wFr = d3.toWidget(map, mapPoke, fr);
    var wEn = d3.toWidget(map, mapPoke, en);

    var frSpan = [];
    var enSpan = [];
    (wFr as RichText).text.visitChildren((span) { frSpan.add(span); return true; });
    (wEn as RichText).text.visitChildren((span) { enSpan.add(span); return true; });

    expect(frSpan[0], enSpan[1]);
    expect(frSpan[1], enSpan[0]);

    var d4 = CardDescription(4);
    d4.parameters = [25];
    var w4Fr = d4.toWidget(map, mapPoke, fr);

    var fr4Span = [];
    (w4Fr as RichText).text.visitChildren((span) { fr4Span.add(span); return true; });
    expect(fr4Span.length, 1);
    expect(fr4Span[0].text!, mapPoke[25]!.name(fr));
  });
}