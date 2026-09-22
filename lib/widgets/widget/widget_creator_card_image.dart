
import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card_design.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/services/environment.dart';

class WidgetCreatorCardImage extends StatefulWidget {
  final PokeNavAdmin             _navAdmin;
  final PokeCardViewerIdentifier _cardId;

  const WidgetCreatorCardImage(this._navAdmin, this._cardId, {super.key});

  @override
  State<WidgetCreatorCardImage> createState() => _CardImageCreatorState();
}

class _CardImageCreatorState extends State<WidgetCreatorCardImage> {
  late CustomRadioController designController = CustomRadioController(onChange: (value) { onDesignChanged(value); });
  late CustomRadioController artController    = CustomRadioController(onChange: (value) { onArtChanged(value); });
  final imageController     = TextEditingController();
  final jpCodeController    = TextEditingController();


  PokeCardDesign currentDesign() {
    return widget._cardId.cardInExp().image(widget._cardId.idImage!)!;
  }

  void onDesignChanged(PokeDesign selectedDesign) {
    final oldDesign = currentDesign();
    final design = PokeCardDesign(selectedDesign, oldDesign.art);
    design.cardImage = oldDesign.cardImage;
    design.jpDBId    = oldDesign.jpDBId;
    design.finalImage= oldDesign.finalImage;

    widget._cardId.cardInExp().setImage(widget._cardId.idImage!, design);
  }

  void onArtChanged( ArtFormat newArt ) {
    final oldDesign = currentDesign();
    final design = PokeCardDesign(oldDesign.design, newArt);
    design.cardImage = oldDesign.cardImage;
    design.jpDBId    = oldDesign.jpDBId;
    design.finalImage= oldDesign.finalImage;

    widget._cardId.cardInExp().setImage(widget._cardId.idImage!, design);
  }

  @override
  void initState() {
    final imageDesign = currentDesign();
    imageController.text  = imageDesign.cardImage;
    jpCodeController.text = imageDesign.jpDBId.toString();

    designController.currentValue = imageDesign.design;
    artController.currentValue    = imageDesign.art;

    super.initState();
  }

  Widget cardView() {
    final imageDesign = widget._cardId.cardInExp().image(widget._cardId.idImage!)!;
    return Column(
      spacing: PokeRendering.spacing,
      children: [
        widget._navAdmin.rendering.genericCardWidget(widget._cardId, language: widget._navAdmin.showLanguage, reloader: true),
        Text(AppLocalizations.of(context)!.ca_b34, style: const TextStyle(fontSize: 12)),
        TextField(
            controller: imageController,
            decoration: InputDecoration(
              hintText: widget._cardId.computeJPPokemonName()
            ),
            onChanged: (data) {
              imageDesign.cardImage = data;
            }
        ),
        if(widget._navAdmin.showLanguage.location() == CardLocation.Asie) Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                controller: jpCodeController,
                onChanged: (data) {
                  setState(() {
                    if(data.isNotEmpty) {
                      imageDesign.jpDBId = int.parse(data);
                    } else {
                      imageDesign.jpDBId = 0;
                    }
                  });
                }
              ),
            ),
            Card( child: IconButton(
              icon: const Icon(Icons.upgrade),
              onPressed: () async {
                // Clean all data
                imageDesign.finalImage = "";
                Environment.instance.storage.cleanSavedCardFile(widget._cardId).then((value) {
                  widget._cardId.computeJPCardID();
                  // Retry
                  setState(() {
                    jpCodeController.text = imageDesign.jpDBId.toString();
                  });
                });
              },
            ))
          ]
        ),
        Card(
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                // Clean all data
                imageDesign.finalImage = "";
                await Environment.instance.storage.cleanSavedCardFile(widget._cardId);

                setState(() {
                  imageDesign.jpDBId = int.parse(jpCodeController.value.text);
                });
              },
            )
        ),
      ]
    );
  }

  Widget designList() {
    final int count = (MediaQuery.of(context).size.width / 250).ceil();
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
        itemCount: widget._navAdmin.collection.designs().length,
        primary: false,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          final element = widget._navAdmin.collection.designs()[index];
          return CustomRadio(value: element, controller: designController, widget: widget._navAdmin.rendering.icon(element) );
        }
    );
  }

  Widget artList() {
    final int count = (MediaQuery.of(context).size.width / 250).ceil();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: count, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
      itemCount: ArtFormat.values.length,
      primary: false,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final element = ArtFormat.values[index];
        return CustomRadio(value: element, controller: artController, widget: widget._navAdmin.rendering.iconArt(element) );
      }
    );
  }

  Widget verticalView() {
    return Column(
      spacing: PokeRendering.spacing,
      children: [
        cardView(),
        artList(),
        designList(),
      ]
    );
  }

  Widget horizonalView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: PokeRendering.spacing,
      children: [
        Expanded(child: cardView()),
        Expanded(
          child: Column(
            spacing: PokeRendering.spacing,
            children: [
              artList(),
              designList(),
            ]
          ),
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    //final nextCardId = widget._cardId.expansion.cards.nextId(widget._cardId.idCard);

    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.ca_b41),
          /*
          actions: [
            if(nextCardId != null)
              Card(
                  color: Colors.grey[800],
                  child: TextButton(
                      child: Text(AppLocalizations.of(context)!.nce_b6),
                      onPressed: () {
                        //TODO
                        /*
                        Navigator.pop(context);
                        Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => CardEditor(widget.expansion, nextCardId, widget.options)),
                        );

                        // WARNING: refresh issue (don't known how to refresh new popped CardEditor page)
                        var nextCard = widget.expansion.cardFromId(nextCardId);
                        if(nextCard.images.length >= widget.idImage.idSet
                            && nextCard.images[widget.idImage.idSet].length > widget.idImage.idImage) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => WidgetCreatorCardImage(
                                widget.expansion, nextCard, nextCardId, widget.idImage, widget.activeLanguage, widget.options)),
                          );
                        }
                        */
                      }
                  )
              ),
          ],
          */
        ),
        body: LayoutBuilder(
          builder: (context, box) {
            if(box.hasTightWidth) {
              return verticalView();
            } else {
              return horizonalView();
            }
          }
        )
    );
  }
}