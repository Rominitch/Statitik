import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:screenshot/screenshot.dart';
import 'package:statitikcard/services/internationalization.dart';

class ScreenPrint
 {
   ScreenshotController screenshotController = ScreenshotController();

   void shareReport(BuildContext context, String extIcon) {
     // Demand to write on device
     [ Permission.storage,
     ].request().then( (Map<Permission, PermissionStatus> statuses) async {
       // If accepted
       if( statuses[Permission.storage]!.isGranted ) {
         screenshotController
             .capture()
             .then((Uint8List? image) async {
           final myImagePath = (await getApplicationSupportDirectory()).path;

           var now = DateTime.now();
           final title = 'Statitik_${extIcon}_${DateFormat(
               'yyyyMMdd_kk_mm').format(now)}';
           var file = File("$myImagePath/$title.png");
           file.writeAsBytesSync(image!);

           PermissionState result = await PhotoManager.requestPermissionExtend();
           if (result == PermissionState.authorized || result == PermissionState.limited) {
             await PhotoManager.editor.saveImageWithPath(
                 file.path, title: title);

             showDialog(
                 context: context,
                 builder: (_) =>
                 AlertDialog(
                   title: Text(StatitikLocale.of(context).read('RE_B1')),
                   content: Text(StatitikLocale.of(context).read('RE_B2')),
                 )
             );
           }
         });
       }
     });
   }
 }