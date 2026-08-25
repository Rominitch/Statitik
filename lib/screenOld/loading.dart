import 'package:flutter/material.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/screenOld/view.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  bool error = false;
  ErrorCode? errorInfo;
  double progression = -1.0;
  LoadingCode? loadingInfo;

  @override
  void initState() {
    super.initState();

    // Connect to end loading
    Environment.instance.onServerError.stream.listen((event) {
      setState(() {
        error = true;
        errorInfo = event;
      });
    });

    // Connect to info loading
    Environment.instance.onInfoLoading.stream.listen((codeMsg) {
      setState(() {
        loadingInfo = codeMsg;
      });
    });

    Environment.instance.onProgression.stream.listen((event) {
      setState(() {
        progression = event;
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

  String codeError(BuildContext context) {
    if(errorInfo == null) {
      return "";
    }
    switch(errorInfo!) {
      case ErrorCode.unknown: return AppLocalizations.of(context)!.error;
      case ErrorCode.db_0: return AppLocalizations.of(context)!.db_0;
      case ErrorCode.db_1: return AppLocalizations.of(context)!.db_1;
      case ErrorCode.userBan: return AppLocalizations.of(context)!.error;
      case ErrorCode.unknownFile: return AppLocalizations.of(context)!.error;
    }
  }

  String loading(BuildContext context) {
    switch(loadingInfo!) {
      case LoadingCode.load_0: return AppLocalizations.of(context)!.load_0;
      case LoadingCode.load_1: return AppLocalizations.of(context)!.load_1;
      case LoadingCode.load_2: return AppLocalizations.of(context)!.load_2;
      case LoadingCode.load_3: return AppLocalizations.of(context)!.load_3;
      case LoadingCode.load_4: return AppLocalizations.of(context)!.load_4;
    }
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
                    style: Theme.of(context).textTheme.displayLarge,
                    ),
                ),
              Center(
                child: Text(
                  env.version,
                ),
              ),
              if(progression > -1.0)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LinearProgressIndicator(value: progression),
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
                          child: Text(codeError(context),
                            style: const TextStyle(color: Colors.white)
                          ),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Card(
                        child: TextButton(
                            child: Text(AppLocalizations.of(context)!.retry),
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
                  child: Text(loading(context),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
            ],
          ),
        ),
      )
    );
  }
}
