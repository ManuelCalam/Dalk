import 'package:flutter/material.dart';

class MockUserProvider extends ChangeNotifier {
  bool isLoaded = false;

  void loadUser() {
    isLoaded = true;
    notifyListeners();
  }

  void clearUser() {
    isLoaded = false;
    notifyListeners();
  }
}