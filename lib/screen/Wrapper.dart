import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/screen/loading.dart';
import 'package:statitikcard/screen/home.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';

class ApplicationWidget extends StatefulWidget {
  const ApplicationWidget({Key? key}) : super(key: key);

  @override
  State<ApplicationWidget> createState() => _ApplicationWidgetState();
}

class _ApplicationWidgetState extends State<ApplicationWidget> {
  @override
  void initState() {
    Environment.instance.onInitialize.stream.listen((event) {
      setState(() {

      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EasyLoading.instance
      .indicatorWidget = drawLoading(context);
    
    if( Environment.instance.isInitialized ) {
      return Home();
    } else {
      return Loading();
    }
  }
}
