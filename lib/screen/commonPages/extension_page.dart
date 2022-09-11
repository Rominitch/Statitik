import 'package:flutter/material.dart';

import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/button_check.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/extension.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/serie_type.dart';
import 'package:statitikcard/services/models/sub_extension.dart';

class ExtensionPage extends StatefulWidget {
  final Language language;
  final Function afterSelected;
  final bool     addMode;

  const ExtensionPage({ required this.language, required this.afterSelected, required this.addMode, Key? key}) : super(key: key);

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  late List<SerieType> series = widget.addMode ? [SerieType.normal] : [SerieType.normal, SerieType.promo, SerieType.deck];
  late CustomButtonCheckController refreshController = CustomButtonCheckController(refresh);

  void refresh() {
    setState(() {

    });
  }

  List<Widget> buildExts() {
    List<Widget> ext = [];
    for( Extension e in Environment.instance.collection.getExtensions(widget.language))
    {
      List<Widget> subExtensions = [];
      for( SubExtension se in Environment.instance.collection.getSubExtensions(e))
      {
        if( series.contains(se.type) ) {
          press() {
            widget.afterSelected(context, widget.language, se);
          }
          subExtensions.add(ExtensionButton(subExtension: se, press: press));
        }
      }
      if(subExtensions.isNotEmpty) {
        ext.add(Container(
          color: Colors.grey[800],
          padding: const EdgeInsets.all(5.0),
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
                  primary: false,
                  children: subExtensions,
                ),
              ],
            ),
          ),
        );
      }
    }
    return ext;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> filters = [];
    if(!widget.addMode) {
      for (var element in SerieType.values) {
        filters.add(
          Expanded(child: SerieTypeButtonCheck(series, element, controller: refreshController))
        );
      }
    }
    List<Widget> ext = buildExts();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children:[
            Text(StatitikLocale.of(context).read('S_B0')),
            const SizedBox(width: 10.0),
            widget.language.barIcon(),
          ],
        ),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widget.addMode ? Text(StatitikLocale.of(context).read('EP_B0'))
              : Row( children: filters,
              ),
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
    );
  }
}