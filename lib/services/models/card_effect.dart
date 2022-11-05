import 'package:flutter/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models/bytes_coder.dart';
import 'package:statitikcard/services/models/card_title_data.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/multi_language_string.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/models/models.dart';

class DescriptionData {
  final MultiLanguageString     multiName;
  List<DescriptionEffect> markers = [];

  DescriptionData.fromDb(this.multiName, int marks) {
    int id = 1;
    while(marks > 0)
    {
      if((marks & 0x1) == 0x1) {
        markers.add(DescriptionEffect.values[id]);
      }
      id = id+1;
      marks = marks >> 1;
    }
  }

  String name(Language l) {
    return multiName.name(l);
  }

  bool search(Language? l, String searchPart) {
    return multiName.search(l, searchPart);
  }
}

class DecryptedString {
  List<String>  finalString = [];
  //List<dynamic> itemsInside = [];
  //Map<int, dynamic> itemsInside = {};
}

class CardDescription {
  int   idDescription;
  List  parameters = []; ///< List of parameter to substitute
  List<DescriptionEffect> effects = [];

  CardDescription(this.idDescription);

  CardDescription.fromBytes(ByteParser parser) : idDescription = parser.extractInt16()
  {
    if(idDescription > 0) {
      int nbParams = parser.extractInt8();

      for(int i = 0; i < nbParams; i += 1) {
        parameters.add( parser.extractInt16() );
      }
    }
  }

  void computeDescriptionEffects(Map descriptionCollection, Language l) {
    // Combine and extract info
    RegExp exp = RegExp(r"(.*?)<(.?:\{\d+\})>(.*)", unicode: true);
    int count=0;

    effects.clear();

    DescriptionData data = descriptionCollection[idDescription];
    for (var element in data.markers) { if(!effects.contains(element)) effects.add(element); }

    String toAnalyze = data.name(l);
    while(toAnalyze.isNotEmpty) {
      var match = exp.firstMatch(toAnalyze);
      if( match != null ) {
        toAnalyze = "";
        var code = match.group(2)!.split(":");
        assert(code.length==2);
        if( code[0] == "D" ) {
          DescriptionData data = descriptionCollection[int.parse(code[1])];
          for (var element in data.markers) { if(!effects.contains(element)) effects.add(element); }

          toAnalyze += data.name(l);
        } else if( code[0] == "E" || code[0] == "P") {
        } else {
          throw StatitikException("Error of code");
        }
        toAnalyze += match.group(3)!;
      } else {
        break;
      }
      count += 1;
      if(count > 30) throw StatitikException("Loop detector");
    }
  }

  List<int> toBytes() {
    List<int> bytes = <int>[
      (idDescription & 0xFF00) >> 8, idDescription & 0xFF,
      parameters.length
    ];
    for (var element in parameters) {
      bytes.add((element & 0xFF00) >> 8);
      bytes.add(element & 0xFF);
    }
    return bytes;
  }

  String interpolate(String string, List params) {
    String result = string;
    for (int i = 1; i < params.length + 1; i++) {
      result = result.replaceAll('{$i}', params[i-1].toString());
    }
    return result;
  }

  Widget toWidget(Map descriptionCollection, Map pokemonCollection, Language l)
  {
    var current = decrypted(descriptionCollection, l);

    List<InlineSpan> children = [];
    var itString = current.finalString.iterator;

    while(itString.moveNext()) {
      var finalText = interpolate(itString.current, parameters);
      if(finalText.isNotEmpty) {
        if(itString.current.startsWith("E:")) {
          String energyCode = finalText.substring(2);
          children.add(WidgetSpan(child: getImageType(TypeCard.values[int.parse(energyCode)])));
        } else if(itString.current.startsWith("P:")) {
          String pokeCode = finalText.substring(2);
          PokemonInfo poke = pokemonCollection[int.parse(pokeCode)];
          children.add(TextSpan(text: poke.name(l)));
        } else {
          children.add(TextSpan(text: finalText));
        }
      }
    }
    // Create final text
    return RichText(text: TextSpan(children: children) );
  }

  DecryptedString decrypted(Map descriptionCollection, Language l) {
    DecryptedString s = DecryptedString();

    // Combine and extract info
    RegExp exp = RegExp(r"(.*?)<(.?:\{\d+\})>(.*)", unicode: true);

    s.finalString.add("");
    int count=0;

    DescriptionData data = descriptionCollection[idDescription];
    String toAnalyze = data.name(l);
    while(toAnalyze.isNotEmpty) {
      var match = exp.firstMatch(toAnalyze);
      if( match != null ) {
          toAnalyze = "";
          s.finalString.last += match.group(1)!;
          var code = match.group(2)!.split(":");
          assert(code.length==2);
          if( code[0] == "D" ) {
            DescriptionData data = descriptionCollection[int.parse(code[1])];
            toAnalyze += data.name(l);
          } else if( code[0] == "E" ) {
            //s.itemsInside.add(getImageType(Type.values[int.parse(code[1])]));
            s.finalString.add("E:${code[1]}");
            s.finalString.add(""); // New string to cumulate
          } else if( code[0] == "P" ) {
            s.finalString.add("P:${code[1]}");
            s.finalString.add(""); // New string to cumulate
          } else {
            throw StatitikException("Error of code");
          }
          toAnalyze += match.group(3)!;
      } else {
        s.finalString.last += toAnalyze;
        break;
      }
      count += 1;
      if(count > 30) throw StatitikException("Loop detector");
    }
    return s;
  }
}

class CardEffect {
  int?              title;       /// Title of capacity if exist.
  CardDescription?  description; /// Description if exists.

  int             power  = 0;   /// Zero = no attack.
  List<TypeCard>  attack = [];  /// Energy to attach for attack.

  CardEffect();
  CardEffect.fromBytes(ByteParser parser) {
    int idEffect = parser.extractInt16();
    if(idEffect != 0) {
      title = idEffect;
    }

    var newDescription = CardDescription.fromBytes(parser);
    if(newDescription.idDescription > 0) {
      description = newDescription;
    }

    power = parser.extractInt16();

    int nbAttack = parser.extractInt8();
    for(int i = 0; i < nbAttack; i +=1) {
      var t = TypeCard.values[parser.extractInt8()];
      if(t != TypeCard.unknown) {
        attack.add(t);
      }
    }
  }

  List<int> toBytes() {
    int idEffect      = title ?? 0;
    List<int> att = [attack.length];
    for (var element in attack) { att.add(element.index); }

    //int 16 = 65k value
    return <int>[ (idEffect & 0xFF00) >> 8,(idEffect & 0xFF)] +
        (description != null ? description!.toBytes() : [0, 0]) +
      [ (power & 0xFF00) >> 8, (power & 0xFF)] + att;
  }
}

class CardEffects {
  List<CardEffect> effects = [];

  static const int version = 1;

  CardEffects();

  CardEffects.fromEffects(this.effects);

  CardEffects.fromBytes(List<int> bytes) {
    if(bytes[0] != version) {
      throw StatitikException('Bad CardEffects version');
    }

    var parser = ByteParser(bytes.sublist(1));
    //var parser = ByteParser(gzip.decode(bytes.sublist(1)));

    int nbEffects = parser.extractInt8();
    for(int i=0; i < nbEffects; i+=1) {
      effects.add(CardEffect.fromBytes(parser));
    }
  }

  void removeUseless() {
    effects.removeWhere((element) {
      return element.title == null && element.description == null;
    });
  }

  List<int> toBytes() {
    List<int> b = [version, effects.length];
    for (var element in effects) {
      b += element.toBytes();
    }
    return b;
  }
}