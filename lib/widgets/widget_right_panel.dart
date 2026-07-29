import 'package:flutter/material.dart';

class RightNavigationBar extends StatefulWidget {
  final Widget child;
  final Size   size;

  const RightNavigationBar({required this.size, required this.child, super.key});

  @override
  State<RightNavigationBar> createState() => _RightNavigationBarState();
}

class _RightNavigationBarState extends State<RightNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: FractionalOffset.centerRight,
      child: Container(
        color: Colors.blueGrey,
      //height: _size.,
        width: widget.size.width,
        child: widget.child,
      ),
    );
  }
}