// Model for UK moving checklist items and products
class ChecklistItem {
  final String id;
  final String title;
  final String category;
  final bool isChecked;
  final String? notes;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isPriority;
  final double price;
  final int quantity;
  final ItemType type; // New field to distinguish between tasks and products
  final bool isBought; // For products - whether they've been purchased

  ChecklistItem({
    String? id,
    required this.title,
    required this.category,
    this.isChecked = false,
    this.notes,
    this.dueDate,
    DateTime? createdAt,
    this.isPriority = false,
    this.price = 0.0,
    this.quantity = 1,
    this.type = ItemType.task,
    this.isBought = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now();

  ChecklistItem copyWith({
    String? id,
    String? title,
    String? category,
    bool? isChecked,
    String? notes,
    DateTime? dueDate,
    DateTime? createdAt,
    bool? isPriority,
    double? price,
    int? quantity,
    ItemType? type,
    bool? isBought,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      isChecked: isChecked ?? this.isChecked,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      isPriority: isPriority ?? this.isPriority,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      type: type ?? this.type,
      isBought: isBought ?? this.isBought,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'isChecked': isChecked,
    'notes': notes,
    'dueDate': dueDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isPriority': isPriority,
    'price': price,
    'quantity': quantity,
    'type': type.toString().split('.').last,
    'isBought': isBought,
  };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    id: json['id'],
    title: json['title'],
    category: json['category'],
    isChecked: json['isChecked'] ?? false,
    notes: json['notes'],
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    isPriority: json['isPriority'] ?? false,
    price: (json['price'] ?? 0.0).toDouble(),
    quantity: json['quantity'] ?? 1,
    type: ItemType.values.firstWhere(
      (e) => e.toString().split('.').last == (json['type'] ?? 'task'),
      orElse: () => ItemType.task,
    ),
    isBought: json['isBought'] ?? false,
  );

  double get totalCost => price * quantity;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChecklistItem(title: $title, category: $category, type: $type, isChecked: $isChecked, isBought: $isBought)';
  }
}

enum ItemType {
  task, // Regular checklist tasks
  product, // Products that need to be purchased
}
