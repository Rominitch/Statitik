import 'dart:async';

import 'package:flutter/material.dart';

class CustomRadioController {
  final List<CustomRadio> _radios = [];
  Function  onChange;
  dynamic   currentValue;

  CustomRadioController({required this.onChange});

  void register(CustomRadio cr) {
    if(currentValue == cr.value) {
      cr.activate(cr.value);
    }
    _radios.add(cr);
  }

  void unregister(CustomRadio cr) {
    _radios.remove(cr);
  }

  void afterPress(value) {
    currentValue = value;
    // Refresh all radio
    refresh();

    // Call custom action
    onChange(value);
  }

  void refresh() {
    for (var element in _radios) {
      element.activate(currentValue);
    }
  }
}

class CustomRadio extends StatefulWidget {
  final CustomRadioController controller;
  final Widget widget;
  final dynamic value;
  final StreamController<dynamic> afterChange = StreamController<dynamic>();
  final double? widthBox;

  CustomRadio({required this.value, required this.controller, required this.widget, this.widthBox, Key? key}) : super(key: key) {
    controller.register(this);
  }

  void activate(cmpValue) {
    afterChange.add(cmpValue);
  }

  @override
  State<CustomRadio> createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  bool _activate = false;

  @override
  void initState() {
    _activate = widget.controller.currentValue == widget.value;

    widget.afterChange.stream.listen((cmpValue) {
      if( !widget.afterChange.isClosed ) {
        setState(() {
          _activate = cmpValue == widget.value;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.unregister(widget);
    widget.afterChange.close();
    super.dispose();
  }

  void refresh() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.widthBox,
      padding: const EdgeInsets.all(1.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: _activate ? Colors.green : Colors.grey[800],
        ),
        child: widget.widget,
        onPressed: () {
          setState(() {
            widget.controller.afterPress(widget.value);
          });
        },
      ),
    );
  }
}