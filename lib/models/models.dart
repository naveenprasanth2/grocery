class ExpenseRecord {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  ExpenseRecord({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
  };

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => ExpenseRecord(
    id: json['id'],
    title: json['title'],
    amount: json['amount']?.toDouble() ?? 0.0,
    date: DateTime.parse(json['date']),
    category: json['category'] ?? 'Other',
  );
}

class ShoppingHistory {
  final String id;
  final List<TileItem> items;
  final DateTime date;
  final double totalAmount;
  final String storeName;

  ShoppingHistory({
    required this.id,
    required this.items,
    required this.date,
    required this.totalAmount,
    this.storeName = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'items': items.map((item) => item.toJson()).toList(),
    'date': date.toIso8601String(),
    'totalAmount': totalAmount,
    'storeName': storeName,
  };

  factory ShoppingHistory.fromJson(Map<String, dynamic> json) =>
      ShoppingHistory(
        id: json['id'],
        items: (json['items'] as List)
            .map((item) => TileItem.fromJson(item))
            .toList(),
        date: DateTime.parse(json['date']),
        totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
        storeName: json['storeName'] ?? '',
      );
}

class TileItem {
  String title;
  bool isChecked;
  double price;
  int quantity;

  TileItem({
    required this.title,
    this.isChecked = false,
    this.price = 0.0,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isChecked': isChecked,
    'price': price,
    'quantity': quantity,
  };

  factory TileItem.fromJson(Map<String, dynamic> json) => TileItem(
    title: json['title'],
    isChecked: json['isChecked'] ?? false,
    price: json['price']?.toDouble() ?? 0.0,
    quantity: json['quantity']?.toInt() ?? 1,
  );

  double get totalPrice => price * quantity;
}
