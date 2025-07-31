import 'dart:convert';

class GroceryHistory {
  final String id;
  final String name;
  final DateTime date;
  final List<String> items;

  GroceryHistory({required this.id, required this.name, required this.date, required this.items});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'items': items,
      };

  factory GroceryHistory.fromJson(Map<String, dynamic> json) => GroceryHistory(
        id: json['id'],
        name: json['name'],
        date: DateTime.parse(json['date']),
        items: (json['items'] as List).map((e) => e.toString()).toList(),
      );
}
