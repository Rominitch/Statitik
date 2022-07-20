import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool error = false;
  late String msgError;
  String? loadingInfo;

  @override
  void initState() {
    super.initState();

    // Connect to end loading
    Environment.instance.onServerError.stream.listen((event) {
      setState(() {
        error = true;
        msgError = event;
      });
    });

    // Connect to info loading
    Environment.instance.onInfoLoading.stream.listen((codeMsg) {
      setState(() {
        loadingInfo = codeMsg;
      });
    });

    // Initialize engine (async and long operation)
    Environment.instance.initialize();
  }
  @override
  void dispose() {
    Environment.instance.onInfoLoading.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Environment env = Environment.instance;
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.lightBlue[800]!,
                  Colors.green[900]!,
                ],
              )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MovingImageWidget( drawImage(context, "logo.png", 400.0) ),
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
                      const SizedBox(height: 80.0),
                      Card(
                        color: Colors.red[700],
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(StatitikLocale.of(context).read(msgError),
                            style: const TextStyle(color: Colors.white)
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Card(
                        child: TextButton(
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
                )
              else if(loadingInfo != null)
                Center(
                  child: Text(StatitikLocale.of(context).read(loadingInfo!),
                        style: Theme.of(context).textTheme.headline5,
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}
