import 'package:flutter/material.dart';

class Pixel extends StatelessWidget {
  final color;

  const Pixel({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
    );
  }
}
