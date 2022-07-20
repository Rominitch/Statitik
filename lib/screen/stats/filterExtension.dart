import 'package:flutter/material.dart';

class FilterExtensions extends StatelessWidget {
  const FilterExtensions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Selection des extensions'),
        ),
        body: SafeArea(
            child:Column(
              children: [
                Row(
                  children: [Card(
                      child: TextButton(
                        child: const Text('Extensions'),
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
