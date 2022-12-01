import 'package:flutter/material.dart';

class Language
{
  int id;
  String image;

  Language({required this.id, required this.image});

  AssetImage create()
  {
    return AssetImage('assets/langue/$image.png');
  }

  Image barIcon([double? newHeight]) {
    return Image(
      image: create(),
      height: newHeight ?? AppBar().preferredSize.height * 0.4,
    );
  }

  bool isWorld() {
    return id != 3;
  }

  bool isJapanese() {
    return id == 3;
  }
}