import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';

import 'connection.dart';

Widget drawImagePress(BuildContext context, String image, double imgHeight) {
  if(Environment.instance.showPressImages) {
    double mediaH = MediaQuery.of(context).size.height;
    double finalH = (mediaH / 1000 * imgHeight).clamp(40.0, imgHeight);
    return CachedNetworkImage(imageUrl: '$adresseHTML/StatitikCard/press/$image.png',
      errorWidget: (context, url, error) => Icon(Icons.help_outline),
      placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
      height: finalH,
    );
  } else {
    return SizedBox();
  }
}

Widget drawImage(BuildContext context, String image, double imgHeight) {
  double mediaH = MediaQuery.of(context).size.height;
  double finalH = (mediaH / 1000 * imgHeight).clamp(40.0, imgHeight);
  return Image(image: AssetImage("assets/"+image), height: finalH);
}

void printOutput(String s) {
  if(!kReleaseMode)
    print(s);
}

