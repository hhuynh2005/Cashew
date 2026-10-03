import 'dart:convert';
import 'document_enums.dart';

/// Thực thể Tài liệu học tập (Document Entity)
class Document {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final DocumentType documentType;
  final DocumentFormat fileFormat;
  final String? filePath;
  final String? fileUrl;
  final int fileSizeBytes;
  final bool isFavorite;
  final DocumentStatus status;
  final DocumentPriority priority;
  final DateTime? dueDate;
  final List<String> tags;
  final DateTime dateCreated;
  final DateTime dateModified;

  Document({
    required this.id,
    required this.title,
    this.description = '',
    required this.subjectId,
    required this.documentType,
    this.fileFormat = DocumentFormat.pdf,
    this.filePath,
    this.fileUrl,
    this.fileSizeBytes = 0,
    this.isFavorite = false,
    this.status = DocumentStatus.newDoc,
    this.priority = DocumentPriority.medium,
    this.dueDate,
    List<String>? tags,
    DateTime? dateCreated,
    DateTime? dateModified,
  })  : tags = tags ?? const [],
        dateCreated = dateCreated ?? DateTime.now(),
        dateModified = dateModified ?? DateTime.now();

  /// Chuyển đổi sang Map để lưu trữ trong SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject_id': subjectId,
      'document_type': documentType.id,
      'file_format': fileFormat.id,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size_bytes': fileSizeBytes,
      'is_favorite': isFavorite ? 1 : 0,
      'status': status.id,
      'priority': priority.id,
      'due_date': dueDate?.toIso8601String(),
      'tags': jsonEncode(tags),
      'date_created': dateCreated.toIso8601String(),
      'date_modified': dateModified.toIso8601String(),
    };
  }

  /// Khởi tạo Document từ Map lấy từ SQLite
  factory Document.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['tags'] as String);
        if (decoded is List) {
          parsedTags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedTags = [];
      }
    }

    return Document(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      subjectId: map['subject_id'] as String,
      documentType: DocumentTypeExtension.fromString(map['document_type'] as String?),
      fileFormat: DocumentFormatExtension.fromString(map['file_format'] as String?),
      filePath: map['file_path'] as String?,
      fileUrl: map['file_url'] as String?,
      fileSizeBytes: (map['file_size_bytes'] as num?)?.toInt() ?? 0,
      isFavorite: (map['is_favorite'] == 1 || map['is_favorite'] == true),
      status: DocumentStatusExtension.fromString(map['status'] as String?),
      priority: DocumentPriorityExtension.fromString(map['priority'] as String?),
      dueDate: map['due_date'] != null
          ? DateTime.tryParse(map['due_date'] as String)
          : null,
      tags: parsedTags,
      dateCreated: map['date_created'] != null
          ? DateTime.tryParse(map['date_created'] as String) ?? DateTime.now()
          : DateTime.now(),
      dateModified: map['date_modified'] != null
          ? DateTime.tryParse(map['date_modified'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Tạo bản sao với các thuộc tính được cập nhật
  Document copyWith({
    String? id,
    String? title,
    String? description,
    String? subjectId,
    DocumentType? documentType,
    DocumentFormat? fileFormat,
    String? filePath,
    String? fileUrl,
    int? fileSizeBytes,
    bool? isFavorite,
    DocumentStatus? status,
    DocumentPriority? priority,
    DateTime? dueDate,
    List<String>? tags,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      documentType: documentType ?? this.documentType,
      fileFormat: fileFormat ?? this.fileFormat,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isFavorite: isFavorite ?? this.isFavorite,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Document && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
