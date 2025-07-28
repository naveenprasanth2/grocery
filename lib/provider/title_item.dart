class TileItem {
  String title;
  bool isChecked;

  TileItem({required this.title, this.isChecked = false});

  Map<String, dynamic> toJson() => {'title': title, 'isChecked': isChecked};

  factory TileItem.fromJson(Map<String, dynamic> json) =>
      TileItem(title: json['title'], isChecked: json['isChecked'] ?? false);
}
