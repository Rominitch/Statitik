import 'package:flutter/material.dart';

class FilterExtensions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Selection des extensions'),
        ),
        body: SafeArea(
            child:Column(
              children: [
                Row(
                  children: [Card(
                      child: TextButton(
                        child: Text('Extensions'),
                        onPressed: () {

                        },
                      )
                  )
                  ],
                ),
              ],
            )
        )
    );
  }
}
