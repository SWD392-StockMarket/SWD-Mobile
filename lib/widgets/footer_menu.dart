import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollableFooterMenu extends StatefulWidget {
  final List<FooterButton> buttons;

  const ScrollableFooterMenu({super.key, required this.buttons});

  @override
  ScrollableFooterMenuState createState() => ScrollableFooterMenuState();
}

class ScrollableFooterMenuState extends State<ScrollableFooterMenu> {
  int selectedIndex = 0;
  bool isExpanded = true;

  void expandFooter() {
    setState(() {
      isExpanded = true;
    });
  }

  void shrinkFooter() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isExpanded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: expandFooter,
      onPanEnd: (_) => shrinkFooter(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: isExpanded ? 70 : 47,
        padding: EdgeInsets.symmetric(vertical: isExpanded ? 8 : 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              spreadRadius: 2,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.forward) {
                expandFooter();
              }
              return true;
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(widget.buttons.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                          expandFooter();
                          widget.buttons[index].onTap();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isExpanded ? 12 : 14,
                          vertical: isExpanded ? 4 : 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.buttons[index].icon,
                              size: isExpanded ? 24 : 22,
                              color: Colors.black,
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 200),
                              child: isExpanded
                                  ? Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: SizedBox(
                                  height: 14,
                                  child: Text(
                                    widget.buttons[index].label,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FooterButton {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  FooterButton({required this.icon, required this.label, required this.onTap});
}
