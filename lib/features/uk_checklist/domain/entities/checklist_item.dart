// Model for UK moving checklist items

class ChecklistItem {
  final String id;
  final String title;
  final String category;
  final bool isChecked;
  final String? notes;
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isPriority;

  ChecklistItem({
    String? id,
    required this.title,
    required this.category,
    this.isChecked = false,
    this.notes,
    this.dueDate,
    DateTime? createdAt,
    this.isPriority = false,
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
  );

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
    return 'ChecklistItem(title: $title, category: $category, isChecked: $isChecked)';
  }
}
