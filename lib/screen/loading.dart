import 'package:flutter/material.dart';
import 'package:statitikcard/services/environment.dart';

class Loading extends StatelessWidget {

  Loading() : super()
  {
    // Make long operation
    Environment env = Environment.instance;
    env.initialize();
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
            ],
          ),
        ),
      )
    );
  }
}
