import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_app/struct/document_enums.dart';
import 'package:study_docs_app/struct/document_model.dart';
import 'package:study_docs_app/struct/subject_model.dart';

void main() {
  group('Domain Layer: Subject Model Tests', () {
    test('Subject toMap and fromMap should be consistent', () {
      final subject = Subject(
        id: 'subj_test_1',
        name: 'Lập trình Di động',
        code: 'CSE441',
        colorHex: '#00796B',
        iconName: 'code',
        semester: 'HK1 - 2026',
      );

      final map = subject.toMap();
      expect(map['id'], 'subj_test_1');
      expect(map['name'], 'Lập trình Di động');
      expect(map['code'], 'CSE441');

      final reconstructed = Subject.fromMap(map);
      expect(reconstructed.id, subject.id);
      expect(reconstructed.name, subject.name);
      expect(reconstructed.code, subject.code);
      expect(reconstructed.colorHex, subject.colorHex);
    });

    test('Subject copyWith updates fields properly', () {
      final subject = Subject(
        id: 'subj_1',
        name: 'Mạng Máy tính',
        code: 'CSE484',
      );

      final updated = subject.copyWith(name: 'Mạng Nâng Cao', colorHex: '#1976D2');
      expect(updated.id, 'subj_1');
      expect(updated.name, 'Mạng Nâng Cao');
      expect(updated.code, 'CSE484');
      expect(updated.colorHex, '#1976D2');
    });
  });

  group('Domain Layer: Document Model Tests', () {
    test('Document toMap and fromMap should retain all attributes', () {
      final doc = Document(
        id: 'doc_test_1',
        title: 'Báo cáo Bài tập Lớn TH1',
        description: 'Mô tả bài thực hành',
        subjectId: 'subj_test_1',
        documentType: DocumentType.assignment,
        fileFormat: DocumentFormat.docx,
        filePath: 'docs/test.docx',
        fileSizeBytes: 204800,
        isFavorite: true,
        status: DocumentStatus.inProgress,
        priority: DocumentPriority.high,
        dueDate: DateTime(2026, 10, 15),
        tags: ['TH1', 'Cashew'],
      );

      final map = doc.toMap();
      expect(map['id'], 'doc_test_1');
      expect(map['title'], 'Báo cáo Bài tập Lớn TH1');
      expect(map['document_type'], 'assignment');
      expect(map['file_format'], 'docx');
      expect(map['is_favorite'], 1);
      expect(map['status'], 'in_progress');
      expect(map['priority'], 'high');

      final fromMapDoc = Document.fromMap(map);
      expect(fromMapDoc.id, doc.id);
      expect(fromMapDoc.title, doc.title);
      expect(fromMapDoc.documentType, DocumentType.assignment);
      expect(fromMapDoc.fileFormat, DocumentFormat.docx);
      expect(fromMapDoc.isFavorite, isTrue);
      expect(fromMapDoc.status, DocumentStatus.inProgress);
      expect(fromMapDoc.tags, contains('TH1'));
    });

    test('Document copyWith should update specified fields without mutation', () {
      final doc = Document(
        id: 'doc_1',
        title: 'Slide Bài Giảng 1',
        subjectId: 'subj_1',
        documentType: DocumentType.lecture,
      );

      final updated = doc.copyWith(
        title: 'Slide Bài Giảng 1 (Đã cập nhật)',
        status: DocumentStatus.completed,
        isFavorite: true,
      );

      expect(updated.id, 'doc_1');
      expect(updated.title, 'Slide Bài Giảng 1 (Đã cập nhật)');
      expect(updated.status, DocumentStatus.completed);
      expect(updated.isFavorite, isTrue);
      expect(doc.status, DocumentStatus.newDoc); // Gốc không bị sửa đổi (Immutable)
    });
  });

  group('Domain Layer: Enums Extensions Tests', () {
    test('DocumentType string parser and display names', () {
      expect(DocumentTypeExtension.fromString('lecture'), DocumentType.lecture);
      expect(DocumentTypeExtension.fromString('assignment'), DocumentType.assignment);
      expect(DocumentTypeExtension.fromString('reference'), DocumentType.reference);
      expect(DocumentTypeExtension.fromString('exam'), DocumentType.exam);
      expect(DocumentTypeExtension.fromString('note'), DocumentType.note);

      expect(DocumentType.lecture.displayName, 'Bài giảng');
      expect(DocumentType.assignment.displayName, 'Bài tập');
    });

    test('DocumentFormat string parser', () {
      expect(DocumentFormatExtension.fromString('pdf'), DocumentFormat.pdf);
      expect(DocumentFormatExtension.fromString('docx'), DocumentFormat.docx);
      expect(DocumentFormatExtension.fromString('pptx'), DocumentFormat.pptx);
      expect(DocumentFormatExtension.fromString('link'), DocumentFormat.link);
    });

    test('DocumentStatus conversions', () {
      expect(DocumentStatusExtension.fromString('new'), DocumentStatus.newDoc);
      expect(DocumentStatusExtension.fromString('in_progress'), DocumentStatus.inProgress);
      expect(DocumentStatusExtension.fromString('completed'), DocumentStatus.completed);
    });
  });
}
