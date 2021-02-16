import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';

Widget drawImagePress(BuildContext context, String image, double imgHeight) {
  if(Environment.instance.showPressImages) {
    double mediaH = MediaQuery.of(context).size.height;
    double finalH = (mediaH / 1000 * imgHeight).clamp(40.0, imgHeight);
    return Image(image: AssetImage("assets/press/"+image), height: finalH);
  } else {
    return SizedBox();
  }
}

Widget drawImage(BuildContext context, String image, double imgHeight) {
  double mediaH = MediaQuery.of(context).size.height;
  double finalH = (mediaH / 1000 * imgHeight).clamp(40.0, imgHeight);
  return Image(image: AssetImage("assets/"+image), height: finalH);
}
