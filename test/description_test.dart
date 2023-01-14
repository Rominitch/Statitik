import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_data.dart';
import 'package:statitikcard/services/models/type_card.dart';

void main() {
  test('CardDescription.noExtract', () {
    Language fr = Language(id: 1, image: "");
    Language en = Language(id: 2, image: "");
    Language jp = Language(id: 3, image: "");
    TypeCard t5 = TypeCard.psy;

    Map<int, DescriptionData> map =
    {
      1: DescriptionData.fromDb(MultiLanguageString(["Monde","World","Sekai"]),0),
    };

    // Simple string
    var d1 = CardDescription(1);
    expect(d1.decrypted(map, fr).finalString[0], map[1]!.name(fr));
    expect(d1.decrypted(map, en).finalString[0], map[1]!.name(en));
    expect(d1.decrypted(map, jp).finalString[0], map[1]!.name(jp));
  });

  test('CardDescription.toWidget', ()
  {
    Language fr = Language(id: 1, image: "");
    Language en = Language(id: 2, image: "");

    Map<int, Region> mapRegion =
    {
      1: Region(MultiLanguageString(["Region", "Region", "Region"]), MultiLanguageString(["%s de Region", "Regionian %s", "Regionian %s"])),
      2: Region(MultiLanguageString(["Paris", "Paris", "Paris"]),    MultiLanguageString(["%s de Paris", "Parisian %s", "Parisian %s"]))
    };

    Map<int, DescriptionData> map =
    {
      1: DescriptionData.fromDb(MultiLanguageString(["Test {1}", "", ""]),0),
      2: DescriptionData.fromDb(MultiLanguageString(["<E:1> {1}", "", ""]),0),
      3: DescriptionData.fromDb(MultiLanguageString(["<E:{1}>{2}", "{2}<E:{1}>", ""]),0),
      4: DescriptionData.fromDb(MultiLanguageString(["<P:{1}>", "", ""]),0),
      5: DescriptionData.fromDb(MultiLanguageString(["<R:{1}|{2}>", "", ""]),0),
    };

    Map<int, PokemonInfo> mapPoke =
    {
      25: PokemonInfo(MultiLanguageString(["Pikachu", "Pikachu", "Pikachu"]), 1, 25),
    };

    Map<int, MultiLanguageString> mapEffects =
    {
      1: MultiLanguageString(["E1","E1","E1"]),
      2: MultiLanguageString(["E2","E2","E2"]),
      3: MultiLanguageString(["E3","E3","E3"]),
    };

    var d2 = CardDescription(2);
    d2.parameters = [1, 2.0];
    Widget w = d2.toWidget(map, mapPoke, mapEffects, mapRegion, fr);

    expect(w.runtimeType, RichText);
    int count = 0;
    (w as RichText).text.visitChildren((span) { count += 1; return true; });
    expect(count, 2);

    // Test Dynamic Energy and parameter order
    var d3 = CardDescription(3);
    d3.parameters = [1, 2];
    var wFr = d3.toWidget(map, mapPoke, mapEffects, mapRegion, fr);
    var wEn = d3.toWidget(map, mapPoke, mapEffects, mapRegion, en);

    var frSpan = [];
    var enSpan = [];
    (wFr as RichText).text.visitChildren((span) { frSpan.add(span); return true; });
    (wEn as RichText).text.visitChildren((span) { enSpan.add(span); return true; });

    expect(frSpan[0], enSpan[1]);
    expect(frSpan[1], enSpan[0]);

    var d4 = CardDescription(4);
    d4.parameters = [25];
    var w4Fr = d4.toWidget(map, mapPoke, mapEffects, mapRegion, fr);

    var fr4Span = [];
    (w4Fr as RichText).text.visitChildren((span) { fr4Span.add(span); return true; });
    expect(fr4Span.length, 1);
    expect(fr4Span[0].text!, mapPoke[25]!.name(fr));

    // Pokemon name + region
    var d5 = CardDescription(5);
    d5.parameters = [25, 1];
    var w5Fr = d5.toWidget(map, mapPoke, mapEffects, mapRegion, fr);

    var fr5Span = [];
    (w5Fr as RichText).text.visitChildren((span) { fr5Span.add(span); return true; });
    expect(fr5Span.length, 1);
    var namePok = Pokemon(mapPoke[25]!, region: mapRegion[1]!);
    expect(fr5Span[0].text!, namePok.titleOfCard(fr));
  });
}