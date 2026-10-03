class StudyDocument {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String fileName;
  final String fileType;
  final DateTime updatedAt;
  final List<String> tags;

  const StudyDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.fileName,
    required this.fileType,
    required this.updatedAt,
    this.tags = const [],
  });

  StudyDocument copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    String? fileName,
    String? fileType,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return StudyDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  bool matchesQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return true;
    }

    final haystack = [
      title,
      category,
      summary,
      fileName,
      ...tags,
    ].join(' ').toLowerCase();

    return haystack.contains(normalizedQuery);
  }
}
