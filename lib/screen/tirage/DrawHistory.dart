import 'package:flutter/material.dart';
import 'package:statitikcard/screen/tirage/tirage_resume.dart';
import 'package:statitikcard/services/SessionDraw.dart';
import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/internationalization.dart';

class DrawHistory extends StatefulWidget {
  final bool isAdmin;
  DrawHistory([this.isAdmin=false]);

  @override
  _DrawHistoryState createState() => _DrawHistoryState();
}

class _DrawHistoryState extends State<DrawHistory> {
  List<SessionDraw> myDraw   = [];
  List<Widget>? myDrawWidgets;

  void buildWidget() {
    Environment.instance.getMyDraw(widget.isAdmin).then((dynamic value) {
      myDraw = value;
      myDrawWidgets = [];
      setState(() {
        for(var draw in myDraw) {
          myDrawWidgets!.add(Card(
              child: TextButton(
                child:Row(
                    children:[
                      draw.language.barIcon(),
                      SizedBox(width: 15),
                      draw.product.image(),
                      SizedBox(width: 15),
                      Flexible(
                        child: Text(draw.product.name,
                            softWrap: true,
                            maxLines: 3,
                            style: draw.product.name.length > 10
                                ? Theme.of(context).textTheme.headline6
                                : Theme.of(context).textTheme.headline5),
                      )
                    ]),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResumePage(draw)));
                },
                onLongPress: (widget.isAdmin) ? () {
                  setState(() {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return SimpleDialog(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
              (myDrawWidgets!.length > 0 ?
                ListView(
                  children: myDrawWidgets!,
                ) :
                Text(StatitikLocale.of(context).read('DH_B0'), style: Theme.of(context).textTheme.headline3)
              ): drawLoading(context)
        )
      )
    );
  }
}
