import 'package:flutter/material.dart';
import 'package:statitikcard/screen/stats/statView.dart';
import 'package:statitikcard/services/internationalization.dart';

SimpleDialog createOptionDialog(BuildContext context, options) {
  return SimpleDialog(
    title: Center(child: Text(StatitikLocale.of(context).read('H_T2'), style: Theme.of(context).textTheme.headline3)),
    contentPadding: EdgeInsets.symmetric(horizontal: 10),
    children: [StatsOptions(options)]
  );
}

class StatsOptions extends StatefulWidget {
  final StatsViewOptions options;

  StatsOptions(options) : this.options = options;

  @override
  _StatsOptionsState createState() => _StatsOptionsState();
}

class _StatsOptionsState extends State<StatsOptions> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(StatitikLocale.of(context).read('S_B17'), style: Theme.of(context).textTheme.headline5),
          RadioListTile<OptionShowState>(
            title: Text(StatitikLocale.of(context).read('S_B16')),
            value: OptionShowState.RealCount,
            groupValue: widget.options.showOption,
            onChanged: (newValue) {
              setState(() {
                widget.options.showOption = newValue!;
              });
            },
          ),
          RadioListTile<OptionShowState>(
            title: Text(StatitikLocale.of(context).read('S_B15')),
            value: OptionShowState.BoosterLuck,
            groupValue: widget.options.showOption,
            onChanged: (newValue) {
              setState(() {
                widget.options.showOption = newValue!;
              });
            },
          ),
          Text(StatitikLocale.of(context).read('S_B18'), style: Theme.of(context).textTheme.headline5),
          RadioListTile<bool>(
            title: Text(StatitikLocale.of(context).read('S_B10')),
            value: true,
            groupValue: widget.options.delta,
            onChanged: (newValue) {
              setState(() {
                widget.options.delta = newValue!;
              });
            },
          ),
          RadioListTile<bool>(
            title: Text(StatitikLocale.of(context).read('S_B19')),
            value: false,
            groupValue: widget.options.delta,
            onChanged: (newValue) {
              setState(() {
                widget.options.delta = newValue!;
              });
            },
          ),
        ]
        ),
    );
  }
}
