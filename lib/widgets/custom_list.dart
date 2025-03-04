import 'package:flutter/material.dart';

class CustomEntityList extends StatelessWidget {
  final List<Widget> entities;

  const CustomEntityList({super.key, required this.entities});

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return const SizedBox.expand(
        child: Center(
          child: Text(
            "Your list is empty, Please create one.",
            style: TextStyle(fontSize: 30, color: Colors.white),
            textAlign: TextAlign.center, // Ensures text is centered properly
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: false, // Allows scrolling
      physics: const BouncingScrollPhysics(), // Enables smooth scrolling
      itemCount: entities.length,
      itemBuilder: (context, index) {
        return entities[index];
      },
      separatorBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 2,
          color: Colors.transparent,
        );
      },
    );
  }
}
