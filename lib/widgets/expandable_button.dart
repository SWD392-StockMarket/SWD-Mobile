import 'package:flutter/material.dart';

class ExpandableButton extends StatefulWidget {
  final Icon icon;
  final List<Widget> children;

  const ExpandableButton({
    super.key,
    required this.icon,
    required this.children,
  });

  @override
  State<ExpandableButton> createState() => _ExpandableButtonState();
}

class _ExpandableButtonState extends State<ExpandableButton> {
  bool isExpanded = false;

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Main button with icon
        IconButton(
          icon: widget.icon,
          onPressed: toggleExpand,
        ),

        // Expandable content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Wrap(
            spacing: 8.0, // Space between items
            children: widget.children.map((child) {
              return SizedBox(
                width: 120, // Limit width of each item
                child: child,
              );
            }).toList(),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
