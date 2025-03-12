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
            Color(0xFF1A1A1A), // Dark gray
            Color(0xFF3A3A3A), // Slightly lighter gray for reflection effect
          ],
          stops: [0.2, 1], // Gradual transition
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: scaffold,
    );
  }
}
