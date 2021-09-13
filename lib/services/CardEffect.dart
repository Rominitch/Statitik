
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class DecryptedString {
  List<String>  finalString = [];
  List<dynamic> itemsInside = [];
  //Map<int, dynamic> itemsInside = {};
}

class CardDescription {
  int   idDescription;
  List  parameters = []; ///< List of parameter to substitute

  CardDescription(this.idDescription);

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

  List<Type>  attack = [];  /// Energy to attach for attack.
  int         power  = 0;   /// Zero = no attack.

  static const int version = 1;

  CardEffect();
  CardEffect.fromByte(this.title, List<int> bytes) {
    if( bytes[0] != version) {
      throw StatitikException("Bad CardEffect version");
    }


  }
}