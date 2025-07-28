import 'package:flutter/material.dart';

class CheckBoxModel extends ChangeNotifier {
  bool _isChecked = false;

  bool get isChecked => _isChecked;

  void toggle(bool value) {
    _isChecked = value;
    notifyListeners();
  }
}
