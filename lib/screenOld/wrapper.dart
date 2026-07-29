import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:statitikcard/screenOld/loading.dart';
import 'package:statitikcard/screenOld/home.dart';
import 'package:statitikcard/screens/main_home.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';

class ApplicationWidget extends StatefulWidget {
  const ApplicationWidget({super.key});

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
      return const MainHome();// const Home();
    } else {
      return const Loading();
    }
  }
}
