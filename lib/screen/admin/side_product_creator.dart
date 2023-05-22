import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/language.dart';
import 'package:statitikcard/services/models/product_category.dart';
import 'package:statitikcard/services/models/product.dart';

class SideProductCreator extends StatefulWidget {
  final Language    language;
  final Product?    product;
  const SideProductCreator(this.language, {this.product, Key? key}) : super(key: key);

  @override
  State<SideProductCreator> createState() => _SideProductCreatorState();
}

class _SideProductCreatorState extends State<SideProductCreator> {
  ProductSide product = ProductSide.empty();
  late List sideProductCategories;

  @override
  void initState() {
    if(widget.product != null) {
      product.releaseDate = widget.product!.releaseDate;
    }
    sideProductCategories = Environment.instance.collection.categories.values.toList()..removeWhere((category) => category.isContainer);
    super.initState();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: product.releaseDate,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1998),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        product.releaseDate = picked;
      });
    }
  }

  bool isValid() {
    return product.name.isNotEmpty && product.category != null ;
  }

  void sendSideProduct() {
    EasyLoading.show();

    Environment.instance.sendSideProducts([product], true).then((value) {
      if(value) {
        // Reload all products and admin stuff
        Environment.instance.restoreAdminData();

        EasyLoading.dismiss();

        Navigator.of(context).pop();
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
          title: Text(StatitikLocale.of(context).read('NP_T0')),
          actions: [
            if(isValid())
              Card(
                color: Colors.green,
                child: TextButton(
                  onPressed: sendSideProduct,
                  child: const Text('Envoyer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
          ],
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1, childAspectRatio: 1.1
                  ),
                  itemCount: sideProductCategories.length,
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    ProductCategory category = sideProductCategories[index];
                    return Card(
                      color: product.category == category ? Colors.green : Colors.grey,
                      child: TextButton(
                        child: Text(category.name.name(widget.language), style: Theme.of(context).textTheme.titleLarge),
                        onPressed: () {
                          setState(() {
                            product.category = category;
                          });
                        },
                      )
                    ) ;
                  }
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Name'
                  ),
                  initialValue: product.name,
                  onChanged: (value){
                    setState(() {
                      product.name = value;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Image'
                  ),
                  initialValue: product.imageURL,
                  onChanged: (value) {
                    product.imageURL = value;
                  },
                ),
                Card(
                  child: TextButton(
                    onPressed: () { _selectDate(context); },
                    child: Text(DateFormat('yyyy-MM-dd').format(product.releaseDate)),
                  )
                ),
              ],
            )
          )
        )
    );
  }
}
