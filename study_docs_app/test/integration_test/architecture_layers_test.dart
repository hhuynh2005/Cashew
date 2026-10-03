import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:study_docs_app/database/app_database.dart';
import 'package:study_docs_app/struct/document_enums.dart';
import 'package:study_docs_app/struct/document_model.dart';
import 'package:study_docs_app/struct/document_repository.dart';
import 'package:study_docs_app/struct/document_state_provider.dart';

void main() {
  // Khởi tạo sqflite FFI cho môi trường test trên Desktop/Windows
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late AppDatabase db;
  late DocumentRepository repository;
  late DocumentStateProvider provider;

  setUp(() async {
    db = await AppDatabase.initInMemory();
    repository = DocumentRepository(db: db);
    provider = DocumentStateProvider(repository: repository);
    // Đợi reactive streams phát đợt dữ liệu ban đầu
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    provider.dispose();
    db.dispose();
  });

  group('Kiểm thử Lớp 1: Persistence & Database Layer (SQLite + Watchers)', () {
    test('Khởi tạo database in-memory và tự động seed dữ liệu mẫu thành công', () async {
      final docs = await db.getAllDocuments();
      final subjects = await db.getAllSubjects();

      expect(docs.isNotEmpty, isTrue, reason: 'Phải có dữ liệu tài liệu mẫu ban đầu');
      expect(subjects.isNotEmpty, isTrue, reason: 'Phải có danh sách môn học mẫu ban đầu');
    });

    test('Thêm, Sửa tài liệu trực tiếp trên Database Layer', () async {
      final newDoc = Document(
        id: 'test_db_doc_1',
        title: 'Tài liệu thử nghiệm tầng Database',
        description: 'Kiểm thử DDL SQLite',
        subjectId: 'subj_cse441',
        documentType: DocumentType.lecture,
      );

      await db.insertDocument(newDoc);
      final retrieved = await db.getDocumentById('test_db_doc_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.title, 'Tài liệu thử nghiệm tầng Database');

      // Cập nhật
      final updated = retrieved.copyWith(title: 'Tài liệu đã cập nhật');
      await db.updateDocument(updated);

      final rechecked = await db.getDocumentById('test_db_doc_1');
      expect(rechecked!.title, 'Tài liệu đã cập nhật');
    });

    test('Xóa tài liệu phải được ghi nhận vào delete_logs (Nguyên lý Cashew Architecture)', () async {
      final docId = 'test_delete_doc';
      await db.insertDocument(Document(
        id: docId,
        title: 'Tài liệu cần xóa',
        subjectId: 'subj_cse441',
        documentType: DocumentType.note,
      ));

      // Thực hiện xóa
      await db.deleteDocument(docId);

      // 1. Kiểm tra tài liệu đã bị xóa khỏi bảng documents
      final retrieved = await db.getDocumentById(docId);
      expect(retrieved, isNull);

      // 2. Kiểm tra nhật ký xóa đã được lưu trữ trong bảng delete_logs để audit/đồng bộ delta
      final deleteLogs = await db.getDeleteLogs();
      final loggedItem = deleteLogs.firstWhere(
        (log) => log['item_id'] == docId,
        orElse: () => {},
      );
      expect(loggedItem.isNotEmpty, isTrue, reason: 'Bảng delete_logs phải ghi nhận ID đã xóa');
      expect(loggedItem['table_name'], 'documents');
    });

    test('Reactive Stream Watcher: Tự động phát dữ liệu mới khi có thao tác CRUD', () async {
      final stream = db.watchAllDocuments();
      final emissions = <List<Document>>[];

      final sub = stream.listen((data) {
        emissions.add(data);
      });

      // Tạo một tài liệu mới
      await db.insertDocument(Document(
        id: 'reactive_doc_test',
        title: 'Tài liệu kiểm tra reactive stream',
        subjectId: 'subj_cse441',
        documentType: DocumentType.exam,
      ));

      await Future.delayed(const Duration(milliseconds: 150));
      expect(emissions.isNotEmpty, isTrue);
      expect(emissions.last.any((d) => d.id == 'reactive_doc_test'), isTrue);

      await sub.cancel();
    });
  });

  group('Kiểm thử Lớp 2: Domain & Business Logic Layer (Repository Validation)', () {
    test('Validation: Từ chối tạo tài liệu khi tiêu đề rỗng', () async {
      expect(
        () async => await repository.createDocument(
          title: '   ', // Rỗng sau khi trim
          subjectId: 'subj_cse441',
          documentType: DocumentType.assignment,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Validation: Từ chối tạo tài liệu khi thiếu mã môn học', () async {
      expect(
        () async => await repository.createDocument(
          title: 'Bài tập 1',
          subjectId: '   ',
          documentType: DocumentType.assignment,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Validation: Kiểm tra tính hợp lệ của liên kết URL', () async {
      expect(
        () async => await repository.createDocument(
          title: 'Bài giảng Online',
          subjectId: 'subj_cse441',
          documentType: DocumentType.lecture,
          fileUrl: 'invalid_url_protocol://test',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Repository tạo Document với UUID v4 chuẩn và lưu thành công', () async {
      final created = await repository.createDocument(
        title: 'Bài giảng Kiến trúc Cashew Phần 1',
        description: 'Tài liệu chuẩn kiến trúc',
        subjectId: 'subj_cse441',
        documentType: DocumentType.lecture,
        fileFormat: DocumentFormat.pdf,
        fileUrl: 'https://flutter.dev/docs',
      );

      expect(created.id, isNotEmpty);
      expect(created.title, 'Bài giảng Kiến trúc Cashew Phần 1');

      final found = await repository.getDocumentById(created.id);
      expect(found, isNotNull);
      expect(found!.id, created.id);
    });
  });

  group('Kiểm thử Lớp 3: State Management Layer (Provider & Reactive Filters)', () {
    test('Lọc tài liệu theo Môn học (Subject Filter)', () async {
      provider.setSelectedSubject('subj_cse441');
      await Future.delayed(const Duration(milliseconds: 50));

      final filtered = provider.filteredDocuments;
      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((d) => d.subjectId == 'subj_cse441'), isTrue);
    });

    test('Lọc tài liệu theo Loại tài liệu (DocumentType Filter)', () async {
      provider.setSelectedType(DocumentType.assignment);
      await Future.delayed(const Duration(milliseconds: 50));

      final filtered = provider.filteredDocuments;
      expect(filtered.isNotEmpty, isTrue);
      expect(filtered.every((d) => d.documentType == DocumentType.assignment), isTrue);
    });

    test('Lọc tài liệu theo Mục yêu thích (Favorites Only)', () async {
      provider.toggleFavoritesOnly();
      await Future.delayed(const Duration(milliseconds: 50));

      final filtered = provider.filteredDocuments;
      expect(filtered.every((d) => d.isFavorite), isTrue);
    });

    test('Tìm kiếm tài liệu không phân biệt dấu tiếng Việt (Search Query)', () async {
      provider.setSearchQuery('kien truc'); // Tìm không dấu "kiến trúc"
      await Future.delayed(const Duration(milliseconds: 50));

      final filtered = provider.filteredDocuments;
      expect(filtered.isNotEmpty, isTrue);
      expect(
        filtered.any((d) => d.title.toLowerCase().contains('kiến trúc')),
        isTrue,
      );
    });

    test('Sắp xếp tài liệu theo Tiêu đề (Sort A-Z)', () async {
      provider.setSortBy('title_asc');
      await Future.delayed(const Duration(milliseconds: 50));

      final filtered = provider.filteredDocuments;
      for (int i = 0; i < filtered.length - 1; i++) {
        expect(
          filtered[i].title.toLowerCase().compareTo(filtered[i + 1].title.toLowerCase()) <= 0,
          isTrue,
        );
      }
    });

    test('Chuyển đổi trạng thái học tập qua Provider', () async {
      final doc = provider.allDocuments.first;
      await provider.updateDocumentStatus(doc.id, DocumentStatus.completed);
      await Future.delayed(const Duration(milliseconds: 100));

      final updatedDoc = provider.allDocuments.firstWhere((d) => d.id == doc.id);
      expect(updatedDoc.status, DocumentStatus.completed);
    });
  });
}
