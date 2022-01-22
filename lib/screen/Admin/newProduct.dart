import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/screen/commonPages/extensionPage.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

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
  int? cat;
  List<NewProductBooster> boosters = [];

  bool validate() {
    bool valid = boosters.length > 0;
    //boosters.forEach((element) { valid &= element.ext != null; });
    return valid;
  }
}

class NewProductPage extends StatefulWidget {
  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = GlobalKey<FormState>();

  NewProduct product = NewProduct();
  List<Widget> radioCat = [];
  List<Widget> radioLangue = [];

  String? error;

  void onAdd()
  {
    setState(() {
      product.boosters.add(new NewProductBooster());
    });
  }

  @override
  void initState() {
    radioLangue = [];
    for( Language l in Environment.instance.collection.languages.values)
    {
      radioLangue.add(Expanded( child:
      Container(
        child: TextButton(
          child: Image(
            image: AssetImage('assets/langue/${l.image}.png'),
          ),
          onPressed: () {
            setState(() {
              product.l = l;
            });
          },
        ),
      )
      )
      );
    }

    Environment.instance.db.transactionR( (connection) async {
      radioCat.clear();
      var catResult = await connection.query("SELECT idCategorie FROM `Categorie`");
      for (var row in catResult) {
        radioCat.add(
        RadioListTile<int>(
          title: Text(categoryName(context, row[0])),
          value: row[0],
          groupValue: product.cat,
          onChanged: (int? value) {
            setState(() {
              product.cat = value!;
            });
          },
        ));
      }
    } ).whenComplete(() {
      setState(() {

      });
    });
    super.initState();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: product.out,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(2015),
        lastDate: DateTime(2101));
    if (picked != null)
      setState(() {
        product.out = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> formular = [];
    if(product.cat == null)
      formular.add(Card( child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
        Text(''),
      ]+radioCat) ));
    if(product.l == null)
      formular.add(Card( child: Row( children: radioLangue) ));
    if(product.cat != null && product.l != null) {
      List<Widget> bs=[];
      for(NewProductBooster booster in product.boosters) {
        bs.add(BoostersInfo(productAdd: onAdd, newProd: booster, l: product.l,));
      }
      bs.add(BoostersInfo(productAdd: onAdd, newProd: null, l: product.l));

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
        TextFormField(
          decoration: InputDecoration(
              labelText: 'EAC'
          ),
          initialValue: product.eac,
          validator: (value) {
            if(value != null) {
              if (value.contains(new RegExp(r'[a-z]'))) {
                return 'EAN doit contenir des chiffres.';
              }
              product.eac = (value.isEmpty ? null : '"'+value+'"');
            }
            return null;
          },
        ),
        Card(
          child: TextButton(
            onPressed: () { _selectDate(context); },
            child: Text(DateFormat('yyyy-MM-dd').format(product.out)),
          )
        ),
      ] + bs + [
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
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

                  var outDate = DateFormat('yyyy-MM-dd 00:00:00').format(product.out);
                  String query = 'INSERT INTO `Produit` (idProduit, idLangue, idUtilisateur, nom, EAN, sortie, idCategorie, icone, approuve) VALUES ($idAchat, ${product.l!.id}, ${env.user!.idDB}, "${product.name}", ${product.eac}, "$outDate", ${product.cat}, "", 1);';
                  await connection.query(query);

                  // Prepare data
                  List<List<Object?>> pb = [];
                  for(NewProductBooster b in product.boosters) {
                    pb.add( [idAchat, b.ext == null ? null : b.ext!.id, b.count, b.nbCard]);
                  }
                  // Send data
                  await connection.queryMulti('INSERT INTO `ProduitBooster` (idProduit, idSousExtension, nombre, carte) VALUES (?, ?, ?, ?);',
                      pb);
                } ).then((value) {
                  if(value)
                    Navigator.pop(context);
                }).onError((errorInfo, stackTrace) {
                  error = errorInfo.toString();
                });
              } catch (e) {
                //print(e);
              }
            }
          },
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
  final Function productAdd;
  final NewProductBooster? newProd;
  final Language? l;

  BoostersInfo({required this.productAdd, this.newProd, required this.l});

  @override
  _BoostersInfoState createState() => _BoostersInfoState();
}

class _BoostersInfoState extends State<BoostersInfo> {

  void afterSelected(BuildContext context, Language language, SubExtension subExt) {
    Navigator.pop(context);
    setState(() {
      widget.newProd!.ext = subExt;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.newProd != null) {
      return Card(
          child: Row(children: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: Size(0.0, 40.0)),
              child: (widget.newProd!.ext != null) ? widget.newProd!.ext!.image(hSize: iconSize) : Icon(Icons.add_to_photos),
              onPressed: (){
                setState(() {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExtensionPage(language: widget.l!, afterSelected: afterSelected, addMode: false)));
                });
              },
            ),
            Expanded(
              child: SpinBox(
                value: widget.newProd!.count.toDouble(),
                min: 1,
                max: 50,
                decoration: InputDecoration(labelText: 'Boosters'),
                onChanged: (value) {
                  widget.newProd!.count = value.toInt();
                },
              ),
            ),
            Expanded(
              child: SpinBox(
                value: widget.newProd!.nbCard.toDouble(),
                min: 1,
                max: 15,
                decoration: InputDecoration(labelText: 'Cartes'),
                onChanged: (value) {
                  widget.newProd!.nbCard = value.toInt();
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

