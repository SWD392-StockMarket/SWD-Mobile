import 'package:flutter/material.dart';

class SearchControllerApp with ChangeNotifier {
  final TextEditingController controller = TextEditingController();

  void updateSearch(String value) {
    print("Search: $value");
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
