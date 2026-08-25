import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/statistics/statistic_data.dart';

import 'package:statitikcard/screens/page_expansion_cards.dart';

import 'package:statitikcard/services/tools.dart';

class PageExpansionInfo extends StatefulWidget {
  final StatisticData      _info;
  final PageController     pageController;

  const PageExpansionInfo(this._info, this.pageController, {super.key});

  @override
  State<PageExpansionInfo> createState() => _PageExpansionInfoState();
}

class _PageExpansionInfoState extends State<PageExpansionInfo> with TickerProviderStateMixin {
  late TabController tabController;

  Widget menuBar(BuildContext context, String text ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text),
    );
  }

  void onChangedTab() {
    widget._info.options.tabViewMode = tabController.index;
  }

  Widget _drawOut(BuildContext context, PokeExpansion se) {
    final tag = Localizations.localeOf(context).toLanguageTag();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(sprintf(AppLocalizations.of(context)!.sec_0, [DateFormat.yMMMMd(tag).format(se.released())]),
                  style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 30),
              drawImagePress(context, 'zorua', 300),
              const SizedBox(height: 30),
              Center(child: Text(sprintf(AppLocalizations.of(context)!.sec_1, [DateFormat.yMMMMd(tag).format(se.released())]),
                  style: Theme.of(context).textTheme.headlineSmall),
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStats = widget._info.selection.hasStats();
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
                  menuBar(context, AppLocalizations.of(context)!.smenu_0),
                  menuBar(context, AppLocalizations.of(context)!.smenu_1),
                  if(hasStats)
                    menuBar(context, AppLocalizations.of(context)!.smenu_2),
                ]
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  PageExtensionCards(widget._info),
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
