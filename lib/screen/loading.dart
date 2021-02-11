import 'package:flutter/material.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class Loading extends StatefulWidget {
  Loading() : super()
  {
    // Make long operation
    Environment env = Environment.instance;
    env.initialize();
  }

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool error = false;
  String msgError;

  @override
  void initState() {
    Environment.instance.onServerError.stream.listen((event) {
      setState(() {
        error = true;
        msgError = event;
      });
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Environment env = Environment.instance;
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: drawImage(context, "logo.png", 400.0)),
              Center(
                child: Text(
                    env.nameApp,
                    style: Theme.of(context).textTheme.headline1,
                    ),
                ),
              Center(
                child: Text(
                  env.version,
                ),
              ),
              if(error)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 80.0),
                      Text(StatitikLocale.of(context).read(msgError),
                        style: TextStyle(color: Colors.red)
                      ),
                      SizedBox(height: 10.0),
                      Card(
                        child: FlatButton(
                            child: Text(StatitikLocale.of(context).read('retry')),
                            onPressed:() {
                              setState(() {
                                error=false;
                                Environment.instance.initialize();
                              });
                            }),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}
