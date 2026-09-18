
import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/card/poke_card_design.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/identifier/poke_card_identifier.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/screenOld/admin/card_editor_options.dart';
import 'package:statitikcard/screenOld/widgets/custom_radio.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/tools.dart';

class WidgetCreatorCardImage extends StatefulWidget {
  final PokeNavAdmin             _navAdmin;
  final PokeCardViewerIdentifier _cardId;
  /*
  final PokeExpansion        expansion;
  final PokemonCardExtension card;
  final CardIdentifier       idCard;
  final CardImageIdentifier  idImage;
  final LanguageOld             activeLanguage;
  */
  final CardEditorOptions    options;

  const WidgetCreatorCardImage(this._navAdmin, this._cardId, /*this.card, this.idCard, this.idImage, this.activeLanguage,*/ this.options, {super.key});

  static void computeJPCardID(PokeCardViewerIdentifier cardInfo) {
    try {
      int idFind = 0;
      // Search list of card
      PokeCardInExpansion ancestorCard;
      switch(cardInfo.idCard.listId) {
        case 0:
          ancestorCard = cardInfo.expansion.cards.cards.sublist(0, cardInfo.idCard.numberId).reversed.firstWhere((element) {
            idFind+=1;
            var img = element[cardInfo.idCard.alternativeId].image(cardInfo.idImage!);
            return img != null && img.jpDBId != 0;
          })[0];
          break;
        case 1:
          ancestorCard = cardInfo.expansion.cards.energyCard.sublist(0, cardInfo.idCard.numberId).reversed.firstWhere((element) {
            idFind+=1;
            var img = element.image(cardInfo.idImage!);
            return img != null && img.jpDBId != 0;
          });
          break;
        case 2:
          ancestorCard = cardInfo.expansion.cards.noNumberedCard.sublist(0, cardInfo.idCard.numberId).reversed.firstWhere((element) {
            idFind+=1;
            var img = element.image(cardInfo.idImage!);
            return img != null && img.jpDBId != 0;
          });
          break;
        default:
          throw StatitikException(ErrorCode.unknown, "Unknown list !");
      }

      // Zero propagation or next number
      var jpDB = ancestorCard
          .image(cardInfo.idImage!)!
          .jpDBId;
      if (jpDB != 0) {
        cardInfo.cardInExp().image(cardInfo.idImage!)!.jpDBId = jpDB + idFind;
      }

      // Copy name of parent
      //TODO
      /*
      var name = card.tryGetImage(PokeCardImageIdentifier()).image;
      if(name.isNotEmpty) {
        cardInfo.cardInExp().image(idImage)!.image = name;
      }
      */
    } catch(e) {
      // Nothing found !
      printOutput("ComputeJCard: impossible to find $e");
    }
  }

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

  void onDesignChanged(selectedDesign) {
    final oldDesign = currentDesign();
    final design = PokeCardDesign(selectedDesign, oldDesign.art);

    widget._cardId.cardInExp().setImage(widget._cardId.idImage!, design);
  }

  void onArtChanged( ArtFormat newArt ) {
    final oldDesign = currentDesign();
    final design = PokeCardDesign(oldDesign.design, newArt);

    widget._cardId.cardInExp().setImage(widget._cardId.idImage!, design);
  }

  @override
  void initState() {
    final imageDesign = currentDesign();
    imageController.text  = imageDesign.cardImage;
    jpCodeController.text = imageDesign.jpDBId.toString();
    // WARNING: don't copy by ref
    var newCardDesign = PokeCardDesign(imageDesign.design);

    designController.currentValue = newCardDesign;
    artController.currentValue    = imageDesign.art;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var imageDesign = widget._cardId.cardInExp().image(widget._cardId.idImage!)!;
    var nextCardId = widget._cardId.expansion.cards.nextId(widget._cardId.idCard);
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.ca_b41),
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
        ),
        body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: widget._navAdmin.rendering.genericCardWidget(widget._cardId, language: widget._navAdmin.showLanguage, reloader: true)),
              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
                  itemCount: widget._navAdmin.collection.designs().length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    var element = widget._navAdmin.collection.designs()[index];
                    return CustomRadio(value: element, controller: designController, widget: widget._navAdmin.rendering.icon(element) );
                  }
              ),
              GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.0),
                  itemCount: ArtFormat.values.length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    var element = ArtFormat.values[index];
                    return CustomRadio(value: element, controller: artController, widget: widget._navAdmin.rendering.iconArt(element) );
                  }
              ),
              Text(AppLocalizations.of(context)!.ca_b34, style: const TextStyle(fontSize: 12)),
              TextField(
                  controller: imageController,
                  decoration: InputDecoration(
                      hintText: widget._cardId.computeJPPokemonName()
                  ),
                  onChanged: (data) {
                    //TODO
                    //imageDesign.image = data;
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
                        //TODO
                        /*
                        // Clean all data
                        imageDesign.finalImage = "";
                        Environment.instance.storage.cleanCardFile(widget.expansion, widget.idCard).then((value) {
                          WidgetCreatorCardImage.computeJPCardID(widget.expansion, widget.card, widget.idCard, widget.idImage);
                          // Retry
                          setState(() {
                            jpCodeController.text = imageDesign.jpDBId.toString();
                          });
                        });
                        */
                      },
                    ))
                  ]
              ),
              Card(
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      //TODO
                      /*
                      // Clean all data
                      imageDesign.finalImage = "";
                      await Environment.instance.storage.cleanCardFile(widget.expansion, widget.idCard);

                      setState(() {
                        imageDesign.jpDBId = int.parse(jpCodeController.value.text);
                      });
                      */
                    },
                  )
              ),
            ]
        )
    );
  }
}