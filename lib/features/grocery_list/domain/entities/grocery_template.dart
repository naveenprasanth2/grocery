class GroceryTemplateItem {
  final String title;
  final int quantity;

  GroceryTemplateItem({required this.title, required this.quantity});

  Map<String, dynamic> toJson() => {'title': title, 'quantity': quantity};

  factory GroceryTemplateItem.fromJson(Map<String, dynamic> json) =>
      GroceryTemplateItem(
        title: json['title'],
        quantity: json['quantity'] ?? 1,
      );
}

class GroceryTemplate {
  final String id;
  final String name;
  final List<GroceryTemplateItem> items;

  GroceryTemplate({required this.id, required this.name, required this.items});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'items': items.map((e) => e.toJson()).toList(),
  };

  factory GroceryTemplate.fromJson(Map<String, dynamic> json) =>
      GroceryTemplate(
        id: json['id'],
        name: json['name'],
        items: (json['items'] as List)
            .map((e) => GroceryTemplateItem.fromJson(e))
            .toList(),
      );
}
