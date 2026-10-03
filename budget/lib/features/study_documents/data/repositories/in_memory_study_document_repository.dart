import '../../domain/entities/study_document.dart';
import '../../domain/repositories/study_document_repository.dart';

class InMemoryStudyDocumentRepository implements StudyDocumentRepository {
  final List<StudyDocument> _documents = [
    StudyDocument(
      id: 'doc-1',
      title: 'Giới thiệu lập trình Dart',
      category: 'Lập trình',
      summary: 'Tổng hợp các khái niệm nền tảng cho sinh viên bắt đầu với Dart và Flutter.',
      fileName: 'dart-fundamentals.pdf',
      fileType: 'PDF',
      updatedAt: DateTime(2026, 9, 18),
      tags: ['dart', 'flutter', 'nền tảng'],
    ),
    StudyDocument(
      id: 'doc-2',
      title: 'Bài tập hệ quản trị cơ sở dữ liệu',
      category: 'Cơ sở dữ liệu',
      summary: 'Bộ bài tập thực hành về SQL, tối ưu truy vấn và thiết kế dữ liệu.',
      fileName: 'database-exercise.docx',
      fileType: 'DOCX',
      updatedAt: DateTime(2026, 9, 22),
      tags: ['sql', 'database', 'bài tập'],
    ),
  ];

  @override
  List<StudyDocument> getAll() => List.unmodifiable(_documents);

  @override
  StudyDocument? getById(String id) {
    return _documents.firstWhereOrNull((document) => document.id == id);
  }

  @override
  void save(StudyDocument document) {
    final index = _documents.indexWhere((item) => item.id == document.id);
    if (index >= 0) {
      _documents[index] = document;
      return;
    }

    _documents.add(document);
  }

  @override
  void delete(String id) {
    _documents.removeWhere((document) => document.id == id);
  }

  @override
  List<StudyDocument> search(String query) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return getAll();
    }

    return _documents
        .where((document) => document.matchesQuery(normalizedQuery))
        .toList(growable: false);
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
