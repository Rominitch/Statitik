import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:statitik_pokemon/screen/loading.dart';
import 'package:statitik_pokemon/screen/home.dart';
import 'package:statitik_pokemon/services/environment.dart';

class ApplicationWidget extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<bool>.value(
          initialData: false,
          value: Environment.instance.onInitialize.stream,
        ),
      ],
      child: Wrapper(),
    );
  }
}

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    final bool isInitialized = Provider.of<bool>(context);
    if( Environment.instance.isInitialized )
      return Home();
    else
      return Loading();
  }
}
