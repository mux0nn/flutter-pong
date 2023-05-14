import 'package:flutter/material.dart';

class Ball extends StatelessWidget {
  Ball({super.key});

  int position = -1;

  void initalizeBall() {
    position = 16;
  }

  void moveBall(int value) {
    position += value;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
