
import 'package:mysql1/mysql1.dart';

class PokeConfiguration {
  bool showExtensionName      = false;
  bool showPressImages        = false;
  bool showPressProductImages = false;
  bool showTCGImages          = false;
  bool isMaintenance          = false;

  int    currentDataDB  = 0;
  String currentVersion = '3.5';

  Future<void> readFrom(TransactionContext connection) async {
    var info = await connection.query("SELECT * FROM `BaseInfo`");

    for (var row in info) {
      currentVersion         = row[0];
      showPressImages        = (row[2] == 1);
      showPressProductImages = (row[3] == 1);
      showTCGImages          = (row[4] == 1);
      isMaintenance          = (row[5] == 1);
      currentDataDB          = row[6];
    }
  }
}