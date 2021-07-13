import 'package:flutter/material.dart';
import 'package:statitikcard/screen/loading.dart';
import 'package:statitikcard/screen/home.dart';
import 'package:statitikcard/services/environment.dart';

class ApplicationWidget extends StatefulWidget {
  // This widget is the root of your application.

  @override
  _ApplicationWidgetState createState() => _ApplicationWidgetState();
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
    if( Environment.instance.isInitialized ) {
      return Home();
    } else {
      return Loading();
    }
  }
}
