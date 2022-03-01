import 'package:flutter/material.dart';
import 'package:statitikcard/screen/tirage/PokeSpaceDrawResume.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/UserDrawFile.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class PokeSpaceSavedDraw extends StatefulWidget {
  final List<UserDrawFile> localDraws;
  const PokeSpaceSavedDraw(this.localDraws, {Key? key}) : super(key: key);

  @override
  _PokeSpaceSavedDrawState createState() => _PokeSpaceSavedDrawState();
}

class _PokeSpaceSavedDrawState extends State<PokeSpaceSavedDraw> {
  late Map<UserDrawFile, SessionDraw> allSavedDraw;

  Future<void> extractData() async {
    allSavedDraw = {};
    for(final element in widget.localDraws) {
      var sd = await element.read(Environment.instance.collection.languages,
           Environment.instance.collection.products, Environment.instance.collection.subExtensions);
      allSavedDraw[element] = sd;
    }
  }

  @override
  void initState() {
    extractData().then((value){
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read('DC_B19'), style: Theme.of(context).textTheme.headline3),
      ),
      body:SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: (allSavedDraw.isEmpty)
            ? drawLoading(context)
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 1, mainAxisSpacing: 1,
                    childAspectRatio: 1.4),
                primary: false,
                shrinkWrap: true,
                itemCount: allSavedDraw.length,
                itemBuilder: (context, id) {
                  var file = allSavedDraw.keys.toList(growable: false)[id];
                  var sd   = allSavedDraw[file]!;
                  return Card(
                    child: TextButton(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: sd.product.image()),
                          SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              sd.language.barIcon(),
                              SizedBox(width:15),
                              Text(sd.product.name, softWrap: true)
                            ]
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceDrawResume.fromSave(sd, file) )).then((value) {
                          setState(() {});
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: Center(child: Text(StatitikLocale.of(context).read('NCE_B3'), style: Theme.of(context).textTheme.headline3)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                children: [
                                  Card(
                                    color: Colors.red,
                                    child: TextButton(
                                      child: Text(StatitikLocale.of(context).read('NCE_B5')),
                                      onPressed: () {
                                        file.remove();
                                        Navigator.of(context).pop();
                                        allSavedDraw.remove(file);
                                        if(allSavedDraw.isEmpty) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    )),
                                ]
                              );
                            }
                          );
                        });
                      },
                    )
                  );
                },
            )
        )
      )
    );
  }
}
