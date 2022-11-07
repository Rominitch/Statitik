import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/tools.dart';

class HTMLEffects  {
  Element? title;
  Element? description;

  HTMLEffects(this.title, this.description);
}

class HtmlCardParser {
  static const Map<String, TypeCard> _convertType = {
    "grass": TypeCard.plante,
    "fire": TypeCard.feu,
    "water": TypeCard.eau,
    "electric": TypeCard.electrique,
    "psychic": TypeCard.psy,
    "fighting": TypeCard.combat,
    "dark": TypeCard.obscurite,
    "dragon": TypeCard.dragon,
    "steel": TypeCard.metal,
    //"fairy": TypeCard.fee,
    "none": TypeCard.incolore,
  };

  static Future<bool> readEffectsJP(PokemonCardExtension card) async {
    final jpLanguage = Environment.instance.collection.languages[3];
    // Never fill already card
    if(card.data.cardEffects.effects.isNotEmpty) {
      printOutput("Card has already data");
      return false;
    }
    if(card.images.isEmpty || card.images.first.isEmpty || card.images.first.first.jpDBId == 0) {
      printOutput("Card has no valid JP Id");
      return false;
    }

    // Build Uri
    final htmlPage = Uri.https("www.pokemon-card.com", "card-search/details.php/card/${card.images.first.first.jpDBId}/regu/XY");

    // Get  page info
    final response = await http.Client().get(htmlPage);
    if(response.statusCode == 200) {
      var document = parse(response.body);
      var bodyElements = document.getElementsByClassName("RightBox-inner");
      if(bodyElements.isEmpty) {
        throw Exception("Bad page format from $htmlPage");
      }
      var body = bodyElements.first;

      List<HTMLEffects> htmlEffects = [];
      // Get Effects
      var lineEffects = body.getElementsByTagName("h4");
      for(var lineEffect in lineEffects) {
        var descriptionElement = lineEffect.nextElementSibling!;
        if(descriptionElement.localName != null && descriptionElement.localName! == "p") {
          htmlEffects.add(HTMLEffects(lineEffect, descriptionElement));
        }
      }
      // Get Effects from supporter
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "サポート") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(HTMLEffects(null, descriptionElement));
        }
      }
      // Get Effects from Object
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "グッズ") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(HTMLEffects(null, descriptionElement));
        } else if(lineEffect.text == "ポケモンのどうぐ") {
          // Skip first p
          var descriptionElement = lineEffect.nextElementSibling!.nextElementSibling;
          if(descriptionElement!.localName != null && descriptionElement.localName! == "p") {
            htmlEffects.add(HTMLEffects(null, descriptionElement));
          }
        }

        // Other power like pokemon
        var subEffects = lineEffect.getElementsByTagName("h4");
        for(var lineEffect in subEffects) {
          var descriptionElement = lineEffect.nextElementSibling;
          if(lineEffect.localName != null && lineEffect.localName! == "p") {
            htmlEffects.add(HTMLEffects(lineEffect, descriptionElement!));
          }
        }
      }
      // Get Effects from Stade
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "スタジアム") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(HTMLEffects(null, descriptionElement!));
        }
      }
      // Get Effects from energy
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "特殊エネルギー") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(HTMLEffects(null, descriptionElement!));
        }
      }

      for(var htmlEffect in htmlEffects) {
        // Get title/Energy/Power
        var effect = CardEffect();

        String effectName        = "";
        String effectDescription = "";
        if(htmlEffect.title != null) {
          for(var energy in htmlEffect.title!.getElementsByClassName("icon")){
            var idType = energy.className.replaceAll("icon", "").replaceAll("-", "").replaceAll(" ", "");
            var type = _convertType[idType];
            if(type != null) {
              effect.attack.add(type);
            } else {
              printOutput("Impossible to find type '$idType' from ${htmlPage.path}");
              return false;
            }
          }

          // Read power value if exist
          var powerNames = htmlEffect.title!.getElementsByClassName("f_right");
          if(powerNames.isNotEmpty) {
            var power = powerNames.first.text;
            bool add   = false;
            bool minus = false;
            bool cross = false;
            if(power.contains("＋")) {
              add = true;
              power = power.replaceAll("＋", "");
            } else if(power.contains("×")) {
              cross = true;
              power = power.replaceAll("×", "");
            } else if(power.contains("－")) {
              minus = true;
              power = power.replaceAll("－", "");
            }

            try {
              effect.power = int.parse(power);
            } catch (e) {
              printOutput("Unknown power: $power");
              rethrow;
            }
          }

          // Get pure text (remove all spans)
          for(var i in htmlEffect.title!.children) {
            i.remove();
          }
          effectName = htmlEffect.title!.text;
        }
        if(htmlEffect.description != null) {
          effectDescription = htmlEffect.description!.innerHtml;
          effectDescription = effectDescription.replaceAll(RegExp(r"<br\s*/>"), "");
          effectDescription = effectDescription.replaceAll(RegExp(r"<br\s*>"), "");
        }

        // Compute Title of effect (add into DB if not found)
        if(effectName.isNotEmpty) {
          effect.title = await getOrAddEffectName(effectName.trim(), jpLanguage);
        }
        if(effectDescription.isNotEmpty) {
          effect.description = await getOrAddDescription(effectDescription.trim(), jpLanguage);
        }

        //printOutput("Name Id: ${effect.title}\nPower: ${effect.power}\nE: ${effect.attack.length}\nDes Id: ${effect.description}\n");

        card.data.cardEffects.effects.add(effect);
      }
      return true;
    } else {
      printOutput("Impossible to find html page from ${htmlPage.path}");
    }
    return false;
  }

  static Future<int> getOrAddEffectName(String effectName, Language language) async {
    assert(effectName.isNotEmpty);
    int? id;

    for (MapEntry e in Environment.instance.collection.effects.entries) {
      var effectValue = e.value as MultiLanguageString;
      if(effectValue.name(language) == effectName) {
        id = e.key;
        printOutput("Find effect at $id");
        break;
      }
    }

    // If not find, need to add it
    id ??= await Environment.instance.addNewEffectName(effectName, language.id);

    return id!;
  }

  static Future<CardDescription?> getOrAddDescription(String descriptionName, Language language) async {
    assert(descriptionName.isNotEmpty);

    //printOutput("Des: $descriptionName");

    CardDescription? d;

    Map<int, int> codes = {};
    var finalDescription = descriptionName;

    // Remove Energy
    for(MapEntry energyEntry in _convertType.entries) {
      String pattern = "<span class=\"icon-${energyEntry.key} icon\"></span>";
      int start = 0;
      // Search
      do
      {
        var p = descriptionName.indexOf(pattern, start);
        if(p != -1) {
          finalDescription = finalDescription.replaceFirst(pattern, "<E:{}>");
          codes[p] = energyEntry.value.index;
          start = p+1;
        } else {
          start = -1;
        }
      }
      while(start != -1);
    }

    // Remove pokemon name
    for(MapEntry pokeEntry in Environment.instance.collection.pokemons.entries) {
      final pattern = pokeEntry.value.name(language);
      int start = 0;
      // Search
      do
      {
        var p = descriptionName.indexOf(pattern, start);
        if(p != -1) {
          finalDescription = finalDescription.replaceFirst(pattern, "<P:{}>");
          codes[p] = pokeEntry.key;
          start = p+1;
        } else {
          start = -1;
        }
      }
      while(start != -1);
    }

    // Remove number into text
    {
      var re = RegExp(r"(\d+)", unicode: true);
      re.allMatches(descriptionName).forEach((match) {
        var v = match.group(1)!;
        finalDescription = finalDescription.replaceFirst(v, "{}");
        codes[match.start] = int.parse(v);
      });
    }

    // Finalize string
    int codeId=0;
    finalDescription = finalDescription.replaceAllMapped("{}", (match) {
      codeId += 1;
      return "{$codeId}";
    });

    //printOutput("Final Des: $finalDescription");

    if(codes.length != codeId) {
      throw Exception("Bad parameters");
    }

    // Search strict data
    int? id;
    for (MapEntry e in Environment.instance.collection.descriptions.entries) {
      var descValue = e.value as DescriptionData;
      if(descValue.name(language) == finalDescription) {
        id = e.key;
        printOutput("Find description at $id");
        break;
      }
    }

    // If not find, need to add it
    id ??= await Environment.instance.addNewDescriptionData(finalDescription, language.id);

    // Create description
    d = CardDescription(id!);
    var orderedParam = codes.keys.toList(growable: false);
    orderedParam.sort();
    for(int idP in orderedParam) {
      d.parameters.add((codes[idP]!));
    }

    return d;
  }
}