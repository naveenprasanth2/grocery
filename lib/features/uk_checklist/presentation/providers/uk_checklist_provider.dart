import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/checklist_item.dart';

class UKChecklistProvider extends ChangeNotifier {
  final List<ChecklistItem> _items = [];
  List<String> _categories = [];
  static const String _prefsKey = 'uk_checklist_items';
  static const String _categoriesPrefsKey = 'uk_checklist_categories';

  List<ChecklistItem> get items => _items;
  List<String> get categories => _categories;

  int get totalItems => _items.length;
  int get completedItems => _items.where((item) => item.isChecked).length;
  int get remainingItems => totalItems - completedItems;

  double get completionPercentage =>
      totalItems == 0 ? 0 : (completedItems / totalItems * 100);

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
      // Remove all items with this category or reassign them
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
  }) {
    final item = ChecklistItem(
      title: title,
      category: category,
      notes: notes,
      dueDate: dueDate,
      isPriority: isPriority,
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

  void toggleChecked(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        isChecked: !_items[index].isChecked,
      );
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

  List<ChecklistItem> getFilteredItems({
    String? searchQuery,
    String? categoryFilter,
    bool showOnlyUnchecked = false,
    bool showOnlyPriority = false,
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

      // Show only unchecked filter
      if (showOnlyUnchecked && item.isChecked) {
        return false;
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
    'Social & Networking',
  ];

  void populateWithDefaultItems() {
    if (_items.isNotEmpty) return; // Don't add items if there are already items

    final defaultItems = _getDefaultChecklistItems();
    _items.addAll(defaultItems);
    _saveToPrefs();
    notifyListeners();
  }

  List<ChecklistItem> _getDefaultChecklistItems() {
    return [
      // Documents
      ChecklistItem(
        title: 'Valid passport',
        category: 'Documents',
        isPriority: true,
      ),
      ChecklistItem(
        title: 'UK visa or settlement documentation',
        category: 'Documents',
        isPriority: true,
      ),
      ChecklistItem(title: 'Birth certificate', category: 'Documents'),
      ChecklistItem(
        title: 'Marriage/divorce certificates',
        category: 'Documents',
      ),
      ChecklistItem(title: 'Academic qualifications', category: 'Documents'),
      ChecklistItem(title: 'Medical records', category: 'Documents'),
      ChecklistItem(title: 'Driving license', category: 'Documents'),
      ChecklistItem(title: 'COVID vaccination records', category: 'Documents'),

      // Housing
      ChecklistItem(title: 'Research UK rental market', category: 'Housing'),
      ChecklistItem(
        title: 'Set up temporary accommodation',
        category: 'Housing',
        isPriority: true,
      ),
      ChecklistItem(title: 'Find long-term housing', category: 'Housing'),
      ChecklistItem(
        title: 'Arrange property viewing appointments',
        category: 'Housing',
      ),
      ChecklistItem(
        title: 'Understand UK rental agreements',
        category: 'Housing',
      ),
      ChecklistItem(title: 'Set up renters insurance', category: 'Housing'),
      ChecklistItem(
        title: 'Arrange furniture/essential items',
        category: 'Housing',
      ),

      // Finance
      ChecklistItem(
        title: 'Open UK bank account',
        category: 'Finance',
        isPriority: true,
      ),
      ChecklistItem(
        title: 'Register for National Insurance Number',
        category: 'Finance',
        isPriority: true,
      ),
      ChecklistItem(
        title: 'Set up direct debits for bills',
        category: 'Finance',
      ),
      ChecklistItem(title: 'Transfer savings/investments', category: 'Finance'),
      ChecklistItem(title: 'Research UK tax system', category: 'Finance'),
      ChecklistItem(
        title: 'Notify tax authorities in home country',
        category: 'Finance',
      ),
      ChecklistItem(
        title: 'Set up international money transfers',
        category: 'Finance',
      ),

      // Healthcare
      ChecklistItem(
        title: 'Register with local GP',
        category: 'Healthcare',
        isPriority: true,
      ),
      ChecklistItem(title: 'Register with NHS', category: 'Healthcare'),
      ChecklistItem(title: 'Find local dentist', category: 'Healthcare'),
      ChecklistItem(
        title: 'Arrange prescriptions for existing conditions',
        category: 'Healthcare',
      ),
      ChecklistItem(
        title: 'Purchase private health insurance (if needed)',
        category: 'Healthcare',
      ),

      // Employment
      ChecklistItem(
        title: 'Update CV/resume for UK job market',
        category: 'Employment',
      ),
      ChecklistItem(
        title: 'Research job opportunities',
        category: 'Employment',
      ),
      ChecklistItem(
        title: 'Register with recruitment agencies',
        category: 'Employment',
      ),
      ChecklistItem(
        title: 'Understand UK employment rights',
        category: 'Employment',
      ),
      ChecklistItem(
        title: 'Set up LinkedIn profile for UK networking',
        category: 'Employment',
      ),

      // Transportation
      ChecklistItem(
        title: 'Research local public transport options',
        category: 'Transportation',
      ),
      ChecklistItem(
        title: 'Get Oyster card (London) or local equivalent',
        category: 'Transportation',
      ),
      ChecklistItem(
        title: 'Apply for UK driving license (if needed)',
        category: 'Transportation',
      ),
      ChecklistItem(
        title: 'Research car insurance options',
        category: 'Transportation',
      ),

      // Education
      ChecklistItem(title: 'Research local schools', category: 'Education'),
      ChecklistItem(
        title: 'Apply for school places for children',
        category: 'Education',
      ),
      ChecklistItem(
        title: 'Prepare educational records for transfer',
        category: 'Education',
      ),
      ChecklistItem(
        title: 'Look into language courses if needed',
        category: 'Education',
      ),

      // Personal Items
      ChecklistItem(
        title: 'Organize shipping of belongings',
        category: 'Personal Items',
        isPriority: true,
      ),
      ChecklistItem(
        title: 'Declutter before moving',
        category: 'Personal Items',
      ),
      ChecklistItem(
        title: 'Purchase UK power adapters',
        category: 'Personal Items',
      ),
      ChecklistItem(
        title: 'Pack essential items for first few weeks',
        category: 'Personal Items',
        isPriority: true,
      ),
      ChecklistItem(
        title: 'Arrange storage solutions if needed',
        category: 'Personal Items',
      ),

      // Utilities
      ChecklistItem(
        title: 'Research mobile phone plans',
        category: 'Utilities',
      ),
      ChecklistItem(
        title: 'Set up internet service',
        category: 'Utilities',
        isPriority: true,
      ),
      ChecklistItem(
        title: 'Arrange electricity/gas connections',
        category: 'Utilities',
      ),
      ChecklistItem(title: 'Set up water service', category: 'Utilities'),

      // Social & Networking
      ChecklistItem(
        title: 'Research expat communities in your area',
        category: 'Social & Networking',
      ),
      ChecklistItem(
        title: 'Join local community groups',
        category: 'Social & Networking',
      ),
      ChecklistItem(
        title: 'Set up social media for UK connections',
        category: 'Social & Networking',
      ),
      ChecklistItem(
        title: 'Research local cultural activities',
        category: 'Social & Networking',
      ),
    ];
  }
}
