import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/ImageStoredLocally.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

import 'connection.dart';

Widget drawCachedImage(folder, image, {double? width, double? height, alternativeRendering}){
  if(Environment.instance.storeImageLocally) {
    return ImageStoredLocally(["images", folder], '$image',
      [Uri.parse('$adresseHTTPS/StatitikCard/$folder/$image.png')],
      width: width,
      height: height,
      alternativeRendering : alternativeRendering
    );
  } else {
    return CachedNetworkImage(
      imageUrl: '$adresseHTTPS/StatitikCard/$folder/$image',
      errorWidget: (context, url, error) {
        if(Environment.instance.isAdministrator()) {
          return Tooltip(
              message: '$adresseHTTPS\r\n$image\r\n$url\r\n$error\r\n',
              child: alternativeRendering ?? Icon(Icons.help_outline));
        } else {
          return alternativeRendering ?? Icon(Icons.help_outline);
        }
      },
      placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
      width: width,
      height: height,
    );
  }
}

Widget drawOut(BuildContext context, SubExtension se) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(sprintf(StatitikLocale.of(context).read('SEC_0'), [DateFormat.yMMMMd(StatitikLocale.of(context).locale.toLanguageTag()).format(se.out)]),
              style: Theme.of(context).textTheme.headline3, textAlign: TextAlign.center),
          SizedBox(height: 30),
          drawImagePress(context, 'zorua', 300),
          SizedBox(height: 30),
          Center(child: Text(sprintf(StatitikLocale.of(context).read('SEC_1'), [DateFormat.yMMMMd(StatitikLocale.of(context).locale.toLanguageTag()).format(se.out)]),
            style: Theme.of(context).textTheme.headline5),
          ),
      ]),
    ),
  );
}

Widget drawImagePress(BuildContext context, String image, double imgHeight) {
  if(Environment.instance.showPressImages) {
    double mediaH = MediaQuery.of(context).size.height;
    double finalH = (mediaH / 1000 * imgHeight).clamp(30.0, imgHeight);
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
  return MovingImageWidget( Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: 40),
      Center(child: Text(StatitikLocale.of(context).read('loading'), style: Theme.of(context).textTheme.headline3)),
      SizedBox(height: 20),
      drawImagePress(context, 'Snorlax', 300),
    ]));
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

bool mask(int value, int mask) {
  return value & mask == mask;
}