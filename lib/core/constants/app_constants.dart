import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'UK Moving Checklist';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A comprehensive checklist app for organizing your move to the United Kingdom.';

  // Colors
  static const Color primaryColor = Color(0xFF1976D2); // Royal Blue
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardColor = Colors.white;

  // Category Colors
  static final Map<String, Color> categoryColors = {
    'Documents': Colors.blue.shade600,
    'Housing': Colors.green.shade600,
    'Finance': Colors.purple.shade600,
    'Healthcare': Colors.red.shade600,
    'Employment': Colors.amber.shade700,
    'Transportation': Colors.orange.shade600,
    'Education': Colors.indigo.shade600,
    'Personal Items': Colors.teal.shade600,
    'Utilities': Colors.cyan.shade600,
    'Social & Networking': Colors.deepPurple.shade600,
  };

  // Category Icons
  static const Map<String, IconData> categoryIcons = {
    'All': Icons.apps,
    'Documents': Icons.description,
    'Housing': Icons.home,
    'Finance': Icons.account_balance,
    'Healthcare': Icons.local_hospital,
    'Employment': Icons.work,
    'Transportation': Icons.commute,
    'Education': Icons.school,
    'Personal Items': Icons.luggage,
    'Utilities': Icons.lightbulb,
    'Social & Networking': Icons.people,
  };

  // UK Checklist Task Suggestions
  static const List<String> taskSuggestions = [
    'Passport',
    'Visa',
    'Birth Certificate',
    'NHS Registration',
    'Bank Account',
    'National Insurance Number',
    'Accommodation',
    'Job Search',
    'Transport Card',
    'Mobile Phone Plan',
    'Internet Setup',
    'Shipping Items',
    'Register with GP',
    'School Application',
    'CV/Resume Update',
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

  static const List<String> grocerySuggestions = [
    'Milk',
    'Bread',
    'Eggs',
    'Butter',
    'Cheese',
    'Yogurt',
    'Chicken',
    'Rice',
    'Apples',
    'Bananas',
    'Tomatoes',
    'Onions',
    'Potatoes',
    'Carrots',
    'Spinach',
    'Orange Juice',
    'Coffee',
    'Tea',
    'Cereal',
    'Pasta',
    'Oil',
  ];
}
