import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Smart Grocery';
  static const String appVersion = '2.0.0';
  static const String appDescription = 'A modern, feature-rich grocery shopping app with smart organization.';

  // Colors
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;
  
  // Category Colors
  static final Map<String, Color> categoryColors = {
    'Dairy': Colors.blue.shade600,
    'Meat': Colors.red.shade600,
    'Fruits': Colors.orange.shade600,
    'Vegetables': Colors.green.shade600,
    'Grains': Colors.amber.shade700,
    'Beverages': Colors.purple.shade600,
    'Other': Colors.grey.shade600,
  };

  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'All': Icons.apps,
    'Dairy': Icons.local_drink,
    'Meat': Icons.set_meal,
    'Fruits': Icons.apple,
    'Vegetables': Icons.eco,
    'Grains': Icons.grain,
    'Beverages': Icons.coffee,
    'Other': Icons.shopping_basket,
  };

  // Grocery Item Suggestions
  static const List<String> grocerySuggestions = [
    'Milk',
    'Bread',
    'Eggs',
    'Butter',
    'Cheese',
    'Yogurt',
    'Chicken',
    'Beef',
    'Apples',
    'Bananas',
    'Oranges',
    'Tomatoes',
    'Onions',
    'Potatoes',
    'Carrots',
    'Rice',
    'Pasta',
    'Olive Oil',
    'Salt',
    'Sugar',
    'Coffee',
    'Tea',
    'Cereal',
  ];

  // Shopping Templates
  static const List<Map<String, dynamic>> shoppingTemplates = [
    {
      'name': 'Weekly Groceries',
      'items': ['Milk', 'Bread', 'Eggs', 'Fruits', 'Vegetables'],
    },
    {
      'name': 'Party Supplies',
      'items': ['Chips', 'Drinks', 'Cake', 'Ice cream', 'Napkins'],
    },
    {
      'name': 'Breakfast Essentials',
      'items': ['Cereal', 'Milk', 'Bananas', 'Coffee', 'Yogurt'],
    },
    {
      'name': 'Cooking Basics',
      'items': ['Oil', 'Salt', 'Spices', 'Onions', 'Garlic'],
    },
  ];

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 600);
  static const Duration longAnimationDuration = Duration(milliseconds: 1000);

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  static const double smallBorderRadius = 8.0;
}
