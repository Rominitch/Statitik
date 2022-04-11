import 'dart:math';

import 'package:flutter/material.dart';

import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/stats/statsExtensionCards.dart';
import 'package:statitikcard/screen/stats/statsExtensionDraw.dart';

import 'package:statitikcard/services/Tools.dart';
import 'package:statitikcard/services/internationalization.dart';
import 'package:statitikcard/services/models/SerieType.dart';

class StatsExtensionWidget extends StatefulWidget {
  final StatsConfiguration info;
  final PageController     pageController;

  const StatsExtensionWidget(this.info, this.pageController);

  @override
  _StatsExtensionWidgetState createState() => _StatsExtensionWidgetState();
}

class _StatsExtensionWidgetState extends State<StatsExtensionWidget> with TickerProviderStateMixin {
  late TabController tabController;



  bool hasStats() {
    return widget.info.statsData.subExt != null && widget.info.statsData.subExt!.type == SerieType.Normal;
  }

  Widget menuBar(BuildContext context, String idText ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(StatitikLocale.of(context).read(idText)),
    );
  }

  void onChangedTab() {
    widget.info.options.tabViewMode = tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    var sData = widget.info.statsData;
    if(sData.stats == null && sData.subExt != null) {
      return drawLoading(context);
    } else if(widget.info.statsData.subExt != null && !widget.info.statsData.subExt!.seCards.isValid) {
      return drawOut(context, widget.info.statsData.subExt!);
    } else {
      var maxTab = hasStats() ? 3 : 2;
      tabController = TabController(length: maxTab,
          vsync: this,
          initialIndex: min(max(widget.info.options.tabViewMode, 0), maxTab-1),
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
              if(hasStats())
                menuBar(context, 'SMENU_2'),
            ]
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                StatsExtensionCards(widget.info),
                SingleChildScrollView(child: StatsExtensionsPage(stats: sData.stats!, data: sData)),
                if(hasStats())
                  SingleChildScrollView(child: StatsExtensionDraw(widget.info)),
              ]
            )
          )
        ]
      );
    }
  }
}
