
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/models.dart';

class DecryptedString {
  String  finalString = "";
  Map<int, dynamic> itemsInside = {};
}

class CardDescription {
  int   idDescription;
  List  parameters = []; ///< List of parameter to substitute

  CardDescription(this.idDescription);

  Widget toWidget(Map descriptionCollection, Language l)
  {
    String current = descriptionCollection[idDescription].name(l);

    // Create final text
    return RichText(text:
      TextSpan(text: sprintf(current, parameters))
    );
/*
    TextSpan(
      text: "Click ",
    ),
    WidgetSpan(
    child: Icon(Icons.add, size: 14),
    ),
*/
  }

  DecryptedString decrypted(Map descriptionCollection, Language l) {
    DecryptedString s = DecryptedString();

    // Combine and extract info
    RegExp exp = RegExp(r"(.*)<(.*:.*)>(.*)");

    int count=0;
    String toAnalyze = descriptionCollection[idDescription].name(l);
    while(toAnalyze.isNotEmpty) {
      var match = exp.firstMatch(toAnalyze);
      if( match != null ) {
          s.finalString += match.group(1)!;

          var code = match.group(2)!.split(":");
          assert(code.length==2);
          toAnalyze = "";
          if( code[0] == "D" ) {
            toAnalyze += descriptionCollection[int.parse(code[1])].name(l);
          } else {
            throw StatitikException("Error of code");
          }
          toAnalyze += match.group(3)!;
      } else {
        s.finalString += toAnalyze;
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