import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../entities/checklist_item.dart';

class JsonDataService {
  static const String _defaultDataPath = 'assets/data/default_checklist.json';

  /// Load default checklist data from assets
  static Future<List<ChecklistItem>> loadDefaultData() async {
    try {
      final String jsonString = await rootBundle.loadString(_defaultDataPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ChecklistItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading default data: $e');
      return _getFallbackData();
    }
  }

  /// Load external JSON data (from API, file, etc.)
  static List<ChecklistItem> loadFromJsonString(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ChecklistItem.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error parsing JSON data: $e');
      return [];
    }
  }

  /// Merge external data with local data, giving preference to local
  static List<ChecklistItem> mergeWithLocalData(
    List<ChecklistItem> localItems,
    List<ChecklistItem> externalItems,
  ) {
    final Map<String, ChecklistItem> mergedMap = {};

    // First, add all external items
    for (final item in externalItems) {
      mergedMap[item.title.toLowerCase()] = item;
    }

    // Then, override with local items (giving preference to local data)
    for (final localItem in localItems) {
      final key = localItem.title.toLowerCase();
      if (mergedMap.containsKey(key)) {
        // Merge: keep local status but update other fields from external if needed
        final externalItem = mergedMap[key]!;
        mergedMap[key] = externalItem.copyWith(
          isChecked: localItem.isChecked, // Local preference
          isBought: localItem.isBought, // Local preference
          notes: localItem.notes?.isNotEmpty == true
              ? localItem.notes
              : externalItem.notes,
          dueDate: localItem.dueDate ?? externalItem.dueDate,
          isPriority: localItem.isPriority || externalItem.isPriority,
        );
      } else {
        // Add local item that doesn't exist in external data
        mergedMap[key] = localItem;
      }
    }

    return mergedMap.values.toList();
  }

  /// Export current data to JSON string
  static String exportToJsonString(List<ChecklistItem> items) {
    final List<Map<String, dynamic>> jsonList = items
        .map((item) => item.toJson())
        .toList();
    return json.encode(jsonList);
  }

  /// Fallback data if JSON loading fails
  static List<ChecklistItem> _getFallbackData() {
    return [
      // Essential tasks
      ChecklistItem(
        title: 'Valid passport',
        category: 'Documents',
        isPriority: true,
        type: ItemType.task,
      ),
      ChecklistItem(
        title: 'UK visa documentation',
        category: 'Documents',
        isPriority: true,
        type: ItemType.task,
      ),
      ChecklistItem(
        title: 'Open UK bank account',
        category: 'Finance',
        isPriority: true,
        type: ItemType.task,
      ),
      ChecklistItem(
        title: 'Find accommodation',
        category: 'Housing',
        isPriority: true,
        type: ItemType.task,
      ),

      // Essential products
      ChecklistItem(
        title: 'UK power adapters',
        category: 'Personal Items',
        price: 15.0,
        quantity: 2,
        type: ItemType.product,
      ),
      ChecklistItem(
        title: 'Travel insurance',
        category: 'Finance',
        price: 50.0,
        type: ItemType.product,
      ),
      ChecklistItem(
        title: 'International SIM card',
        category: 'Utilities',
        price: 20.0,
        type: ItemType.product,
      ),
    ];
  }
}
