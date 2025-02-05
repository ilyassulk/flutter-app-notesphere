class Folder {
  final int id;
  String name;
  bool isExpanded;

  Folder({
    required this.id,
    required this.name,
    this.isExpanded = true,
  });

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
    id: json['id'],
    name: json['name'],
    isExpanded: json['isExpanded'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isExpanded': isExpanded,
  };
}