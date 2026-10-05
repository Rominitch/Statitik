import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_language.dart';

class WidgetAdminCardButton extends StatefulWidget {
  final PokeNavAdmin  _nav;
  final PokeCardViewerIdentifier  _cvi;
  final Function(PokeCardIdentifier) _onAddCard;
  final Function(PokeCardIdentifier) _onSelectCard;
  final Function(PokeCardIdentifier) _onRemoveCard;

  const WidgetAdminCardButton(this._nav, this._cvi, this._onAddCard, this._onSelectCard, this._onRemoveCard, {super.key});

  @override
  State<WidgetAdminCardButton> createState() => _WidgetAdminCardButtonState();
}

class _WidgetAdminCardButtonState extends State<WidgetAdminCardButton> {
  @override
  Widget build(BuildContext context) {
    final isJapanese = widget._cvi.expansion.location() == CardLocation.Asie;
    final card = widget._cvi.cardInExp();

    // Search if Jap Card link exist
    var colorCard = const Color(0xFF5D9070);

    if( widget._nav.collection.containsCard(card.card) ) {
      var subEx = widget._nav.collection
          .searchCardIntoAllSubExtension(card.card);
      int count = 0;
      for (final element in subEx) {
        if (element.expansion.location() == CardLocation.Asie) {
          count += 1;
        }
      }

      if( isJapanese ) {
        // Show multi link
        colorCard = count > 1 ? Colors.cyan : Colors.green[900]!;
      } else {
        // Show link with japan
        colorCard = count > 0 ? Colors.green[800]! : Colors.grey[900]!;
      }
    } else  {
      colorCard = Colors.grey[800]!;
    }

    var numberCard = widget._cvi.expansion.cards.numberOfCard(widget._cvi.idCard.numberId);

    bool hasJPImageLink = false;
    if( isJapanese ) {
      final imageId = PokeCardImageIdentifier(card.setInfo.keys.first);
      final cardDesign = card.tryGetImage(imageId);
      if(cardDesign != null) {
        hasJPImageLink = cardDesign.jpDBId != 0 || cardDesign.finalImage.isNotEmpty;
      }
    }
    return Card(
      color: colorCard,
      child: TextButton(
        onLongPress: () {
          setState(() {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                      title: Center(child: Text(AppLocalizations.of(context)!.nce_b3, style: Theme.of(context).textTheme.displaySmall)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                      children: [
                        Card(
                            color: Colors.grey[700],
                            child: TextButton(
                              child: Text(AppLocalizations.of(context)!.nce_b4),
                              onPressed: () {
                                setState(() {
                                  widget._onAddCard(widget._cvi.idCard);
                                  Navigator.of(context).pop();
                                });
                              },
                            )
                        ),
                        Card(
                            color: Colors.red,
                            child: TextButton(
                              child: Text(AppLocalizations.of(context)!.nce_b5),
                              onPressed: () {
                                setState(() {
                                  widget._onRemoveCard(widget._cvi.idCard);
                                  Navigator.of(context).pop();
                                });
                              },
                            )
                        ),
                      ]
                  );
                }
            );
          });
        },
        onPressed: () {
          setState(() {
            widget._onSelectCard(widget._cvi.idCard);
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row( mainAxisAlignment: MainAxisAlignment.center,
              children: [card.imageType()] + widget._nav.rendering.imageRarity(card.rarity)),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(numberCard, style: TextStyle(fontSize: numberCard.length > 3 ? 10 : 12)),
                if(isJapanese && !hasJPImageLink) const Icon(Icons.broken_image, color: Colors.deepOrange, size: 11),
                if(card.card.missingMainData())           const Icon(Icons.text_format, color: Colors.red, size: 10),
                if(card.card.cardEffects.effects.isEmpty) const Icon(Icons.filter_vintage_outlined, color: Colors.red, size: 10),
              ])
          ]
        ),
      ),
    );

  }
}
