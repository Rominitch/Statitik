import 'package:flutter/foundation.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class NewCardReport {
  List<int>   idCard;
  CodeDraw    state;

  NewCardReport(this.idCard, this.state);
}

class NewCardsReport {
  Map<SubExtension, List<NewCardReport>> result = {};

  void add(SubExtension subExtension, NewCardReport code) {
    if( !result.containsKey(subExtension) ){
      result[subExtension] = [];
    }
    var list = result[subExtension]!;

    // Search for merge
    bool find=false;
    for(int id=0; id < list.length; id +=1) {
      if( listEquals(list[id].idCard, code.idCard) ) {
        list[id].state.add(code.state);

        find=true;
        break;
      }
    }

    // else Add new
    if(!find)
      result[subExtension]!.add(code);
  }
}