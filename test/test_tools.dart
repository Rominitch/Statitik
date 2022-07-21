import 'package:flutter_test/flutter_test.dart';

void parseDualIterator<T>(Iterator main, Iterator other, Function(T mElement, T oElement) parser) {
  bool parsing = true;
  while(parsing){
    var endMain  = main.moveNext();
    var endOther = other.moveNext();
    parsing = endMain;
    expect(endMain, endOther);
    if(parsing) {
      parser(main.current, other.current);
    }
  }
}

void parseDualArray<T>(List<T> main, List<T> other, Function(T mElement, T oElement) parser) {
  expect(main.length, other.length);
  var itOther = other.iterator;
  for (var element in main) {
    itOther.moveNext();
    parser(element, itOther.current);
  }
}

void parseDualMap<T, T1>(Map<T, T1> main, Map<T, T1> other, Function(T mKey, T1 mElement, T oKey, T1 oElement) parser) {
  expect(main.length, other.length);
  var itOther = other.keys.iterator;
  main.forEach((key, element) {
    itOther.moveNext();
    parser(key, element, itOther.current, other[itOther.current] as T1);
  });
}