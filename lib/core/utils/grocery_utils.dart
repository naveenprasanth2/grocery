import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class CategoryUtils {
  /// Categorizes an item based on its name
  static String categorizeItem(String itemName) {
    final name = itemName.toLowerCase();
    
    if (['milk', 'cheese', 'butter', 'yogurt', 'cream'].any(name.contains)) {
      return 'Dairy';
    }
    if (['chicken', 'beef', 'pork', 'fish', 'meat'].any(name.contains)) {
      return 'Meat';
    }
    if (['apple', 'banana', 'orange', 'grape', 'berry'].any(name.contains)) {
      return 'Fruits';
    }
    if (['tomato', 'onion', 'potato', 'carrot', 'lettuce'].any(name.contains)) {
      return 'Vegetables';
    }
    if (['rice', 'bread', 'pasta', 'cereal', 'flour'].any(name.contains)) {
      return 'Grains';
    }
    if (['coffee', 'tea', 'juice', 'soda', 'water'].any(name.contains)) {
      return 'Beverages';
    }
    
    return 'Other';
  }

  /// Gets the color for a category
  static Color getCategoryColor(String category) {
    return AppConstants.categoryColors[category] ?? Colors.grey.shade600;
  }

  /// Gets the icon for a category
  static IconData getCategoryIcon(String category) {
    return AppConstants.categoryIcons[category] ?? Icons.shopping_basket;
  }
}

class GroceryUtils {
  /// Formats an item title with quantity and price
  static String formatItemTitle(String name, int quantity, {double? price}) {
    String formattedTitle = '$name ($quantity)';
    if (price != null && price > 0) {
      formattedTitle += ' - \$${price.toStringAsFixed(2)}';
    }
    return formattedTitle;
  }

  /// Extracts the name from a formatted item title
  static String extractItemName(String title) {
    return title.split(' (').first;
  }

  /// Extracts the quantity from a formatted item title
  static String extractQuantity(String title) {
    if (title.contains('(')) {
      return title.split('(').last.split(')').first;
    }
    return '1';
  }

  /// Generates a shopping list text for sharing
  static String generateShareText(List<dynamic> items) {
    String shareText = '🛒 My Shopping List:\n\n';
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      shareText += '${i + 1}. ${item.title} ${item.isChecked ? '✅' : '⭕'}\n';
    }
    shareText += '\nShared from My Grocery App 📱';
    return shareText;
  }
}
