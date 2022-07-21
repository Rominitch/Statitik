import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:statitikcard/services/environment.dart';

class News {
  int    id;
  String title;
  String body;
  String? images;

  News(this.id, this.title, this.body, this.images);

  static Future<List<News>> readFromDB(Locale locale, int latestId) async {
    List<News> news = [];
    var db = Environment.instance.db;

    await db.transactionR( (connection) async {
      String query = 'SELECT *'
          ' FROM `News`'
          ' WHERE `idNews` > \'$latestId\''
          ' AND `language` = \'${locale.languageCode}\''
          ' ORDER BY `idNews` DESC LIMIT 5';
      //printOutput(query);

      var req = await connection.query(query);
      for (var row in req) {
        news.add(News(row[0], row[2], (row[3] as Blob).toString(), row[4]));
      }
    });
    return news;
  }
}