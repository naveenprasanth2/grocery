import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class CheckBoxModel extends ChangeNotifier {
  final List<TileItem> _items = [];
  static const String _prefsKey = 'grocery_items';

  List<TileItem> get items => _items;
  int get count => _items.length;

  double get totalCost =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get completedCost => _items
      .where((item) => item.isChecked)
      .fold(0.0, (sum, item) => sum + item.totalPrice);
  double get remainingCost => totalCost - completedCost;

  CheckBoxModel() {
    _loadFromPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((item) => item.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(jsonList));
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _items.clear();
      _items.addAll(jsonList.map((e) => TileItem.fromJson(e)).toList());
      notifyListeners();
    }
  }

  void addItem(String title, {double price = 0.0, int quantity = 1}) {
    _items.add(TileItem(title: title, price: price, quantity: quantity));
    _saveToPrefs();
    notifyListeners();
  }

  void deleteItem(int index) {
    _items.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  void updateItem(int index, String newTitle, {double? price, int? quantity}) {
    _items[index] = TileItem(
      title: newTitle,
      isChecked: _items[index].isChecked,
      price: price ?? _items[index].price,
      quantity: quantity ?? _items[index].quantity,
    );
    _saveToPrefs();
    notifyListeners();
  }

  void moveItem(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _items.length ||
        newIndex < 0 ||
        newIndex >= _items.length) {
      return; // Invalid indices
    }
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    _saveToPrefs();
    notifyListeners();
  }

  void toggle(int index, bool value) {
    _items[index].isChecked = value;
    _saveToPrefs();
    notifyListeners();
  }
}
