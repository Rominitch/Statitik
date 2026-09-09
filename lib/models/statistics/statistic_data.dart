
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_serie.dart';
import 'package:statitikcard/models/statistics/poke_stats_booster.dart';
import 'package:statitikcard/screenOld/stats/stat_view.dart';
import 'package:statitikcard/screenOld/stats/stats.dart';
import 'package:statitikcard/services/models/models.dart';
import 'package:statitikcard/services/models/product.dart';
import 'package:statitikcard/services/models/product_category.dart';

class ExpansionSelection {
  PokeLanguage?   language;
  CardLocation?  location;
  PokeSerie?     serie;
  PokeExpansion? expansion;

  ExpansionSelection({this.language, this.location, this.serie, this.expansion});

  List<PokeExpansion>? allExpansions() {
    return serie!.expansions(language!.location());
  }

  bool hasStats() {
    return expansion != null && expansion!.type == ExpansionType.Normal;
  }
}

class StatisticData {
  ExpansionSelection selection = ExpansionSelection();

  ProductRequested? pr;
  ProductCategory?  category;
  PokeStatsBooster? stats;
  PokeStatsBooster? userStats;
  CardResults       cardStats = CardResults();

  StateStatsExtension state     = StateStatsExtension.cards;
  StatsViewOptions    options   = StatsViewOptions();

  bool isValid() {
    return selection.language != null && selection.expansion != null && stats != null;
  }
}