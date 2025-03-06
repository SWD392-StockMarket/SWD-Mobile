import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onIconPressed;

  const GradientAppBar({
    super.key,
    required this.title,
    this.icon,
    this.onIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 30),
      ),
      centerTitle: icon == null, // Center title if there's no icon
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: icon != null
          ? [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Center(
            child: IconButton(
              onPressed: onIconPressed ?? () {},
              icon: Icon(icon, color: Colors.white, size: 30),
            ),
          ),
        )
      ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
