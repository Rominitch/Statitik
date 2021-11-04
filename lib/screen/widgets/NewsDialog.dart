import 'dart:math';

import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:statitikcard/services/News.dart';
import 'package:statitikcard/services/Tools.dart';

SimpleDialog createNewDialog(BuildContext context, List<News> news)
{
  return SimpleDialog(
    titlePadding: EdgeInsets.zero,
    contentPadding: EdgeInsets.zero,
    insetPadding: EdgeInsets.symmetric(horizontal: 0),
    children: [
      Container(
        width: MediaQuery.of(context).size.width,
        child: CarouselNews(news)
      )
    ],
  );
}

class CarouselNews extends StatefulWidget {

  final List<News> news;

  const CarouselNews(this.news);

  @override
  _CarouselNewsState createState() => _CarouselNewsState();
}

class _CarouselNewsState extends State<CarouselNews> {
  int _current = 0;
  final CarouselController _controller = CarouselController();
  late List<Widget> newsWidget;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> newsWidget = [];
    for(var newsItem in widget.news) {
      newsWidget.add(Container(
          width: MediaQuery.of(context).size.width,
          /*
          decoration: BoxDecoration(
              color: Colors.amber
          ),
          */
          child: Column(
                children: [
                  Center( child: Text(newsItem.title, style: Theme.of(context).textTheme.headline5)),
                  SizedBox(height: 20),
                  SingleChildScrollView(child: Text(newsItem.body, textAlign: TextAlign.justify, softWrap: true, maxLines: 20, style: TextStyle(fontSize: 12))),
                  if(newsItem.images != null) Flexible(child: drawImagePress(context, newsItem.images!, 300)),
                ]
            ),
          )
      );
    }

    return Column(
      children: [
        CarouselSlider(
            carouselController: _controller,
            options: CarouselOptions(
                height: min(MediaQuery.of(context).size.height/2, 600),
                enableInfiniteScroll: false,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }
            ),
            items:   newsWidget
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: newsWidget.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                        .withOpacity(_current == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
        Card(
          color: Colors.grey[900],
          child: TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Icon(Icons.close)),
        )
      ],
    );
  }
}
