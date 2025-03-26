import 'package:flutter/material.dart';

class SearchControllerApp with ChangeNotifier {
  final TextEditingController controller = TextEditingController();
  String searchQuery = '';

  void updateSearch(String value) {
    searchQuery = value.toLowerCase();
    notifyListeners();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
