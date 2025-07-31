import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/checklist_item.dart';
import '../../domain/services/json_data_service.dart';

class UKChecklistProvider extends ChangeNotifier {
  final List<ChecklistItem> _items = [];
  List<String> _categories = [];
  static const String _prefsKey = 'uk_checklist_items';
  static const String _categoriesPrefsKey = 'uk_checklist_categories';

  List<ChecklistItem> get items => _items;
  List<String> get categories => _categories;

  // Basic stats
  int get totalItems => _items.length;
  int get completedTasks => _items
      .where((item) => item.type == ItemType.task && item.isChecked)
      .length;
  int get purchasedProducts => _items
      .where((item) => item.type == ItemType.product && item.isBought)
      .length;
  int get remainingTasks => _items
      .where((item) => item.type == ItemType.task && !item.isChecked)
      .length;
  int get remainingProducts => _items
      .where((item) => item.type == ItemType.product && !item.isBought)
      .length;

  // Financial tracking
  double get totalBudget => _items
      .where((item) => item.type == ItemType.product)
      .fold(0.0, (sum, item) => sum + item.totalCost);
  double get spentAmount => _items
      .where((item) => item.type == ItemType.product && item.isBought)
      .fold(0.0, (sum, item) => sum + item.totalCost);
  double get remainingBudget => totalBudget - spentAmount;

  // Overall completion
  double get completionPercentage {
    if (totalItems == 0) return 0;
    final completed = completedTasks + purchasedProducts;
    return (completed / totalItems * 100);
  }

  UKChecklistProvider() {
    _loadFromPrefs();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((item) => item.toJson()).toList();
    await prefs.setString(_prefsKey, json.encode(jsonList));
    await prefs.setStringList(_categoriesPrefsKey, _categories);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        _items.clear();
        _items.addAll(jsonList.map((e) => ChecklistItem.fromJson(e)).toList());
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading UK checklist items: $e');
      }
    }

    final categoriesList = prefs.getStringList(_categoriesPrefsKey);
    if (categoriesList != null) {
      _categories = categoriesList;
    } else {
      _categories = defaultCategories;
      _saveToPrefs();
    }
  }

  /// Load and merge JSON data with local data
  Future<void> loadFromJson(String jsonString) async {
    try {
      final externalItems = JsonDataService.loadFromJsonString(jsonString);
      final mergedItems = JsonDataService.mergeWithLocalData(
        _items,
        externalItems,
      );

      _items.clear();
      _items.addAll(mergedItems);

      // Update categories if new ones are found
      final newCategories = mergedItems.map((item) => item.category).toSet();
      for (final category in newCategories) {
        if (!_categories.contains(category)) {
          _categories.add(category);
        }
      }

      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading JSON data: $e');
    }
  }

  /// Export current data as JSON
  String exportAsJson() {
    return JsonDataService.exportToJsonString(_items);
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void removeCategory(String category) {
    if (_categories.contains(category)) {
      _categories.remove(category);
      _items.removeWhere((item) => item.category == category);
      _saveToPrefs();
      notifyListeners();
    }
  }

  void addItem(
    String title,
    String category, {
    String? notes,
    DateTime? dueDate,
    bool isPriority = false,
    double price = 0.0,
    int quantity = 1,
    ItemType type = ItemType.task,
  }) {
    final item = ChecklistItem(
      title: title,
      category: category,
      notes: notes,
      dueDate: dueDate,
      isPriority: isPriority,
      price: price,
      quantity: quantity,
      type: type,
    );
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

  void deleteItemById(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveToPrefs();
    notifyListeners();
  }

  void updateItem(
    String id, {
    String? title,
    String? category,
    bool? isChecked,
    String? notes,
    DateTime? dueDate,
    bool? isPriority,
    double? price,
    int? quantity,
    ItemType? type,
    bool? isBought,
  }) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        title: title,
        category: category,
        isChecked: isChecked,
        notes: notes,
        dueDate: dueDate,
        isPriority: isPriority,
        price: price,
        quantity: quantity,
        type: type,
        isBought: isBought,
      );
      _saveToPrefs();
      notifyListeners();
    }
  }

  void toggleChecked(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final item = _items[index];
      if (item.type == ItemType.task) {
        _items[index] = item.copyWith(isChecked: !item.isChecked);
      } else {
        _items[index] = item.copyWith(isBought: !item.isBought);
      }
      _saveToPrefs();
      notifyListeners();
    }
  }

  void clearCompleted() {
    _items.removeWhere(
      (item) =>
          (item.type == ItemType.task && item.isChecked) ||
          (item.type == ItemType.product && item.isBought),
    );
    _saveToPrefs();
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    _saveToPrefs();
    notifyListeners();
  }

  List<ChecklistItem> getFilteredItems({
    String? searchQuery,
    String? categoryFilter,
    bool showOnlyUnchecked = false,
    bool showOnlyPriority = false,
    ItemType? typeFilter,
  }) {
    return _items.where((item) {
      // Text search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!item.title.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Category filter
      if (categoryFilter != null && categoryFilter != 'All') {
        if (item.category != categoryFilter) {
          return false;
        }
      }

      // Type filter
      if (typeFilter != null && item.type != typeFilter) {
        return false;
      }

      // Show only unchecked filter
      if (showOnlyUnchecked) {
        if (item.type == ItemType.task && item.isChecked) return false;
        if (item.type == ItemType.product && item.isBought) return false;
      }

      // Show only priority items
      if (showOnlyPriority && !item.isPriority) {
        return false;
      }

      return true;
    }).toList();
  }

  List<String> get defaultCategories => [
    'Documents',
    'Housing',
    'Finance',
    'Healthcare',
    'Employment',
    'Transportation',
    'Education',
    'Personal Items',
    'Utilities',
  ];

  void populateWithDefaultItems() async {
    if (_items.isNotEmpty) return;

    try {
      final defaultItems = await JsonDataService.loadDefaultData();
      _items.addAll(defaultItems);
      await _saveToPrefs();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading default items: $e');
    }
  }
}
