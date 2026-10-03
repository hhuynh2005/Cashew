import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_app/functions.dart';

void main() {
  group('AppFunctions Utility Tests', () {
    test('formatDate should return formatted string or fallback', () {
      final date = DateTime(2026, 10, 3);
      expect(AppFunctions.formatDate(date), '03/10/2026');
      expect(AppFunctions.formatDate(null), 'Không có');
    });

    test('formatFileSize converts bytes correctly', () {
      expect(AppFunctions.formatFileSize(0), '0 KB');
      expect(AppFunctions.formatFileSize(null), '0 KB');
      expect(AppFunctions.formatFileSize(500), '500 B');
      expect(AppFunctions.formatFileSize(1024), '1.0 KB');
      expect(AppFunctions.formatFileSize(1024 * 1024 * 2), '2.00 MB');
      expect(AppFunctions.formatFileSize(1024 * 1024 * 1024), '1.00 GB');
    });

    test('removeVietnameseDiacritics removes accents accurately', () {
      expect(
        AppFunctions.removeVietnameseDiacritics('Lập trình Di động'),
        'lap trinh di dong',
      );
      expect(
        AppFunctions.removeVietnameseDiacritics('Kiến trúc Cashew Phân tầng'),
        'kien truc cashew phan tang',
      );
    });

    test('matchesSearch performs accent-insensitive search', () {
      const text = 'Slide Bài giảng Lập trình Di động Flutter';
      expect(AppFunctions.matchesSearch(text, 'lap trinh'), isTrue);
      expect(AppFunctions.matchesSearch(text, 'FLUTTER'), isTrue);
      expect(AppFunctions.matchesSearch(text, 'bài giảng'), isTrue);
      expect(AppFunctions.matchesSearch(text, 'bai giang'), isTrue);
      expect(AppFunctions.matchesSearch(text, 'Java'), isFalse);
    });

    test('isValidUrl validates HTTP and HTTPS links', () {
      expect(AppFunctions.isValidUrl('https://flutter.dev'), isTrue);
      expect(AppFunctions.isValidUrl('http://example.com/doc.pdf'), isTrue);
      expect(AppFunctions.isValidUrl('ftp://example.com'), isFalse);
      expect(AppFunctions.isValidUrl('not a url'), isFalse);
      expect(AppFunctions.isValidUrl(''), isFalse);
      expect(AppFunctions.isValidUrl(null), isFalse);
    });
  });
}
