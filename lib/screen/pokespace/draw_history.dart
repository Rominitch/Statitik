import 'package:flutter/material.dart';
import 'package:statitikcard/screen/PokeSpace/pokespace_draw_resume.dart';
import 'package:statitikcard/services/draw/session_draw.dart';
import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class DrawHistory extends StatefulWidget {
  final bool isAdmin;
  const DrawHistory([this.isAdmin=false, key]): super(key: key);

  @override
  State<DrawHistory> createState() => _DrawHistoryState();
}

class _DrawHistoryState extends State<DrawHistory> {
  List<SessionDraw> myDraw   = [];
  List<Widget>?     myDrawWidgets;

  void buildWidget() {
    Environment.instance.getMyDraw(widget.isAdmin).then((dynamic value) {
      myDraw = value;
      myDrawWidgets = [];
      setState(() {
        for(var draw in myDraw) {
          myDrawWidgets!.add(Card(
              child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PokeSpaceDrawResume(activeSession: draw)));
                },
                onLongPress: (widget.isAdmin) ? () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                          children: [
                            Card(
                              color: Colors.red,
                              child: TextButton(
                                child: Text(StatitikLocale.of(context).read('delete')),
                                onPressed: () {
                                  Environment.instance.removeUserProduct(draw).then((value){
                                    Navigator.of(context).pop();
                                    setState(() {
                                      buildWidget();
                                    });
                                  });
                                },
                              )),
                          ]
                        );
                      }
                    );
                  });
                } : () {},
                child:Row(
                  children:[
                    draw.language.barIcon(),
                    const SizedBox(width: 15),
                    draw.product.image(),
                    const SizedBox(width: 15),
                    Flexible(
                      child: Text(draw.product.name,
                        softWrap: true,
                        maxLines: 3,
                        style: draw.product.name.length > 10
                            ? Theme.of(context).textTheme.headline6
                            : Theme.of(context).textTheme.headline5),
                    )
                  ]),
              )
          ));
        }
      });
    });
  }

  @override
  void initState() {
    buildWidget();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( StatitikLocale.of(context).read('DC_B11'), style: Theme.of(context).textTheme.headline3),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: myDrawWidgets != null ?
              (myDrawWidgets!.isNotEmpty ?
                ListView(
                  children: myDrawWidgets!,
                ) :
                drawNothing(context, 'DH_B0')
              ): drawLoading(context)
        )
      )
    );
  }
}