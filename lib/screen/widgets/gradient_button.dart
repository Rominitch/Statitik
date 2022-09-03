import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double? width;
  final double? height;
  final Function() onPressed;

  const GradientButton( this.child, this.onPressed, {
    this.gradient = const LinearGradient(colors: [Colors.grey, Colors.grey]),
    this.width,
    this.height, Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(4.0)),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
          child: child,
        ),
      ),
    );
  }
}