import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/ProductCategory.dart';
import 'package:statitikcard/services/models/TypeCard.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
/*
class NewProductBooster {
  SubExtension? ext;
  int count=1;
  int nbCard=11;
}

class NewProduct {
  Language? l;
  String name = '';
  String? eac;
  String image = '';
  DateTime out = DateTime.now();
  ProductCategory? cat;
  List<NewProductBooster> boosters = [];

  bool validate() {
    bool valid = boosters.length > 0;
    //boosters.forEach((element) { valid &= element.ext != null; });
    return valid;
  }
}
*/

class NewProductPage extends StatefulWidget {
  final Language activeLanguage;
  final Product? editProduct;

  NewProductPage([this.editProduct, Language? l]) :
    activeLanguage = (l != null ? l : Environment.instance.collection.languages[1]!);

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = GlobalKey<FormState>();

  Product       product     = Product.empty();
  //NewProduct    product     = NewProduct();
  List<Widget>  radioCat    = [];
  List<Widget>  radioLangue = [];

  String? error;

  void onAdd()
  {
    setState(() {
      product.boosters.add(ProductBooster(null, 1, product.language!.isJapanese() ? 5 : 11));
    });
  }

  @override
  void initState() {
    if(widget.editProduct != null)
      product = widget.editProduct!;

    radioLangue.clear();
    for( Language l in Environment.instance.collection.languages.values)
    {
      radioLangue.add(
        Expanded(
          child: Container(
            child: TextButton(
              child: Image(
                image: AssetImage('assets/langue/${l.image}.png'),
              ),
              onPressed: () {
                setState(() {
                  product.language = l;
                });
              },
            ),
          )
        )
      );
    }

    radioCat.clear();
    Environment.instance.collection.categories.forEach((idDB, category) {
      if(category.isContainer) {
        radioCat.add(
          RadioListTile<ProductCategory>(
            title: Text(category.name.name(widget.activeLanguage)),
            value: category,
            groupValue: product.category,
            onChanged: (ProductCategory? value) {
              setState(() {
                product.category = value!;
              });
            },
          )
        );
      }
    });
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: product.outDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        product.outDate = picked;
      });
  }

  void sendProduct() {
    if ( product.validate() && _formKey.currentState!.validate()) {
      error = null;
      try {
        Environment env = Environment.instance;
        env.db.transactionR( (connection) async {
          int idAchat=0;
          var req = await connection.query('SELECT count(idProduit) FROM `Produit`;');
          for (var row in req) {
            idAchat = row[0] + 1;
          }

          var outDate = DateFormat('yyyy-MM-dd 00:00:00').format(product.outDate);
          String query = 'INSERT INTO `Produit` (`idProduit`, `idLangue`, `nom`, `icone`, `sortie`, `idCategorie`, `contenu` )'
                         ' VALUES (?, ?, ?, ?, ?, ?, ?);';
          await connection.queryMulti(query,
              [[  idAchat, product.language!.id, product.name, product.imageURL,
                  outDate, product.category!.idDB, Int8List.fromList(product.toBytes(Environment.instance.collection.rCardsExtensions))
              ]]
          );
        } ).then((value) {
          if(value)
            Navigator.pop(context);
          else
            EasyLoading.showError("Erreur produit");
        }).onError((errorInfo, stackTrace) {
          error = errorInfo.toString();
          EasyLoading.showError(error!);
        });
      } catch (e) {
        printOutput(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formular = [];
    if(product.language == null)
      formular.add(Card( child: Row( children: radioLangue) ));
    if(product.category == null)
      formular.add(Card( child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Text(''),
      ]+radioCat) ));
    if(product.category != null && product.language != null) {
      List<Widget> bs=[];
      for(ProductBooster booster in product.boosters) {
        bs.add(BoostersInfo(onAdd, booster, product.language!));
      }
      bs.add(BoostersInfo(onAdd, null, product.language!));

      formular = [
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Nom du produit'
          ),
          initialValue: product.name,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Veuillez donner un nom.';
            }
            product.name = value;
            return null;
          },
        ),
        Card(
          child: TextButton(
            onPressed: () { _selectDate(context); },
            child: Text(DateFormat('yyyy-MM-dd').format(product.outDate)),
          )
        ),
      ] + bs + [
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: sendProduct,
          child: Text('Envoyer'),
        ),
        if(error != null) Text(error!),
      ];
    }
    return Scaffold(
        appBar: AppBar(
        title: Container(
        child: Text(StatitikLocale.of(context).read('NP_T0')),
     ),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: formular,
          )
      ),
    )
    );
  }
}

class BoostersInfo extends StatefulWidget {
  final Function        productAdd;
  final ProductBooster? newProd;
  final Language        l;

  BoostersInfo(this.productAdd, this.newProd, this.l);

  @override
  _BoostersInfoState createState() => _BoostersInfoState();
}

class _BoostersInfoState extends State<BoostersInfo> {

  void afterSelected(BuildContext context, Language language, SubExtension subExt) {
    Navigator.pop(context);
    setState(() {
      widget.newProd!.subExtension = subExt;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.newProd != null) {
      return Card(
          child: Row(children: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: Size(0.0, 40.0)),
              child: (widget.newProd!.subExtension != null) ? widget.newProd!.subExtension!.image(hSize: iconSize) : Icon(Icons.add_to_photos),
              onPressed: (){
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.l, afterSelected: afterSelected, addMode: false)));
                });
              },
            ),
            Expanded(
              child: SpinBox(
                value: widget.newProd!.nbBoosters.toDouble(),
                min: 1,
                max: 50,
                decoration: InputDecoration(labelText: 'Boosters'),
                onChanged: (value) {
                  widget.newProd!.nbBoosters = value.toInt();
                },
              ),
            ),
            Expanded(
              child: SpinBox(
                value: widget.newProd!.nbCardsPerBooster.toDouble(),
                min: 1,
                max: 15,
                decoration: InputDecoration(labelText: 'Cartes'),
                onChanged: (value) {
                  widget.newProd!.nbCardsPerBooster = value.toInt();
                },
              ),
            ),
          ])
      );
    } else {
      return Card(
        child: TextButton(
          child: Center( child: Icon(Icons.add_to_photos) ),
          onPressed: () {
            widget.productAdd();
          },
        ),
      );
    }
  }
}

