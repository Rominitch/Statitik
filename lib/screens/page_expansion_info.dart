import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';

import 'package:statitikcard/screenOld/stats/stats.dart';
import 'package:statitikcard/screenOld/stats/stats_extension.dart';
import 'package:statitikcard/screenOld/stats/stats_extension_cards.dart';
import 'package:statitikcard/screenOld/stats/stats_extension_draw.dart';

import 'package:statitikcard/services/tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/serie_type.dart';

class PageExpansionInfo extends StatefulWidget {
  final StatisticData      _info;
  final PageController     pageController;

  const PageExpansionInfo(this._info, this.pageController, {super.key});

  @override
  State<PageExpansionInfo> createState() => _PageExpansionInfoState();
}

class _PageExpansionInfoState extends State<PageExpansionInfo> with TickerProviderStateMixin {
  late TabController tabController;

  Widget menuBar(BuildContext context, String idText ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(StatitikLocale.of(context).read(idText)),
    );
  }

  void onChangedTab() {
    widget._info.options.tabViewMode = tabController.index;
  }

  Widget _drawOut(BuildContext context, PokeExpansion se) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(sprintf(StatitikLocale.of(context).read('SEC_0'), [DateFormat.yMMMMd(StatitikLocale.of(context).locale.toLanguageTag()).format(se.released())]),
                  style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              drawImagePress(context, 'zorua', 300),
              const SizedBox(height: 30),
              Center(child: Text(sprintf(StatitikLocale.of(context).read('SEC_1'), [DateFormat.yMMMMd(StatitikLocale.of(context).locale.toLanguageTag()).format(se.released())]),
                  style: Theme.of(context).textTheme.headlineSmall),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStats = widget._info.hasStats();
    if( !widget._info.isValid() ) {
      return drawLoading(context);
    } else if(!widget._info.selection.expansion!.cards.isValid()) {
      return _drawOut(context, widget._info.selection.expansion!);
    } else {
      var maxTab = hasStats ? 3 : 2;
      tabController = TabController(length: maxTab,
          vsync: this,
          initialIndex: min(max(widget._info.options.tabViewMode, 0), maxTab-1),
          animationDuration: Duration.zero);
      tabController.addListener(onChangedTab);
      return Column(
          children: [
            TabBar(
                controller: tabController,
                isScrollable: false,
                indicatorPadding: const EdgeInsets.all(1),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.green,
                ),
                tabs: [
                  menuBar(context, 'SMENU_0'),
                  menuBar(context, 'SMENU_1'),
                  if(hasStats)
                    menuBar(context, 'SMENU_2'),
                ]
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Placeholder(), //StatsExtensionCards(widget._info),
                  Placeholder(), //SingleChildScrollView(child: StatsExtensionsPage(widget._info)),
                  if(hasStats)
                    Placeholder(), //SingleChildScrollView(child: StatsExtensionDraw(widget._info)),
                ]
              )
            )
          ]
      );
    }
  }
}
