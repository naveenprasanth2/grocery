class GroceryItem {
  final String id;
  final String title;
  final bool isChecked;
  final double price;
  final int quantity;
  final DateTime createdAt;

  GroceryItem({
    String? id,
    required this.title,
    this.isChecked = false,
    this.price = 0.0,
    this.quantity = 1,
    DateTime? createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  GroceryItem copyWith({
    String? id,
    String? title,
    bool? isChecked,
    double? price,
    int? quantity,
    DateTime? createdAt,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isChecked: isChecked ?? this.isChecked,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isChecked': isChecked,
    'price': price,
    'quantity': quantity,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
    id: json['id'],
    title: json['title'],
    isChecked: json['isChecked'] ?? false,
    price: (json['price'] ?? 0.0).toDouble(),
    quantity: json['quantity'] ?? 1,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroceryItem &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          isChecked == other.isChecked &&
          price == other.price &&
          quantity == other.quantity;

  @override
  int get hashCode =>
      title.hashCode ^ isChecked.hashCode ^ price.hashCode ^ quantity.hashCode;

  @override
  String toString() {
    return 'GroceryItem(title: $title, isChecked: $isChecked, price: $price, quantity: $quantity)';
  }
}

// For backward compatibility
typedef TileItem = GroceryItem;
