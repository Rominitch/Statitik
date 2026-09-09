import 'dart:collection';

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_card_effect.dart';
import 'package:statitikcard/models/poke_card_in_expansion.dart';
import 'package:statitikcard/models/poke_card_subject.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';

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

class AdminHTMLEffects  {
  Element? title;
  Element? description;

  AdminHTMLEffects(this.title, this.description);
}

class AdminHTMLEffectsReader  {
  String? title;
  String? description;

  AdminHTMLEffectsReader(this.title, this.description);
}

class AdminHtmlCardParser {
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

  final PokeNavAdmin _nav;
  late String regions = "";
  //late SplayTreeMap<int, PokemonName> pokemonOrdered;
  late List<PokemonName> pokemonOrdered;

  AdminHtmlCardParser(this._nav) {
    for(final region in _nav.collection.regions()) {
      regions += "${_nav.showLanguage.label(region)!}|";
    }
    pokemonOrdered= _nav.collection.pokemons().toList()..sort(
        (a, b) {
          return a.name(_nav.showLanguage)!.compareTo(b.name(_nav.showLanguage)!);
        }
    );
  }


  Future<bool> readEffectsJP(PokeCardInExpansion card) async {
    // UR / HR
    if(card.rarity.id() == 27 || card.rarity.id() == 24) {
      printOutput("Card never met into Jp pokemon site");
      return false;
    }

    final jpLanguage = _nav.collection.language(Language.jp);

    // Clean data to recompute effect from scratch
    card.card.cardEffects.effects.clear();

    // Find world card node
    List<AdminHTMLEffectsReader> frAbilities = [];
    List<AdminHTMLEffectsReader> usAbilities = [];

    PokeExpansion? seWorld;
    PokeCardIdentifier? cardIdWorld;
    _nav.collection.searchCardIntoSubExtension(card.card).forEach((element) {
      if( element.expansion.location() == CardLocation.Monde ) {
        seWorld     = element.expansion;
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
    final htmlPage = Uri.https("www.pokemon-card.com", "card-search/details.php/card/${card.specialID}/regu/XY");

    // Get  page info
    final response = await http.Client().get(htmlPage);
    if(response.statusCode == 200) {
      var document = parse(response.body);
      var bodyElements = document.getElementsByClassName("RightBox-inner");
      if(bodyElements.isEmpty) {
        throw Exception("Bad page format from $htmlPage");
      }
      var body = bodyElements.first;

      List<AdminHTMLEffects> htmlEffects = [];
      // Get Effects
      var lineEffects = body.getElementsByTagName("h4");
      for(var lineEffect in lineEffects) {
        var descriptionElement = lineEffect.nextElementSibling!;
        if(descriptionElement.localName != null && descriptionElement.localName! == "p") {
          htmlEffects.add(AdminHTMLEffects(lineEffect, descriptionElement));
        }
      }
      // Get Effects from supporter
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "サポート") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(AdminHTMLEffects(null, descriptionElement));
        }
      }
      // Get Effects from Object
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "グッズ") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(AdminHTMLEffects(null, descriptionElement));
        } else if(lineEffect.text == "ポケモンのどうぐ") {
          // Skip first p
          var descriptionElement = lineEffect.nextElementSibling!.nextElementSibling;
          if(descriptionElement!.localName != null && descriptionElement.localName! == "p") {
            htmlEffects.add(AdminHTMLEffects(null, descriptionElement));
          }
        }

