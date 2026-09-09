import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:statitikcard/screenOld/widgets/image_stored_locally.dart';
import 'package:statitikcard/services/connection.dart';

class ImageWithCache extends StatefulWidget {
  final String folder;
  final List<Uri> webAddress;
  final double? width;
  final double? height;
  final Widget? alternativeRendering;
  final bool photoView;

  const ImageWithCache(this.folder, this.webAddress, {this.width, this.height, this.alternativeRendering, this.photoView=false, super.key});

  static ImageWithCache generator(String folder, List<String> webNames, {required Widget alternativeRendering, double? height}) {
    assert(webNames.isNotEmpty);
    List<Uri> webAddress = [];
    for( final webName in webNames) {
      webAddress += [
        Uri.parse("$adresseHTTPS/StatitikCard/$folder/$webName.webp"),
        Uri.parse("$adresseHTTPS/StatitikCard/$folder/$webName.png")
      ];
    }
    return ImageWithCache(folder, webAddress,
        alternativeRendering: alternativeRendering,
        height: height);
  }

  @override
  State<ImageWithCache> createState() => _ImageWithCacheState();
}

class _ImageWithCacheState extends State<ImageWithCache> {
  @override
  Widget build(BuildContext context) {
    return ImageStoredLocally(["images", widget.folder], path.basename(widget.webAddress.first.toString()), widget.webAddress,
        width: widget.width,
        height: widget.height,
        alternativeRendering : widget.alternativeRendering,
        photoView: widget.photoView
    );
  }
  /*
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
  }*/
}

