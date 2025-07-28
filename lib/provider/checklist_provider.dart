import 'package:flutter/material.dart';
import 'package:grocery/provider/title_item.dart';

class CheckBoxModel extends ChangeNotifier {
  final List<TileItem> _items = [];

  List<TileItem> get items => _items;

  int get count => _items.length;

  void addItem(String title) {
    _items.add(TileItem(title: title));
    notifyListeners();
  }

  void toggle(int index, bool value) {
    _items[index].isChecked = value;
    notifyListeners();
  }
}