        // Other power like pokemon
        var subEffects = lineEffect.getElementsByTagName("h4");
        for(var lineEffect in subEffects) {
          var descriptionElement = lineEffect.nextElementSibling;
          if(lineEffect.localName != null && lineEffect.localName! == "p") {
            htmlEffects.add(AdminHTMLEffects(lineEffect, descriptionElement!));
          }
        }
      }
      // Get Effects from Stade
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "スタジアム") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(AdminHTMLEffects(null, descriptionElement!));
        }
      }
      // Get Effects from energy
      for(var lineEffect in body.getElementsByClassName("mt20")) {
        if(lineEffect.text == "特殊エネルギー") {
          var descriptionElement = lineEffect.nextElementSibling;
          htmlEffects.add(AdminHTMLEffects(null, descriptionElement!));
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
        AdminHTMLEffectsReader? frInfo;
        AdminHTMLEffectsReader? usInfo;
        if(parserFr.moveNext()) {
          frInfo = parserFr.current;
        }
        if(parserUs.moveNext()) {
          usInfo = parserUs.current;
        }

        // Get title/Energy/Power
        PokeEffectName?        effectName;
        PokeEffectDescription? description;
        int             power  = 0;   /// Zero = no attack.
        List<TypeCard>  attack = [];

        String effectNameStr = "";
        String effectDescriptionStr = "";
        if(htmlEffect.title != null) {
          for(var energy in htmlEffect.title!.getElementsByClassName("icon")){
            var idType = energy.className.replaceAll("icon", "").replaceAll("-", "").replaceAll(" ", "");
            var type = _convertType[idType];
            if(type != null) {
              attack.add(type);
            } else {
              printOutputError("Impossible to find type '$idType' from ${htmlPage.path}");
              return false;
            }
          }

          // Read power value if exist
          var powerNames = htmlEffect.title!.getElementsByClassName("f_right");
          if(powerNames.isNotEmpty) {
            var powerStr = powerNames.first.text;
            //bool add   = false;
            //bool minus = false;
            //bool cross = false;
            if(powerStr.contains("＋")) {
              //add = true;
              powerStr = powerStr.replaceAll("＋", "");
            } else if(powerStr.contains("×")) {
              //cross = true;
              powerStr = powerStr.replaceAll("×", "");
            } else if(powerStr.contains("－")) {
              //minus = true;
              powerStr = powerStr.replaceAll("－", "");
            }

            try {
              power = int.parse(powerStr);
            } catch (e) {
              printOutput("Unknown power: $powerStr");
              rethrow;
            }
          }

          // Get pure text (remove all spans)
          for(var i in htmlEffect.title!.children) {
            i.remove();
          }
          effectNameStr = htmlEffect.title!.text.trim();
        }
        if(htmlEffect.description != null) {
          effectDescriptionStr = htmlEffect.description!.innerHtml;
          effectDescriptionStr = effectDescriptionStr.replaceAll(RegExp(r"<br\s*/>"), "");
          effectDescriptionStr = effectDescriptionStr.replaceAll(RegExp(r"<br\s*>"), "");
          effectDescriptionStr = effectDescriptionStr.trim();
        }

        // Compute Title of effect (add into DB if not found)

        if(effectNameStr.isNotEmpty) {
          final pid = await getOrAddEffectName(effectNameStr, jpLanguage);
          effectName = PokeEffectName.fromDB( pid.id() );
        }
        if(effectDescriptionStr.isNotEmpty) {
          if(frInfo == null || usInfo == null) {
            printOutput("${htmlPage.toString()}\n Impossible to find world info !\n");
          }
          description = await getOrAddDescription(effectDescriptionStr, jpLanguage);
        }

        //printOutput("Name Id: ${effect.title}\nPower: ${effect.power}\nE: ${effect.attack.length}\nDes Id: ${effect.description}\n");

        card.card.cardEffects.effects.add(PokeCardEffect(effectName, description, power, attack));
      }
      return true;
    } else {
      printOutput("Impossible to find html page from ${htmlPage.path}");
    }
    return false;
  }

  Future<PokeIdentifier> getOrAddEffectName(String effectLabels, PokeLanguage language) async {
    PokeIdentifier? id;
    // Search into Jp effect
    for (final e in _nav.collection.effectNames()) {
      if( language.label(e)! == effectLabels) {
        id = e;
        //printOutput("Find effect at $id");
        break;
      }
    }

    // If not find, need to add it
    if( id == null) {
      _nav.database.transactionR( (connection) async {
        id = await _nav.collection.addNewEffectName(connection, effectLabels, language);
      }
      );
    }

    return id!;
  }

  Future<PokeEffectDescription?> getOrAddDescription(String descriptionName, PokeLanguage language) async {
    PokeEffectDescription? d;
    //TODO
    /*
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
        for(final poke in pokemonOrdered) {
          final pattern = RegExp("「($regions)\\s*(${poke.name(language)!})([^」]*)」");
          final pokeMatches = pattern.firstMatch(subString);
          if(pokeMatches != null) {
            assert(pokeMatches.groupCount == 3);
            String injection = "";
            var regionFind = pokeMatches.group(1);
            if(regionFind != null && regionFind.isNotEmpty) {
              // Search region
              int regionId = -1;
              for(final region in _nav.collection.regions()) {
                if(regionFind == language.label(region)) {
                  regionId = region.id();
                  break;
                }
              }
              assert(regionId != -1);
              injection = "「<R:{}|{}>";
              codes[match.start] = poke.pid().id();
              codes[match.end]   = regionId;
            } else {
              injection = "「<P:{}>";
              codes[match.end] = poke.pid().id();
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
          for(final effectEntry in _nav.collection.effectNames()) {
            if( subString == "「${language.label(effectEntry)!}」") {
              codes[match.end] = effectEntry.id();
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
    for (final e in _nav.collection.descriptions().entries) {
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
*/
    return d;
  }

  static Future<List<AdminHTMLEffectsReader>> getFrDescription(PokeExpansion ext, PokeCardIdentifier cardId) async {
    return getWorldDescription("fr/jcc-pokemon/cartes-pokemon", ext, cardId);
  }

  static Future<List<AdminHTMLEffectsReader>> getUSDescription(PokeExpansion ext, PokeCardIdentifier cardId) async {
    return getWorldDescription("us/pokemon-tcg/pokemon-cards", ext, cardId);
  }

  static Future<List<AdminHTMLEffectsReader>> getWorldDescription(String codeLangue, PokeExpansion ext, PokeCardIdentifier cardId) async {
    List<AdminHTMLEffectsReader> htmlEffects = [];

    var codeCard = ext.cards.tcgImage(cardId.numberId).toUpperCase();

    for (var seFolder in ext.codes()) {
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

                htmlEffects.add(AdminHTMLEffectsReader(nameNode.text, description));
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
            htmlEffects.add(AdminHTMLEffectsReader(title, description));
          }
        }
        // First exit
        return htmlEffects;
      }
    }
    return htmlEffects; // return []
  }
}