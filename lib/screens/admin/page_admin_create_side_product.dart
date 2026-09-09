import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_rendering.dart';
import 'package:statitikcard/models/products/poke_product_category.dart';
import 'package:statitikcard/models/products/poke_product_side.dart';
import 'package:statitikcard/services/environment.dart';

class PageAdminCreateSideProduct extends StatefulWidget {
  final PokeNavAdmin       _nav;
  final PokeProductSide?   edition;
  const PageAdminCreateSideProduct(this._nav, {this.edition, super.key});

  @override
  State<PageAdminCreateSideProduct> createState() => _PageAdminCreateSideProductState();
}

class _PageAdminCreateSideProductState extends State<PageAdminCreateSideProduct> {
  late List<PokeProductCategory> sideProductCategories;

  late PokeIdentifier      _pid;
  late PokeProductCategory _category;
  DateTime                 _release = DateTime.now();
  PokeIdentifier?          _name;

  PokeIdentifier newSideProductId() {
    return widget._nav.collection.newId(PokeIdentifierType.sideProduct, widget._nav.collection.sideProducts());
  }

  @override
  void initState() {
    sideProductCategories = widget._nav.collection.productCategories().toList()..removeWhere((category) => category.isContainer);
    sideProductCategories.sort((PokeProductCategory a, PokeProductCategory b) {
      return a.name(widget._nav.showLanguage).compareTo( b.name(widget._nav.showLanguage));
    });

    if(widget.edition != null) {
      _pid      = widget.edition!.pid();
      _category = widget.edition!.category;
      _release  = widget.edition!.releaseDate;
      _name     = widget.edition!.idName();
    } else {
      _pid = newSideProductId();
      _category = sideProductCategories.first;
    }
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _release,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1998),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        _release = picked;
      });
    }
  }
  bool isValid() {
    return _name != null;
  }

  void sendSideProduct() {
    EasyLoading.show();
    widget._nav.database.transactionR( (connection) {
      final sideProduct = PokeProductSide(_pid, _category, _release, _name!);
      return widget._nav.collection.sendSideProducts(connection, [sideProduct], widget.edition == null);
    }).then((value) {
      if(value) {
        // Reload all products and admin stuff
        Environment.instance.restoreAdminData();

        EasyLoading.dismiss();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      } else {
        EasyLoading.showError("Error");
      }
    }).onError((error, stackTrace)
    {
      EasyLoading.showError("Error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.np_t0),
              actions: [
                Card(
                  color: isValid() ? Colors.green: Colors.grey,
                  child: TextButton(
                    onPressed: isValid() ? sendSideProduct : null,
                    child: const Text('Envoyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Row(
                  spacing: PokeRendering.spacing,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      color: PokeRendering.colorLightCard,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 200,
                          child: PokeRendering.sideProductImage(_pid,
                            alternativeRendering: Center(child: Text("ID = ${_pid.id()}"))),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: PokeRendering.spacing,
                      children: [
                        Card(
                            child: TextButton(onPressed: () {

                            },
                                child: Text(_name != null ? widget._nav.showLanguage.label(_name!)! : "Pas de nom" )
                            )
                        ),
                        DropdownButton<PokeProductCategory>(
                          value: _category,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (PokeProductCategory? value) {
                            // This is called when the user selects an item.
                            setState(() {
                              _category = value!;
                            });
                          },
                          items: sideProductCategories.map<DropdownMenuItem<PokeProductCategory>>((PokeProductCategory category) {
                            return DropdownMenuItem<PokeProductCategory>(value: category,
                                child: Text(category.name(widget._nav.showLanguage), style: Theme.of(context).textTheme.titleLarge));
                          }).toList(),
                        ),
                        Card(
                            child: TextButton(
                              onPressed: () { _selectDate(context); },
                              child: Text(DateFormat('yyyy-MM-dd').format(_release)),
                            )
                        )
                      ]
                    )
                  ],
                )
              )
            )
        )
    );
  }
}
