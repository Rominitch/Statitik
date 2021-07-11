import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

import 'connection.dart';


CachedNetworkImage drawCachedImage(folder, image, {double? width, double? height}){
  return CachedNetworkImage(
    imageUrl: '$adresseHTTPS/StatitikCard/$folder/$image.png',
    errorWidget: (context, url, error) {
      if(Environment.instance.user != null && Environment.instance.user!.admin) {
        return Tooltip(
            message: '$adresseHTTPS\r\n$image\r\n$url\r\n$error\r\n',
            child: Icon(Icons.help_outline));
      } else {
        return Icon(Icons.help_outline);
      }
    },
    placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
    width: width,
    height: height,
  );
}


Widget drawImagePress(BuildContext context, String image, double imgHeight) {
  if(Environment.instance.showPressImages) {
    double mediaH = MediaQuery.of(context).size.height;
    double finalH = (mediaH / 1000 * imgHeight).clamp(40.0, imgHeight);
    return drawCachedImage('press', image, height: finalH);
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

Widget drawLoading(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: 40),
      Center(child: Text(StatitikLocale.of(context).read('loading'), style: Theme.of(context).textTheme.headline3)),
      SizedBox(height: 20),
      drawImagePress(context, 'Snorlax', 300),
    ]);
}

Widget drawNothing(BuildContext context, String code) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 40),
        Center(child: Text(StatitikLocale.of(context).read(code), style: Theme.of(context).textTheme.headline3)),
        SizedBox(height: 20),
        drawImagePress(context, 'Arrozard', 300),
      ]);
}
