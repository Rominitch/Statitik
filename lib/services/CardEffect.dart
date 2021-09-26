import 'package:flutter/material.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

import 'Tools.dart';

class DecryptedString {
  List<String>  finalString = [];
  List<dynamic> itemsInside = [];
  //Map<int, dynamic> itemsInside = {};
}

class CardDescription {
  int   idDescription;
  List  parameters = []; ///< List of parameter to substitute

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

  List<int> toBytes() {
    List<int> bytes = <int>[
      (idDescription & 0xFF00) >> 8, idDescription & 0xFF,
      parameters.length
    ];
    parameters.forEach((element) {
      bytes.add((element & 0xFF00) >> 8);
      bytes.add(element & 0xFF);
    });
    return bytes;
  }

  Widget toWidget(Map descriptionCollection, Language l)
  {
    var current = decrypted(descriptionCollection, l);
    List<InlineSpan> children = [];

    int idParameters = 0;
    RegExp regExp = RegExp("%[dsf]");
    var itString = current.finalString.iterator;
    var itIcon   = current.itemsInside.iterator;

    while(itString.moveNext()) {
      int nbParameters = regExp.allMatches(itString.current).length;

      children.add(TextSpan(text: sprintf(itString.current, parameters.sublist(idParameters, idParameters+nbParameters))));
      idParameters += nbParameters;
      if(itIcon.moveNext()) {
        children.add(WidgetSpan(child: itIcon.current));
      }
    }
    // Create final text
    return RichText(text: TextSpan(children: children) );
  }

  DecryptedString decrypted(Map descriptionCollection, Language l) {
    DecryptedString s = DecryptedString();

    // Combine and extract info
    RegExp exp = RegExp(r"(.*?)<(.*?:.*?)>(.*)");

    s.finalString.add("");
    int count=0;
    String toAnalyze = descriptionCollection[idDescription].name(l);
    while(toAnalyze.isNotEmpty) {
      var match = exp.firstMatch(toAnalyze);
      if( match != null ) {
          toAnalyze = "";
          s.finalString.last += match.group(1)!;
          var code = match.group(2)!.split(":");
          assert(code.length==2);
          if( code[0] == "D" ) {
            toAnalyze += descriptionCollection[int.parse(code[1])].name(l);
          } else if( code[0] == "E" ) {
            s.itemsInside.add(getImageType(Type.values[int.parse(code[1])]));
            s.finalString.add("");
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

  int         power  = 0;   /// Zero = no attack.
  List<Type>  attack = [];  /// Energy to attach for attack.

  CardEffect();
  CardEffect.fromBytes(ByteParser parser) {
    int idEffect = parser.extractInt16();
    if(idEffect != 0)
        title = idEffect;

    var newDescription = CardDescription.fromBytes(parser);
    if(newDescription.idDescription > 0)
      description = newDescription;

    power = parser.extractInt16();

    int nbAttack = parser.extractInt8();
    for(int i = 0; i < nbAttack; i +=1) {
      attack.add(Type.values[parser.extractInt8()]);
    }
  }

  List<int> toBytes() {
    int idEffect      = title ?? 0;
    List<int> att = [attack.length];
    attack.forEach((element) { att.add(element.index); });

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
    if(bytes[0] != version)
      throw StatitikException('Bad CardEffects version');

    var parser = ByteParser(bytes.sublist(1));
    //var parser = ByteParser(gzip.decode(bytes.sublist(1)));

    int nbEffects = parser.extractInt8();
    for(int i=0; i < nbEffects; i+=1) {
      effects.add(CardEffect.fromBytes(parser));
    }
  }

  List<int> toBytes() {
    List<int> b = [version, effects.length];
    effects.forEach((element) {
      b += element.toBytes();
    });

    printOutput("CardEffects: data: ${b.length}");
    return b;

    // Don't use compression -> No gain in place
    /*
    List<int> b = [effects.length];
    effects.forEach((element) {
      b += element.toBytes();
    });

    List<int> finalBytes = [version];
    finalBytes += gzip.encode(b);

    printOutput("CardEffects: data: ${b.length+1} compressed: ${finalBytes.length}");

    return finalBytes;
    */
  }
}