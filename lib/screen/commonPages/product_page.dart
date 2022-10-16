import 'package:flutter/material.dart';

import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/sub_extension.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/type_card.dart';
import 'package:statitikcard/services/tools.dart';

enum ProductPageMode {
  allSelection,
  userSelection,
}

class ProductPage extends StatefulWidget {
  final Language language;
  final SubExtension subExt;
  final Function(BuildContext, Language, ProductRequested?, ProductCategory?) afterSelected;
  final ProductPageMode mode;

  const ProductPage({ required this.mode, required this.language, required this.subExt, required this.afterSelected, Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Widget>? widgetProd;
  bool productFound = false;

  bool userSelection() {
    return (widget.mode == ProductPageMode.userSelection);
  }

  void setupProducts(BuildContext context) {
    var env = Environment.instance;
    if(widgetProd != null) {
      widgetProd!.clear();
    }

    filterProducts(widget.language, widget.subExt, null, showAll: env.state.showAllproduct, withUserCount: userSelection(), onlyWithUser: userSelection() ).then((products) {
      widgetProd = [];
      productFound = false;

      // All products
      if( userSelection() ) {
        widgetProd!.add(
          Card(
            child: TextButton(child: Row(
                children: [
                  Text(StatitikLocale.of(context).read('S_B9'), style: Theme
                      .of(context)
                      .textTheme
                      .headline5),
                  const Expanded(child: SizedBox(width: 10)),
                  Text(StatitikLocale.of(context).read('TP_B2'),
                      style: const TextStyle(fontSize: 9)),
                  const Icon(Icons.arrow_right_outlined)
                ]),
              onPressed: () {
                widget.afterSelected(context, widget.language, null, null);
              },
            ),
          ));
      }

      // For each product
      products.forEach((category, catProd) {
        List<Widget> productCard = [];

        for (ProductRequested pr in catProd) {
          productFound = true;

          String nameProduct = pr.product.name;
          if(userSelection()) {
            int countP = pr.count;
            // Stop and don't show
            if(countP == 0) {
              continue;
            }

            nameProduct += ' (${countP.toString()})';
          }

          bool productImage = pr.product.hasImages() && env.showPressProductImages;
          productCard.add(Card(
              color: pr.color,
              child: TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.all(8.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if(productImage) pr.product.image(),
                      if(productImage) Text(
                          nameProduct, textAlign: TextAlign.center,
                          softWrap: true,
                          style: TextStyle(fontSize: ((pr.product.name.length > 15)
                              ? 8
                              : 13)))
                      else
                        Text(nameProduct, textAlign: TextAlign.center,
                          softWrap: true,),

                    ]
                ),
                onPressed: () {
                  widget.afterSelected(context, widget.language, pr, null);
                },
              )
          ));
        }

        if (productCard.isNotEmpty) {
          if(userSelection()) {
            widgetProd!.add(
                Card(
                  child: TextButton(
                    child: Row(
                    children: [
                      Text(category.name.name(widget.language), style: Theme.of(context).textTheme.headline5),
                      const Expanded(child: SizedBox(width: 10)),
                      Text(StatitikLocale.of(context).read('TP_B2'), style: const TextStyle(fontSize: 9)),
                      const Icon(Icons.arrow_right_outlined)
                    ]),
                    onPressed: () {
                      widget.afterSelected(context, widget.language, null, category);
                    },
                  ),

                ));
          } else {
            widgetProd!.add(
                Text(category.name.name(widget.language), style: Theme.of(context).textTheme.headline5));
          }
          widgetProd!.add(GridView.count(
            crossAxisCount: 3,
            scrollDirection: Axis.vertical,
            primary: false,
            shrinkWrap: true,
            children: productCard,
          ));
        }
      });

      setState(() {});
    });
  }

  @override
  void initState() {
    setupProducts(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var env = Environment.instance;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children:[
            Text(StatitikLocale.of(context).read('TP_T0'), style: Theme.of(context).textTheme.headline5),
            const SizedBox(width: 5),
            widget.language.barIcon(),
            widget.subExt.image( wSize: iconSize ),
          ],
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.grey[800],
            radius: 20,
            child: TextButton(
                child: env.state.showAllproduct ? const Icon(Icons.grid_on) : const Icon(Icons.grid_view),
                onPressed: () {
                  env.state.showAllproduct = !env.state.showAllproduct;
                  setupProducts(context);
                },
            ),
          ),
          const SizedBox(width: 5),
          CircleAvatar(
              backgroundColor: Colors.grey[800],
              radius: 20,
              child: TextButton(
                child: const Icon(Icons.help_outline,),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(StatitikLocale.of(context).read('help'), style: Theme.of(context).textTheme.headline5),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text( StatitikLocale.of(context).read('TP_B6'), textAlign: TextAlign.justify),
                          const SizedBox(height: 10.0),
                          Text( StatitikLocale.of(context).read('TP_B1'), textAlign: TextAlign.justify),
                          Environment.instance.createDiscordButton()
                        ]
                      )
                    )
                  );
                },
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body:
        widgetProd == null
          ? drawLoading(context)
          : (widgetProd!.isEmpty ? Center( child: Text(StatitikLocale.of(context).read('TP_B0'), textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline1))
            : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widgetProd!,
              ),
          )
        )
    );
  }
}