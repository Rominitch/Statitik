import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';

class ExtensionPage extends StatefulWidget {
  final Language language;
  final Function afterSelected;

  ExtensionPage({ required this.language, required this.afterSelected });

  @override
  _ExtensionPageState createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  List<Widget> buildExts() {
    List<Widget> ext = [];
    for( Extension e in Environment.instance.collection.getExtensions(widget.language))
    {
      List<Widget> subExtensions = [];
      for( SubExtension se in Environment.instance.collection.getSubExtensions(e))
      {
        void Function() press = () {
          widget.afterSelected(context, widget.language, se);
        };
        subExtensions.add(ExtensionButton(subExtension: se, press: press));
      }
      if(subExtensions.isNotEmpty)
      ext.add(Container(
        color: Colors.grey[800],
        padding: EdgeInsets.all(5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(e.name,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5,
              ),
            ),
            GridView.count(
                crossAxisCount: Environment.instance.showExtensionName ? 3 : 5,
                shrinkWrap: true,
                children: subExtensions,
                primary: false,
              ),
          ],
        ),
      ),
      );
    }
    return ext;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ext = buildExts();

    return Container(
        child: Scaffold(
          appBar: AppBar(
            title: Container(
              child: Row(
                children:[
                  Text(StatitikLocale.of(context).read('S_B0')),
                  SizedBox(width: 10.0),
                  widget.language.barIcon(),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(StatitikLocale.of(context).read('EP_B0')),
                  CheckboxListTile(
                    title: Text(StatitikLocale.of(context).read('EP_B1')),
                    value: Environment.instance.showExtensionName,
                    onChanged: (newValue) {
                      setState(() {
                        Environment.instance.toggleShowExtensionName();
                      });
                    },
                  ),
                  Column( children: ext ),
                ],
              )
          ),
        )
    );
  }
}