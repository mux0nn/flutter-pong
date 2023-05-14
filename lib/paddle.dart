import 'package:flutter/material.dart';

class Paddle extends StatelessWidget {
  Paddle({super.key});

  List<int> position = [];

  void initalizePaddle() {
    position = [
      136,
      137,
      138,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
