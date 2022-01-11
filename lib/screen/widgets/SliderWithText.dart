import 'package:flutter/material.dart';
import 'dart:math';

class SliderWithTextThumb extends SliderComponentShape {
  final double thumbRadius;
  final dynamic sliderValue;

  const SliderWithTextThumb({
    required this.thumbRadius,
    required this.sliderValue,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {

    final Canvas canvas = context.canvas;

    int sides = 4;
    double innerPolygonRadius = thumbRadius * 1.2;
    double outerPolygonRadius = thumbRadius * 1.4;
    double angle = (pi * 2) / sides;

    // Paint out
    final outerPathColor = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;

    var outerPath = Path();

    Offset startPoint2 = Offset(
      outerPolygonRadius * cos(0.0),
      outerPolygonRadius * sin(0.0),
    );

    outerPath.moveTo(
      startPoint2.dx + center.dx,
      startPoint2.dy + center.dy,
    );

    for (int i = 1; i <= sides; i++) {
      double x = outerPolygonRadius * cos(angle * i) + center.dx;
      double y = outerPolygonRadius * sin(angle * i) + center.dy;
      outerPath.lineTo(x, y);
    }

    outerPath.close();
    canvas.drawPath(outerPath, outerPathColor);

    // Paint in
    final innerPathColor = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.black
      ..style = PaintingStyle.fill;

    var innerPath = Path();

    Offset startPoint = Offset(
      innerPolygonRadius * cos(0.0),
      innerPolygonRadius * sin(0.0),
    );

    innerPath.moveTo(
      startPoint.dx + center.dx,
      startPoint.dy + center.dy,
    );

    for (int i = 1; i <= sides; i++) {
      double x = innerPolygonRadius * cos(angle * i) + center.dx;
      double y = innerPolygonRadius * sin(angle * i) + center.dy;
      innerPath.lineTo(x, y);
    }

    innerPath.close();
    canvas.drawPath(innerPath, innerPathColor);

    // Paint text
    TextSpan span = new TextSpan(
      style: new TextStyle(
        fontSize: thumbRadius,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      text: sliderValue.round().toString(),
    );

    TextPainter tp = new TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();

    Offset textCenter = Offset(
      center.dx - (tp.width / 2),
      center.dy - (tp.height / 2),
    );

    tp.paint(canvas, textCenter);
  }
}

class SliderInfoController {
  var     functionValue;
  var     functionChanged;

  SliderInfoController(this.functionValue, this.functionChanged);
}

class SliderInfo extends StatefulWidget {
  final SliderInfoController controller;
  final dynamic minValue;
  final dynamic maxValue;
  final int? division;
  const SliderInfo(this.controller, this.minValue, this.maxValue, {this.division});

  @override
  _SliderInfoState createState() => _SliderInfoState();
}

class _SliderInfoState extends State<SliderInfo> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          thumbShape: SliderWithTextThumb(
            thumbRadius: 15.0,
            sliderValue: widget.controller.functionValue(),
          ),
        ),
        child: Slider(
          value: widget.controller.functionValue(),
          min: widget.minValue.toDouble(),
          max: widget.maxValue.toDouble(),
          divisions: widget.division,
          onChanged: (double value) {
            setState(() {
              widget.controller.functionChanged(value);
            }
            );
          },
        )
    );
  }
}
