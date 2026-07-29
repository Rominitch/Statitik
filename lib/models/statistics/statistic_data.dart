
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_langage.dart';
import 'package:statitikcard/models/poke_serie.dart';
import 'package:statitikcard/screenOld/stats/stat_view.dart';
import 'package:statitikcard/screenOld/stats/stats.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/product_category.dart';

class ExpansionSelection {
  PokeLangage?   language;
  CardLocation?  location;
  PokeSerie?     serie;
  PokeExpansion? expansion;

  ExpansionSelection({this.language, this.location, this.serie, this.expansion});
}

class StatisticData {
  ExpansionSelection selection = ExpansionSelection();

  ProductRequested? pr;
  ProductCategory?  category;
  StatsBooster?     stats;
  StatsBooster?     userStats;
  CardResults       cardStats = CardResults();

  StateStatsExtension state     = StateStatsExtension.cards;
  StatsViewOptions    options   = StatsViewOptions();

  bool isValid() {
    return selection.language != null && selection.expansion != null && stats != null;
  }

  bool hasStats() {
    return selection.expansion != null && selection.expansion!.type == ExpansionType.Normal;
  }
}