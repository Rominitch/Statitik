import 'package:flutter/material.dart';

import 'package:statitikcard/screen/stats/stats.dart';
import 'package:statitikcard/screen/stats/statsExtension.dart';
import 'package:statitikcard/screen/stats/statsExtensionCards.dart';
import 'package:statitikcard/screen/stats/statsExtensionDraw.dart';

import 'package:statitikcard/services/Tools.dart';

class StatsExtensionWidget extends StatefulWidget {

  final StatsConfiguration info;

  const StatsExtensionWidget(this.info);

  @override
  _StatsExtensionWidgetState createState() => _StatsExtensionWidgetState();
}

class _StatsExtensionWidgetState extends State<StatsExtensionWidget> {
  @override
  Widget build(BuildContext context) {
    var sData = widget.info.statsData;

    if(sData.stats == null && sData.subExt != null) {
      return drawLoading(context);
    } else if(widget.info.statsData.subExt != null && !widget.info.statsData.subExt!.seCards.isValid) {
      return drawOut(context, widget.info.statsData.subExt!);
    } else {
      switch( widget.info.state ) {
        case StateStatsExtension.Draw:
          return StatsExtensionDraw(widget.info);
        case StateStatsExtension.Cards:
          return StatsExtensionCards(widget.info);
        case StateStatsExtension.GlobalStats:
          return StatsExtensionsPage(stats: sData.stats!, data: sData);
        default :
          throw Exception("Bad Id of panel");
      }
    }
  }
}
