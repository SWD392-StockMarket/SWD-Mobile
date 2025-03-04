import 'package:flutter/material.dart';

class CustomEntityList extends StatelessWidget {
  final List<Widget> entities;

  const CustomEntityList({super.key, required this.entities});

  @override
  Widget build(BuildContext context) {
    if (entities.isEmpty) {
      return const Center(
        child: Text(
          "Your list is empty, Please create one.",
          style: TextStyle(fontSize: 16, color: Colors.white),
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
