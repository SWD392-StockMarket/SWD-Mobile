import 'package:flutter/material.dart';

class CustomEntityWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor; // Add a background color property

  const CustomEntityWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.backgroundColor = Colors.white, // Default background color
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Container(
        padding: const EdgeInsets.all(12.0), // Add padding inside the container
        decoration: BoxDecoration(
          color: backgroundColor, // Set background color
          borderRadius: BorderRadius.circular(10), // Optional: rounded corners
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
