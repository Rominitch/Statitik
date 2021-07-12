import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:statitikcard/screen/commonPages/languagePage.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class NewCardExtensions extends StatefulWidget {
  const NewCardExtensions({Key? key}) : super(key: key);

  @override
  _NewCardExtensionsState createState() => _NewCardExtensionsState();
}

class _NewCardExtensionsState extends State<NewCardExtensions> {
  Language?     _language;
  SubExtension? _se;
  List<Widget>  _cardInfo = [];
  late CustomRadioController energyController = CustomRadioController(onChange: (value) { onTypeChanged(value); });

  void onTypeChanged(value) {

  }

  void afterSelectExtension(BuildContext context, Language language, SubExtension subExt) {
    Navigator.pop(context);
    Navigator.pop(context);
    setState(() {
      // Change selection
      _language = language;
      _se       = subExt;

      _cardInfo = _cards();
    });
  }

  Widget cardCreator() {
    List<Widget> typeCard = [];
    energies.forEach((element) {
      typeCard.add(CustomRadio(value: element, controller: energyController, widget: energyImage(element)));
    });

    return Card(
      child: Column(
        children: [
          GridView.count(
              crossAxisCount: 8,
              primary: false,
              shrinkWrap: true,
              children: typeCard,
          ),

          /*
          Row(children: [
            GridView.count(
              crossAxisCount: 7,
              primary: false,
              shrinkWrap: true,
            )
          ]),
          Row(children: [
            GridView.count(
              crossAxisCount: 3,
              primary: false,
              shrinkWrap: true,
            )
          ]),
          */
        ],
      )
    );
  }

  List<Widget> _cards() {
    List<Widget> myCards = [];
    int id=0;
    _se!.cards!.cards.forEach((card) {
      myCards.add( Padding(
        padding: const EdgeInsets.all(2.0),
        child: TextButton(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row( mainAxisAlignment: MainAxisAlignment.center,
                       children: [card.imageType(),]+card.imageRarity()),
                  Text(_se!.nameCard(id)),
                  ]
            ),
            style: TextButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.all(2.0)
            ),
            onPressed: () {
              int currentId=id;
            },
        ),
      ));
      id +=1;
    });
    return myCards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Text(StatitikLocale.of(context).read('NCE_T0')),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          children: [
            Card(
              child: TextButton(
                child: _language != null ? Row(
                    children: [
                      Text(StatitikLocale.of(context).read('S_B0')),
                      SizedBox(width: 8.0),
                      Image(image: _language!.create(), height: 30),
                      SizedBox(width: 8.0),
                      Tooltip(message: _se!.name,
                          child:_se!.image(hSize: 30)),
                    ]) : Text(StatitikLocale.of(context).read('S_B0')),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LanguagePage(afterSelected: afterSelectExtension)));
                },
              )
            ),
            if(_se != null) cardCreator(),
            if(_se != null && _se!.cards != null) GridView.count(
                primary: false,
                children: _cardInfo,
                shrinkWrap: true,
                crossAxisCount: 5,
            ),
          ],
        )

      )
    );
  }
}
