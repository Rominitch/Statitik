import 'package:flutter/foundation.dart';
import 'package:statitikcard/services/Draw/cardDrawData.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class NewCardReport {
  List<int>   idCard;
  CodeDraw    state;

  NewCardReport(this.idCard, this.state);

  int compareTo(NewCardReport other) {
    var itOther = other.idCard.iterator;
    for(var element in idCard) {
      if(itOther.moveNext()) {
        var cmp = element.compareTo(itOther.current);
        if(cmp != 0)
          return cmp;
      }
    }
    return 0;
  }
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

  void sort() {
    result.forEach((key, list) {
      list.sort((a, b) => a.compareTo(b));
    });
  }
}