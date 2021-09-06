import 'dart:async';

import 'package:flutter/material.dart';

class CustomRadioController {
  List<CustomRadio> _radios = [];
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
    _radios.forEach((element) {
      element.activate(value);
    });

    // Call custom action
    onChange(value);
  }
}

class CustomRadio extends StatefulWidget {
  final CustomRadioController controller;
  final Widget widget;
  final dynamic value;
  final StreamController<dynamic> afterChange = StreamController<dynamic>();

  CustomRadio({required this.value, required this.controller, required this.widget}) {
    controller.register(this);
  }

  void activate(cmpValue) {
    afterChange.add(cmpValue);
  }

  void _closeEvent() {
    afterChange.close();
  }

  @override
  _CustomRadioState createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  bool _activate = false;

  @override
  void initState() {
    _activate = widget.controller.currentValue == widget.value;

    widget.afterChange.stream.listen((cmpValue) {
      setState(() {
        _activate = cmpValue == widget.value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.unregister(widget);
    widget._closeEvent();
    super.dispose();
  }

  void refresh() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /*
      constraints: BoxConstraints(
        maxWidth: 55.0,
      ),
       */
      padding: EdgeInsets.all(1.0),
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