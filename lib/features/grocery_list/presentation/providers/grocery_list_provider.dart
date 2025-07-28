import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/grocery_item.dart';

class GroceryListProvider extends ChangeNotifier {
  final List<GroceryItem> _items = [];
  static const String _prefsKey = 'grocery_items';

  List<GroceryItem> get items => _items;
  int get count => _items.length;

  double get totalCost =>
      _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get completedCost => _items
      .where((item) => item.isChecked)
      .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

  double get remainingCost => totalCost - completedCost;

  int get completedCount => _items.where((item) => item.isChecked).length;
  int get remainingCount => count - completedCount;

  GroceryListProvider() {
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
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _items.clear();
        _items.addAll(jsonList.map((e) => GroceryItem.fromJson(e)).toList());
        notifyListeners();
      } catch (e) {
        // Handle parsing errors gracefully
        debugPrint('Error loading grocery items: $e');
      }
    }
  }

  void addItem(String title, {double price = 0.0, int quantity = 1}) {
    final item = GroceryItem(title: title, price: price, quantity: quantity);
    _items.add(item);
    _saveToPrefs();
    notifyListeners();
  }

  void deleteItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void updateItem(int index, String newTitle, {double? price, int? quantity}) {
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(
        title: newTitle,
        price: price,
        quantity: quantity,
      );
      _saveToPrefs();
      notifyListeners();
    }
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
    if (index >= 0 && index < _items.length) {
      _items[index] = _items[index].copyWith(isChecked: value);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearCompleted() {
    _items.removeWhere((item) => item.isChecked);
    _saveToPrefs();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  List<GroceryItem> getFilteredItems({
    String? searchQuery,
    String? categoryFilter,
    bool showOnlyUnchecked = false,
  }) {
    return _items.where((item) {
      // Text search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!item.title.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Category filter (implement category logic)
      if (categoryFilter != null && categoryFilter != 'All') {
        // Add category filtering logic here
      }

      // Show only unchecked filter
      if (showOnlyUnchecked && item.isChecked) {
        return false;
      }

      return true;
    }).toList();
  }
}

// For backward compatibility
typedef CheckBoxModel = GroceryListProvider;
