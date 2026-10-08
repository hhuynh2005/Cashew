import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_app/struct/firebase_storage_service.dart';

void main() {
  group('Lớp Cloud Storage: FirebaseStorageService Tests (Nhóm trưởng Huỳnh)', () {
    late FirebaseStorageService storageService;

    setUp(() {
      storageService = FirebaseStorageService();
      storageService.forceMockMode = true; // Ép dùng Mock mode khi Unit Test
      storageService.clearMockStorage();
    });

    test('1. Chuẩn hóa đường dẫn lưu trữ Storage Path theo kiến trúc phân tầng', () {
      final path = FirebaseStorageService.buildStoragePath(
        uploaderUid: 'user_tlu_123',
        documentId: 'doc_dms_999',
        fileName: 'Bai Giang Kien Truc (Cashew).pdf',
      );

      expect(path, startsWith('documents/user_tlu_123/doc_dms_999/'));
      expect(path.contains('('), isFalse, reason: 'Ký tự ngoặc đơn phải được chuẩn hóa');
      expect(path.endsWith('.pdf'), isTrue);
    });

    test('2. Tự động nhận diện MIME Type cho các định dạng tài liệu học tập', () {
      expect(FirebaseStorageService.detectMimeType('tailieu.pdf'), equals('application/pdf'));
      expect(FirebaseStorageService.detectMimeType('baocao.docx'),
          equals('application/vnd.openxmlformats-officedocument.wordprocessingml.document'));
      expect(FirebaseStorageService.detectMimeType('slide.pptx'),
          equals('application/vnd.openxmlformats-officedocument.presentationml.presentation'));
      expect(FirebaseStorageService.detectMimeType('bangdiem.xlsx'),
          equals('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'));
      expect(FirebaseStorageService.detectMimeType('sodo.png'), equals('image/png'));
      expect(FirebaseStorageService.detectMimeType('hinhanh.jpg'), equals('image/jpeg'));
      expect(FirebaseStorageService.detectMimeType('source_code.zip'), equals('application/zip'));
    });

    test('3. Upload tài liệu lên Cloud Storage thành công và nhận Download URL', () async {
      final dummyBytes = Uint8List.fromList(utf8.encode('Nội dung tài liệu học tập CSE441 Thủy Lợi'));
      final progressValues = <double>[];

      final result = await storageService.uploadDocumentFile(
        uploaderUid: 'student_2351170599',
        documentId: 'doc_kien_truc_01',
        fileName: 'GiaoTrinh_KienTrucPhanMem.pdf',
        bytes: dummyBytes,
        onProgress: (p) => progressValues.add(p),
        customMetadata: {
          'subjectCode': 'CSE441',
          'academicYear': '2026-2027',
        },
      );

      expect(result.downloadUrl, contains(FirebaseStorageService.defaultBucket));
      expect(result.storagePath, contains('student_2351170599'));
      expect(result.fileSizeBytes, equals(dummyBytes.length));
      expect(result.contentType, equals('application/pdf'));
      expect(result.metadata['subjectCode'], equals('CSE441'));
      expect(result.metadata['appSource'], equals('StudyDocs-Cashew-Group16'));

      // Kiểm tra tiến trình tải lên được kích hoạt
      expect(progressValues, isNotEmpty);
      expect(progressValues.last, equals(1.0));
      expect(storageService.isFileInMockStorage(result.storagePath), isTrue);
    });

    test('4. Kiểm tra tải lại nội dung tệp (Download) và lấy URL', () async {
      final dummyBytes = Uint8List.fromList(utf8.encode('Dữ liệu tải xuống kiểm thử'));
      final uploadResult = await storageService.uploadDocumentFile(
        uploaderUid: 'tuan_letuan',
        documentId: 'doc_download_test',
        fileName: 'file_test.txt',
        bytes: dummyBytes,
      );

      final downloadedBytes = await storageService.downloadFileBytes(uploadResult.storagePath);
      expect(utf8.decode(downloadedBytes), equals('Dữ liệu tải xuống kiểm thử'));

      final url = await storageService.getDownloadUrl(uploadResult.storagePath);
      expect(url, equals(uploadResult.downloadUrl));
    });

    test('5. Xóa tệp tài liệu trên Cloud Storage thành công', () async {
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final uploadResult = await storageService.uploadDocumentFile(
        uploaderUid: 'user_delete',
        documentId: 'doc_to_delete',
        fileName: 'sample.pdf',
        bytes: dummyBytes,
      );

      expect(storageService.isFileInMockStorage(uploadResult.storagePath), isTrue);

      final deleteSuccess = await storageService.deleteDocumentFile(uploadResult.storagePath);
      expect(deleteSuccess, isTrue);
      expect(storageService.isFileInMockStorage(uploadResult.storagePath), isFalse);
    });

    test('6. Validation từ chối khi tên tệp rỗng hoặc dữ liệu byte 0 bytes', () async {
      final validBytes = Uint8List.fromList([1, 2, 3]);

      // Tên file rỗng
      expect(
        () => storageService.uploadDocumentFile(
          uploaderUid: 'uid_test',
          documentId: 'doc_test',
          fileName: '',
          bytes: validBytes,
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Byte dữ liệu rỗng
      expect(
        () => storageService.uploadDocumentFile(
          uploaderUid: 'uid_test',
          documentId: 'doc_test',
          fileName: 'valid.pdf',
          bytes: Uint8List(0),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('7. Từ chối tệp vượt quá kích thước bảo mật quy định (50MB)', () async {
      // Giả lập dung lượng > 50MB (50MB + 10 bytes)
      final largeBytes = Uint8List(50 * 1024 * 1024 + 10);

      expect(
        () => storageService.uploadDocumentFile(
          uploaderUid: 'uid_test',
          documentId: 'doc_large',
          fileName: 'oversized_file.zip',
          bytes: largeBytes,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
