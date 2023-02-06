import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/card_effect.dart';
import 'package:statitikcard/services/models/card_identifier.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/pokemon_card_extension.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/tools.dart';

class HTMLEffects  {
  Element? title;
  Element? description;

  HTMLEffects(this.title, this.description);
}

class HTMLEffectsReader  {
  String? title;
  String? description;

  HTMLEffectsReader(this.title, this.description);
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

  final Language language;
  late String regions = "";
  late SplayTreeMap<int, PokemonInfo> pokemonOrdered;

  HtmlCardParser(this.language) {
    for(MapEntry region in Environment.instance.collection.regions.entries) {
      regions += "${region.value.name(language)}|";
    }
    final pok = Environment.instance.collection.pokemons;
    pokemonOrdered = SplayTreeMap<int, PokemonInfo>.from(pok, (k1, k2) {
      var n1 = pok[k1].name(language);
      var n2 = pok[k2].name(language);

      if (n1.length > n2.length) {
        return -1;
      } else if (n1.length == n2.length) {
        return n1.compareTo(n2);
      }
      return 1;
    });
  }


  Future<bool> readEffectsJP(PokemonCardExtension card) async {
    if(card.images.isEmpty || card.images.first.isEmpty || card.images.first.first.jpDBId == 0) {
      printOutput("Card has no valid JP Id");
      return false;
    }

    // UR / HR
    if(card.rarity.id == 27 || card.rarity.id == 24) {
      printOutput("Card never met into Jp pokemon site");
      return false;
    }

    // Clean data to recompute effect from scratch
    card.data.cardEffects.effects.clear();

    // Find world card node
    List<HTMLEffectsReader> frAbilities = [];
    List<HTMLEffectsReader> usAbilities = [];

    SubExtension? seWorld;
    CardIdentifier? cardIdWorld;
    Environment.instance.collection.searchCardIntoSubExtension(card.data).forEach((element) {
      if( element.se.extension.language.isWorld() ) {
        seWorld     = element.se;
        cardIdWorld = element.idCard;
      }
    });

    if(seWorld != null) {
      frAbilities = await getFrDescription(seWorld!, cardIdWorld!);
      usAbilities = await getUSDescription(seWorld!, cardIdWorld!);

      if(frAbilities.length != usAbilities.length) {
        printOutputError("Abilities FR/US are not matched");
        throw Exception("Need investigate");
      }
    } else {
      printOutput("No World card found");
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

      var parserFr = frAbilities.iterator;
      var parserUs = usAbilities.iterator;

      if(seWorld != null && frAbilities.length != htmlEffects.length) {
        printOutputError("Abilities FR/JP are not matched");
        throw Exception("Need investigate");
      }

      for(var htmlEffect in htmlEffects) {
        // Read World info in same time if possible
        HTMLEffectsReader? frInfo;
        HTMLEffectsReader? usInfo;
        if(parserFr.moveNext()) {
          frInfo = parserFr.current;
        }
        if(parserUs.moveNext()) {
          usInfo = parserUs.current;
        }

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
              printOutputError("Impossible to find type '$idType' from ${htmlPage.path}");
              return false;
            }
          }

          // Read power value if exist
          var powerNames = htmlEffect.title!.getElementsByClassName("f_right");
          if(powerNames.isNotEmpty) {
            var power = powerNames.first.text;
            //bool add   = false;
            //bool minus = false;
            //bool cross = false;
            if(power.contains("＋")) {
              //add = true;
              power = power.replaceAll("＋", "");
            } else if(power.contains("×")) {
              //cross = true;
              power = power.replaceAll("×", "");
            } else if(power.contains("－")) {
              //minus = true;
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
          effectName = htmlEffect.title!.text.trim();
        }
        if(htmlEffect.description != null) {
          effectDescription = htmlEffect.description!.innerHtml;
          effectDescription = effectDescription.replaceAll(RegExp(r"<br\s*/>"), "");
          effectDescription = effectDescription.replaceAll(RegExp(r"<br\s*>"), "");
          effectDescription = effectDescription.trim();
        }

        // Compute Title of effect (add into DB if not found)
        if(effectName.isNotEmpty) {
          var name = MultiLanguageString(
              [ frInfo != null ? "${frInfo.title}" : "<$effectName>",
                usInfo != null ? "${usInfo.title}" : "<$effectName>",
                effectName]);
          effect.title = await getOrAddEffectName(name, language);
        }
        if(effectDescription.isNotEmpty) {
          if(frInfo == null || usInfo == null) {
            printOutput("${htmlPage.toString()}\n Impossible to find world info !\n");
          }
          var name = MultiLanguageString(
              [ frInfo != null ? "${frInfo.description}" : "<$effectDescription>",
                usInfo != null ? "${usInfo.description}" : "<$effectDescription>",
                effectDescription]);
          effect.description = await getOrAddDescription(name, language);
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

  Future<int> getOrAddEffectName(MultiLanguageString effectNames, Language language) async {
    int? id;
    // Search into Jp effect
    for (MapEntry e in Environment.instance.collection.effects.entries) {
      var effectValue = e.value as MultiLanguageString;
      if(effectValue.name(language) == effectNames.name(language)) {
        id = e.key;
        //printOutput("Find effect at $id");
        break;
      }
    }

    // If not find, need to add it
    id ??= await Environment.instance.addNewEffectName(effectNames);

    return id!;
  }

  Future<CardDescription?> getOrAddDescription(MultiLanguageString descriptionNames, Language language) async {
    CardDescription? d;
    final descriptionName = descriptionNames.name(language);
    Map<int, int> codes = {};
    var finalDescription = descriptionName;

    // Remove Energy
    for(MapEntry energyEntry in _convertType.entries) {
      String pattern = '<span class="icon-${energyEntry.key} icon"></span>';
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

    int start = 0;
    final specialWord = RegExp(r"(「[^」]*」)");
    Iterable<RegExpMatch> matches;
    do
    {
      // Search first
      matches = specialWord.allMatches(finalDescription, start);
      if(matches.isNotEmpty) {
        var match = matches.first;
        var subString = match.group(1)!;
        // Search pokemon naming
        bool findPokemon = false;
        for(MapEntry pokeEntry in pokemonOrdered.entries) {
          final pattern = RegExp("「($regions)\\s*(${pokeEntry.value.name(language)})([^」]*)」");
          final pokeMatches = pattern.firstMatch(subString);
          if(pokeMatches != null) {
            assert(pokeMatches.groupCount == 3);
            String injection = "";
            var regionFind = pokeMatches.group(1);
            if(regionFind != null && regionFind.isNotEmpty) {
              // Search region
              int regionId = -1;
              for(MapEntry region in Environment.instance.collection.regions.entries) {
                if(regionFind == region.value.name(language)) {
                  regionId = region.key;
                  break;
                }
              }
              assert(regionId != -1);
              injection = "「<R:{}|{}>";
              codes[match.start] = pokeEntry.key;
              codes[match.end]   = regionId;
            } else {
              injection = "「<P:{}>";
              codes[match.end] = pokeEntry.key;
            }
            // Finally inject
            injection += "${pokeMatches.group(3) ?? ""}」";
            finalDescription = finalDescription.replaceRange(match.start, match.end, injection);

            findPokemon = true;
            break; // Quit now
          }
        }

        if(!findPokemon) {
          // Remove effect name too
          for(MapEntry effectEntry in Environment.instance.collection.effects.entries) {
            if( subString == "「${effectEntry.value.name(language)}」") {
              codes[match.end] = effectEntry.key;
              finalDescription = finalDescription.replaceRange(match.start, match.end, "「<A:{}>」");
              break;
            }
          }
        }

        // Continue to search next item
        start = match.end;
      }
    }
    while(matches.isNotEmpty);

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
      throw Exception("Bad parameters: $descriptionName\n$finalDescription\n $codeId generated with $codes");
    }

    // Search strict data
    int? id;
    for (MapEntry e in Environment.instance.collection.descriptions.entries) {
      var descValue = e.value as DescriptionData;
      if(descValue.name(language) == finalDescription) {
        id = e.key;
        //printOutput("Find description at $id");
        break;
      }
    }

    var orderedParam = codes.keys.toList(growable: false);
    orderedParam.sort();
    String dumpParameters = "";
    for(int idP in orderedParam) {
      dumpParameters += "${codes[idP]!} ";
    }

    // Modify Fr/Us/Jp
    var finalName = MultiLanguageString(["<$dumpParameters>${descriptionNames.names()[0]}",
                                         "<$dumpParameters>${descriptionNames.names()[1]}",
                                         finalDescription]);

    // If not find, need to add it
    id ??= await Environment.instance.addNewDescriptionData(finalName);

    // Create description
    d = CardDescription(id!);

    for(int idP in orderedParam) {
      d.parameters.add((codes[idP]!));
    }

    return d;
  }

  static Future<List<HTMLEffectsReader>> getFrDescription(SubExtension ext, CardIdentifier cardId) async {
    return getWorldDescription("fr/jcc-pokemon/cartes-pokemon", ext, cardId);
  }

  static Future<List<HTMLEffectsReader>> getUSDescription(SubExtension ext, CardIdentifier cardId) async {
    return getWorldDescription("us/pokemon-tcg/pokemon-cards", ext, cardId);
  }

  static Future<List<HTMLEffectsReader>> getWorldDescription(String codeLangue, SubExtension ext, CardIdentifier cardId) async {
    List<HTMLEffectsReader> htmlEffects = [];

    var codeCard = ext.seCards.tcgImage(cardId.numberId).toUpperCase();

    for (var seFolder in ext.seCode) {
      final htmlPage = Uri.https("www.pokemon.com", "$codeLangue/ss-series/${seFolder.toLowerCase()}/$codeCard");
      //printOutput(htmlPage.toString());
      var skipNames = ["Règle V", "V rule", "Règle VMAX", "VMAX rule",];
      // Get  page info
      final response = await http.Client().get(htmlPage);
      if(response.statusCode == 200) {
        var document = parse(response.body);
        var abilities = document.getElementsByClassName("pokemon-abilities");

        // Special Ability/Talent
        if(abilities.isNotEmpty) {
          var div = abilities.first.getElementsByClassName("poke-ability");
          if(div.isNotEmpty) {
            var nameNode = div.first.nextElementSibling;
            if(nameNode!=null) {
              var p = abilities.first.getElementsByTagName("p");
              if(p.isNotEmpty) {
                var p2 = p.first.getElementsByTagName("p");
                String? description;
                if(p2.isNotEmpty) {
                  description = p2.first.text;
                } else {
                  if(p.first.text.isNotEmpty) {
                    description = p.first.text;
                  }
                }
                // Clean description
                if(description != null && description.isNotEmpty) {
                  String pattern = "<span class=\".*\">.*</span>";
                  int start = 0;
                  // Search
                  do
                  {
                    var p = description!.indexOf(pattern, start);
                    String finalDescription = description;
                    if(p != -1) {
                      finalDescription = finalDescription.replaceFirst(pattern, "<E:{}>");
                      start = p+1;
                    } else {
                      start = -1;
                    }
                    description = finalDescription;
                  }
                  while(start != -1);
                }

                if(nameNode.text.length > 100) {
                  printOutput("${htmlPage.toString()}\nAbility: Effect reach limit: ${nameNode.text}");
                }
                if(description != null && description.length > 500) {
                  printOutput("${htmlPage.toString()}\nAbility: Description reach limit: $description");
                }

                htmlEffects.add(HTMLEffectsReader(nameNode.text, description));
              }
            }
          }
        }
        for(var ability in abilities.first.getElementsByClassName("ability")) {
          String title = "";
          String description = "";

          var labelNode = ability.getElementsByClassName("left label");
          if(labelNode.isNotEmpty && labelNode.first.localName! == "h4") {
            title = labelNode.first.text;
          }

          // Stop if special name
          if(skipNames.contains(title)) {
            continue;
          }

          var preItem = ability.getElementsByTagName("pre");
          if(preItem.isNotEmpty) {
            var pItem = preItem.first.getElementsByTagName("p");
            if(pItem.isNotEmpty) {
              description = pItem.first.text.trim();
            } else {
              description = preItem.first.text.trim();
            }
          }

          if(title.length > 100) {
            printOutput("${htmlPage.toString()}\nEffect reach limit: $title");
          }
          if(description.length > 500) {
            printOutput("${htmlPage.toString()}\nDescription reach limit: $description");
          }

          if(title.isNotEmpty || description.isNotEmpty) {
            htmlEffects.add(HTMLEffectsReader(title, description));
          }
        }
        // First exit
        return htmlEffects;
      }
    }
    return htmlEffects; // return []
  }
}