import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:intl/intl.dart';

import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/screenOld/widgets/image_stored_locally.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

import 'connection.dart';

Color cardMenuColor    = Colors.blueAccent.shade200;
const Color productMenuColor = Colors.deepOrange;
const Color deckMenuColor    = Colors.deepPurpleAccent;

Future<Uri?> _searchValidPath(String path, List<String> webNames) async {
  for( final String image in webNames) {
    final Uri uri = Uri.parse('$path/$image');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return uri;
    }
  }
  return null;
}

Widget drawCachedImage(String folder, String image, {double? width, double? height, alternativeRendering, photoView=false}){
  return drawCachedImages(folder, image, [image], width: width, height: height, alternativeRendering: alternativeRendering, photoView: photoView);
}

Widget drawCachedImages(String folder, String image, List<String> webNames, {double? width, double? height, alternativeRendering, photoView=false}){
  if(Environment.instance.storeImageLocally) {
    List<Uri> webAddress = [];
    for( final webName in webNames) {
      webAddress += [
        Uri.parse("$adresseHTTPS/StatitikCard/$folder/$webName.webp"),
        Uri.parse("$adresseHTTPS/StatitikCard/$folder/$webName.png")
      ];
    }

    return ImageStoredLocally(["images", folder], image, webAddress,
      width: width,
      height: height,
      alternativeRendering : alternativeRendering,
      photoView: photoView
    );
  } else {
    return FutureBuilder<Uri?>(
      future: _searchValidPath('$adresseHTTPS/StatitikCard/$folder', webNames),
      builder: (BuildContext context, AsyncSnapshot<Uri?> snapshot) {
        if(snapshot.connectionState == ConnectionState.done
           && snapshot.hasData && snapshot.data != null) {
          return CachedNetworkImage(
            imageUrl: snapshot.data!.toString(),
            errorWidget: (context, url, error) {
              if(Environment.instance.isAdministrator()) {
                return Tooltip(
                    message: '$adresseHTTPS\r\n$image\r\n$url\r\n$error\r\n',
                    child: alternativeRendering ?? const Icon(Icons.help_outline));
              } else {
                return alternativeRendering ?? const Icon(Icons.help_outline);
              }
            },
            placeholder: (context, url) => CircularProgressIndicator(color: Colors.orange[300]),
            width: width,
            height: height,
          );
        } else {
          return CircularProgressIndicator(color: Colors.orange[300]);
        }
      }
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
              style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          drawImagePress(context, 'zorua', 300),
          const SizedBox(height: 30),
          Center(child: Text(sprintf(StatitikLocale.of(context).read('SEC_1'), [DateFormat.yMMMMd(StatitikLocale.of(context).locale.toLanguageTag()).format(se.out)]),
            style: Theme.of(context).textTheme.headlineSmall),
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
    return const SizedBox();
  }
}

Widget drawImage(BuildContext context, String image, double imgHeight) {
  double mediaH = MediaQuery.of(context).size.height;
  double finalH = (mediaH / 1000 * imgHeight).clamp(40.0, imgHeight);
  return Image(image: AssetImage("assets/$image"), height: finalH);
}

void printOutputError(String s) {
  if (kDebugMode) {
    print("\x1B[31m📕 $s\x1B[0m");
  }
}

void printOutput(String s) {
  if (kDebugMode) {
    print(s);
  }
}

Widget drawLoading(BuildContext context) {
  return MovingImageWidget( Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 40),
      Center(child: Text(StatitikLocale.of(context).read('loading'), style: Theme.of(context).textTheme.displaySmall)),
      const SizedBox(height: 20),
      drawImagePress(context, 'Snorlax', 300),
    ]));
}

Widget drawNothing(BuildContext context, String code) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(child: Text(StatitikLocale.of(context).read(code), style: Theme.of(context).textTheme.displaySmall)),
        const SizedBox(height: 20),
        drawImagePress(context, 'Arrozard', 300),
      ]);
}

bool mask(int value, int mask) {
  return (value & mask) == mask;
}

int setMask(int data, int value, int mask) {
  return (data & ~mask) | (value & mask);
}