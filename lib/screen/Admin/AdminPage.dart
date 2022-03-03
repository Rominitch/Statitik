
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/screen/Admin/newCardExtensions.dart';
import 'package:statitikcard/screen/Admin/newProduct.dart';
import 'package:statitikcard/screen/tirage/DrawHistory.dart';
import 'package:statitikcard/services/connection.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Widget> buttons = [];

  void cleanOrphan() {
    var orphans = Environment.instance.collection.searchOrphanCard();
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            title: new Text(StatitikLocale.of(context).read('warning')),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text( sprintf(StatitikLocale.of(context).read('CA_B33'), [orphans.length]),
                      textAlign: TextAlign.justify),
                  if(orphans.isNotEmpty) Card(
                      color: Colors.red,
                      child: TextButton(
                          child: Text(StatitikLocale.of(context).read('yes')),
                          onPressed: () {
                            // Remove card
                            Environment.instance.removeOrphans(orphans).then((value) {
                              if(value) {
                                // Reload full database to have all real data
                                Environment.instance.restoreAdminData().then( (value){
                                  Navigator.pop(context);
                                });
                              }
                            });
                          }
                      )
                  )
                ]
            )
        )
    );
  }

  Widget createButton(IconData icon, Color colorBox, Function() action) {
    return Card(
      color: colorBox,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon),
        color: Colors.white,
        onPressed: action,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    buttons.add(createButton(Icons.add_shopping_cart, Colors.lightGreen, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => NewProductPage()));
    }));
    buttons.add(createButton(Icons.post_add_outlined, Colors.deepOrange, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => NewCardExtensions()));
    }));
    buttons.add(createButton(Icons.remove_red_eye_rounded, Colors.blueAccent, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DrawHistory(true)));
    }));
    buttons.add(createButton(Icons.delete_forever, Colors.blueAccent, cleanOrphan));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(child: Text( StatitikLocale.of(context).read('H_T4'), style: Theme.of(context).textTheme.headline3 )),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Card(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row( children: [
                    Text(StatitikLocale.of(context).read('O_B2')),
                    Checkbox(value: useDebug,
                        onChanged: (newValue) {
                          useDebug = newValue!;
                          EasyLoading.show();
                          Environment.instance.restoreAdminData().then((value){
                            setState(() {});
                            EasyLoading.dismiss();
                          });
                        }
                    ),
                    Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey, // background
                          ),
                          onPressed: () {
                            EasyLoading.show();
                            Environment.instance.restoreAdminData().then((value) {
                              EasyLoading.dismiss();
                            });
                          },
                          child: Text(StatitikLocale.of(context).read('O_B1'))
                      ),
                    ),
                  ]
                  ),
                )),

                GridView.count(crossAxisCount: 3,
                  children: buttons,
                  primary: false,
                  shrinkWrap: true,
                ),
              ],
            )
          )
        )
    );
  }
}
