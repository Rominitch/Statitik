import 'package:statitikcard/services/models/language.dart';

class MultiLanguageString {
  final List<String> _names;

  MultiLanguageString(this._names){
    assert(_names.length == 3, "MultiLanguageString Error: $_names");
  }

  String defaultName([String separator='\n']) {
    return _names.join(separator);
  }

  String name(LanguageOld l) {
    assert(0 <= l.id-1 && l.id-1 < _names.length);
    return _names[l.id-1];
  }

  void editName(String value, LanguageOld l) {
    assert(0 <= l.id-1 && l.id-1 < _names.length);
    _names[l.id-1] = value;
  }

  bool search(LanguageOld? l, String searchPart) {
    if(l != null) {
      return name(l).toLowerCase().contains(searchPart.toLowerCase());
    } else {
      for( var name in _names) {
        if( name.toLowerCase().contains(searchPart.toLowerCase())) {
          return true;
        }
      }
      return false;
    }
  }

  List<String> names() { return _names; }
}