import 'package:statitikcard/services/tools.dart';

class TimeReport {
  DateTime start = DateTime.now();
  DateTime end   = DateTime.now();

  void tick(String label) {
    end = DateTime.now();
    printOutput("${label.padRight(20)} - Done in ${(end.difference(start).inMilliseconds).toString().padLeft(5)} ms");
    start = end;
  }
}