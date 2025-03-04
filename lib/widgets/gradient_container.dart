import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  final Widget scaffold;

  const GradientContainer({super.key, required this.scaffold});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x0A0015FA), // 4% opacity
            Color(0xFFB700FF),
          ],
          stops: [0.0, 1.0], // 0% and 100%
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: scaffold,
    );
  }
}
