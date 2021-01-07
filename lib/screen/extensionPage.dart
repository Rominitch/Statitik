import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/environment.dart';

class ExtensionPage extends StatefulWidget {
  final Language language;
  final Function afterSelected;

  ExtensionPage({ this.language, this.afterSelected });

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
        Function press = () {
          widget.afterSelected(context, widget.language, se);
        };
        subExtensions.add(ExtensionButton(subExtension: se, press: press));
      }
      ext.add(Container(
        color: Colors.grey[800],
        padding: EdgeInsets.all(5.0),
        child: Column(
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
            Container(
              height: 60.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: subExtensions,
              ),
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
    //80% of screen width
    double cWidth = MediaQuery.of(context).size.width;
    List<Widget> ext = buildExts();

    return Container(
        child: Scaffold(
          appBar: AppBar(
            title: Container(
              child: Row(
                children:[
                  Text('Selection d\'une extension'),
                  SizedBox(width: 10.0),
                  widget.language.barIcon(),
                ],
              ),
            ),
          ),
          body: Container(
              padding: const EdgeInsets.all(10.0),
              width: cWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Veuillez choisir l\'extension d\'un booster de votre produit.'),
                  CheckboxListTile(
                    title: Text("Afficher les noms"),
                    value: Environment.instance.showExtensionName,
                    onChanged: (newValue) {
                      setState(() {
                        Environment.instance.toggleShowExtensionName();
                      });
                    },
                  ),
                  ListView( shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: ext ),
                ],
              )
          ),
        )
    );
  }
}