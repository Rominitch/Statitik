import 'package:flutter/material.dart';

import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/screen/widgets/ButtonCheck.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/Extension.dart';
import 'package:statitikcard/services/models/Language.dart';
import 'package:statitikcard/services/models/SerieType.dart';
import 'package:statitikcard/services/models/SubExtension.dart';

class ExtensionPage extends StatefulWidget {
  final Language language;
  final Function afterSelected;
  final bool     addMode;

  ExtensionPage({ required this.language, required this.afterSelected, required this.addMode });

  @override
  _ExtensionPageState createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  late List<SerieType> serieFilters;
  late CustomButtonCheckController refreshController = CustomButtonCheckController(refresh);

  @override
  void initState() {
    super.initState();
    serieFilters = widget.addMode ? [SerieType.Normal] : [SerieType.Normal, SerieType.Promo, SerieType.Deck];
  }

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
        if( serieFilters.contains(se.type) ) {
          void Function() press = () {
            widget.afterSelected(context, widget.language, se);
          };
          subExtensions.add(ExtensionButton(subExtension: se, press: press));
        }
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
    List<Widget> filters = [];
    if(!widget.addMode) {
      SerieType.values.forEach((element) {
        filters.add(
          Expanded(child: SerieTypeButtonCheck(serieFilters, element, controller: refreshController))
        );
      });
    }
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
        )
    );
  }
}