import 'package:flutter/material.dart';
import 'package:statitikcard/l10n/statitik_localizations.dart';

import 'package:statitikcard/screenOld/stats/stat_view.dart';

SimpleDialog createOptionDialog(BuildContext context, options) {
  return SimpleDialog(
    title: Center(child: Text(AppLocalizations.of(context)!.h_t2, style: Theme.of(context).textTheme.displaySmall)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
    children: [StatsOptions(options)]
  );
}

class StatsOptions extends StatefulWidget {
  final StatsViewOptions options;

  const StatsOptions(this.options, {super.key});

  @override
  State<StatsOptions> createState() => _StatsOptionsState();
}

class _StatsOptionsState extends State<StatsOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocalizations.of(context)!.s_b17, style: Theme.of(context).textTheme.headlineSmall),
        RadioListTile<OptionShowState>(
          title: Text(AppLocalizations.of(context)!.s_b16),
          value: OptionShowState.realCount,
          groupValue: widget.options.showOption,
          onChanged: (newValue) {
            setState(() {
              widget.options.showOption = newValue!;
            });
          },
        ),
        RadioListTile<OptionShowState>(
          title: Text(AppLocalizations.of(context)!.s_b15),
          value: OptionShowState.boosterLuck,
          groupValue: widget.options.showOption,
          onChanged: (newValue) {
            setState(() {
              widget.options.showOption = newValue!;
            });
          },
        ),
        Text(AppLocalizations.of(context)!.s_b18, style: Theme.of(context).textTheme.headlineSmall),
        RadioListTile<bool>(
          title: Text(AppLocalizations.of(context)!.s_b10),
          value: true,
          groupValue: widget.options.delta,
          onChanged: (newValue) {
            setState(() {
              widget.options.delta = newValue!;
            });
          },
        ),
        RadioListTile<bool>(
          title: Text(AppLocalizations.of(context)!.s_b19),
          value: false,
          groupValue: widget.options.delta,
          onChanged: (newValue) {
            setState(() {
              widget.options.delta = newValue!;
            });
          },
        ),
      ]
    );
  }
}
