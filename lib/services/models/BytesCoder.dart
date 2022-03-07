class ByteEncoder
{
  static List<int> encodeInt32(int value) {
    return <int>[
      (value & 0xFF000000) >> 24,
      (value & 0xFF0000) >> 16,
      (value & 0xFF00) >> 8,
      (value & 0xFF)
    ];
  }

  static List<int> encodeInt8(int value) {
    assert(value < 256);
    return <int>[
      (value & 0xFF)
    ];
  }

  static List<int> encodeInt16(int value) {
    assert(value < 65536);
    return <int>[
      (value & 0xFF00) >> 8,
      (value & 0xFF)
    ];
  }

  static List<int> encodeString16(List<int> stringInfo) {
    assert(stringInfo.length * 2 <= 255);
    var imageCode = <int>[
      stringInfo.length * 2, // Not more than 256
    ];
    stringInfo.forEach((element) {
      assert(element < 65536);
      imageCode += ByteEncoder.encodeInt16(element);
    });
    assert(imageCode[0] == imageCode.length-1);
    return imageCode;
  }

  static List<int> encodeBytesArray(List<int> byteArray) {
    assert(byteArray.length < 65536);
    return encodeInt16(byteArray.length) + byteArray;
  }

  static List<int> encodeBool(bool value) {
    return <int>[value ? 1 : 0];
  }
}

class ByteParser
{
  List<int> byteArray;
  Iterator<int>  it;
  late bool canParse;

  ByteParser(this.byteArray) : it = byteArray.iterator {
    canParse = it.moveNext();
  }

  String decodeString16() {
    List<int> charCodes = [];
    int length = extractInt8();
    assert(length % 2 == 0);
    for(int i = 0; i < length/2; i +=1) {
      charCodes.add(extractInt16());
    }
    return String.fromCharCodes(charCodes);
  }

  int extractInt32() {
    int v = it.current << 24;
    canParse = it.moveNext();
    v |= it.current << 16;
    canParse = it.moveNext();
    v |= it.current << 8;
    canParse = it.moveNext();
    v |= it.current;
    canParse = it.moveNext();
    return v;
  }
  int extractInt16() {
    int v = it.current << 8;
    canParse = it.moveNext();
    v |= it.current;
    canParse = it.moveNext();
    return v;
  }
  int extractInt8() {
    int v = it.current;
    canParse = it.moveNext();
    return v;
  }

  bool extractBool() {
    int v = it.current;
    canParse = it.moveNext();
    return v != 0;
  }

  List<int> extractBytesArray() {
    int nbItems = extractInt16();
    List<int> extract = [];
    for(int i = 0 ; i < nbItems; i +=1) {
      extract.add(extractInt8());
    }
    return extract;
  }
}