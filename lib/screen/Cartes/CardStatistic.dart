import 'package:flutter/material.dart';

import 'package:statitikcard/screen/Cartes/CardFilterSelector.dart';
import 'package:statitikcard/screen/Cartes/CardNameSelector.dart';
import 'package:statitikcard/screen/Cartes/statsCard.dart';
import 'package:statitikcard/screen/widgets/CustomRadio.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';
import 'package:statitikcard/services/pokemonCard.dart';

class CardStatisticPage extends StatefulWidget {
  const CardStatisticPage({Key? key}) : super(key: key);

  @override
  _CardStatisticPageState createState() => _CardStatisticPageState();
}

class _CardStatisticPageState extends State<CardStatisticPage> {
  late CustomRadioController langueController = CustomRadioController(onChange: (Language value) { onLanguageChanged(value); });
  CardResults  _cardResults = CardResults();
  List<Widget> _languages = [];

  void onLanguageChanged(Language value) {
    setState(() {
      afterDataFilled();
    });
  }

  @override
  void initState() {
    super.initState();

    langueController.currentValue = Environment.instance.collection.languages.values.first;
    Environment.instance.collection.languages.values.forEach((element) {
        _languages.add(CustomRadio(value: element, controller: langueController, widget: element.barIcon()));
    });

    afterDataFilled();
  }

  void afterDataFilled() {
    _cardResults.stats = null;
    computeStats().then((value) {
      setState(() {
        _cardResults.stats = value;
      });
    }).whenComplete(() => setState(() {}));
  }

  Future<CardStats> computeStats() async {
    CardStats stats = CardStats();

    assert(langueController.currentValue != null);

    Environment.instance.collection.getExtensions(langueController.currentValue).forEach((ext) {
      Environment.instance.collection.getSubExtensions(ext).forEach((SubExtension subExt) {
        if( subExt.seCards.isValid ) {
          int id=1;
          subExt.seCards.cards.forEach((List<PokemonCardExtension> cards) {
            cards.forEach((singleCard) {
              if( _cardResults.isSelected(singleCard) ) {
                stats.add(subExt, singleCard, id);
              }
              id += 1;
            });
          });
        }
       });
    });
    return stats;
  }

  Widget computeStatsGUI(BuildContext context) {
    if (_cardResults.hasStats()) {
      if (_cardResults.stats!.hasData()) {
        assert(langueController.currentValue != null);
        return Card(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatsCard(langueController.currentValue, this._cardResults))
               );
      } else {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: drawNothing(context, 'S_B1'),
        );
      }
    } else {
      return drawLoading(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text( StatitikLocale.of(context).read('CA_T0'), style: Theme.of(context).textTheme.headline3, ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: _languages,
            ),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: TextButton(
                      onPressed: () {
                        _cardResults.specificCard = null;
                        _cardResults.stats        = null;

                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CardNameSelector(langueController.currentValue)),
                          ).then((value) {
                            _cardResults.specificCard = value;
                            afterDataFilled();
                          });
                        });
                      },
                      child: Text( _cardResults.specificCard != null ? _cardResults.specificCard!.name(langueController.currentValue) : StatitikLocale.of(context).read('CA_B3')),
                    ),
                  ),
                ),
                Card(
                  color: _cardResults.isFiltered() ? Colors.green : Colors.grey[700],
                  child: TextButton(
                    onPressed: () {
                      _cardResults.stats = null;
                      setState(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CardFilterSelector(langueController.currentValue, _cardResults)),
                        ).then((value) {
                          setState(() {
                            afterDataFilled();
                          });
                        });
                      });
                    },
                    child: Text(StatitikLocale.of(context).read('CA_B4')),
                  ),
                ),
              ],
            ),
            computeStatsGUI(context)
          ],
        )
      )
    );
  }
}
