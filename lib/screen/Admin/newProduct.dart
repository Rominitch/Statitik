import 'package:flutter/material.dart';
import 'package:statitikcard/screen/view.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models.dart';

class NewProductBooster {
  int subExtension;
  int count;
  int nbCard;
}

class NewProduct {
  Language l;
  String name = '';
  String EAC = '';
  String image = '';
  int year = 2021;
  int cat = null;
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

  @override
  void initState() {
    radioLangue = [];
    for( Language l in Environment.instance.collection.languages)
    {
      radioLangue.add(Expanded( child:
      Container(
        child: FlatButton(
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
      var catResult = await connection.query("SELECT * FROM `Categorie`");
      for (var row in catResult) {
        radioCat.add(
        RadioListTile<int>(
          title: Text(row[1]),
          value: row[0],
          groupValue: product.cat,
          onChanged: (int value) {
            setState(() {
              product.cat = value;
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
      formular = [
        TextFormField(
          decoration: InputDecoration(
              labelText: 'Nom du produit'
          ),
          initialValue: product.name,
          validator: (value) {
            if (value.isEmpty) {
              return 'Veuillez donner un nom.';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(
              labelText: 'EAC'
          ),
          initialValue: product.EAC,
          validator: (value) {
            if (value.isEmpty) {
              return 'Veuillez donner un nom.';
            }
            return null;
          },
        ),
        Center(
          child: Row(children: [
            CircleAvatar(child: Icon(Icons.remove)),
            Container(
                width: 100.0,
                child: Text('${product.year}', textAlign: TextAlign.center,)),
            CircleAvatar(child: Icon(Icons.add))
          ]),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate returns true if the form is valid, or false
            // otherwise.
            if (_formKey.currentState.validate()) {
            // If the form is valid, display a Snackbar.

            }
          },
          child: Text('Submit'),
        )
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
