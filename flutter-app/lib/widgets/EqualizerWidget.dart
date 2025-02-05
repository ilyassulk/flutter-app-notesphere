import 'dart:math';

import 'package:flutter/material.dart';

/// Простейший Equalizer (анимация)
class EqualizerWidget extends StatefulWidget {
  const EqualizerWidget({Key? key}) : super(key: key);

  @override
  _EqualizerWidgetState createState() => _EqualizerWidgetState();
}

class _EqualizerWidgetState extends State<EqualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(duration: Duration(milliseconds: 500), vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _randomHeight() => 10 + _random.nextDouble() * 30;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                width: 5,
                height: _randomHeight(),
                color: Theme.of(context).primaryColor,
              );
            }),
          );
        },
      ),
    );
  }
}