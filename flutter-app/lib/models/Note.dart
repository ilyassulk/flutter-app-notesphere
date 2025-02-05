class Note {
  final int id;
  /// Если folderId == 0, значит заметка не привязана к папке (например, создана из распознавания речи)
  final int folderId;
  String title;
  String content;
  DateTime lastModified;
  late List<String> tags;

  Note({
    required this.id,
    required this.folderId,
    required this.title,
    required this.content,
    required this.lastModified,
    this.tags = const [],
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    folderId: json['folderId'],
    title: json['title'],
    content: json['content'],
    lastModified: DateTime.parse(json['lastModified']),
    tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'folderId': folderId,
    'title': title,
    'content': content,
    'lastModified': lastModified.toIso8601String(),
    'tags': tags,
  };

  String get preview =>
      content.length > 50 ? content.substring(0, 50) + "..." : content;
}