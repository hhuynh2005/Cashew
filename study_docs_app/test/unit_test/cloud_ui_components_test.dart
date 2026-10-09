import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_app/struct/document_enums.dart';
import 'package:study_docs_app/struct/document_model.dart';
import 'package:study_docs_app/widgets/cloud_sync_badge.dart';
import 'package:study_docs_app/widgets/cloud_transfer_progress.dart';
import 'package:study_docs_app/widgets/offline_mode_indicator.dart';

/// Bộ kiểm thử Đơn vị (Unit Test) & Widget Test cho phân hệ Cloud UI & Indicators
/// Dự án: Ứng dụng Quản lý Tài liệu Học tập (StudyDocs DMS)
/// Phụ trách: NGUYỄN TRUNG KIÊN (MSV: 2251172394) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
/// Nhánh Git: kien-cloud-ui
void main() {
  group('1. Kiểm thử Logic Trạng thái Cloud Sync (CloudSyncStatus Enum)', () {
    test('TC-SYNC-01: Kiểm tra mapping ID và DisplayName của CloudSyncStatus', () {
      expect(CloudSyncStatus.synced.id, equals('synced'));
      expect(CloudSyncStatus.synced.displayName, equals('Đã đồng bộ Cloud'));
      expect(CloudSyncStatus.synced.shortLabel, equals('Cloud Sync'));

      expect(CloudSyncStatus.syncing.id, equals('syncing'));
      expect(CloudSyncStatus.syncing.shortLabel, equals('Đồng bộ'));

      expect(CloudSyncStatus.pending.id, equals('pending'));
      expect(CloudSyncStatus.pending.shortLabel, equals('Chờ tải'));

      expect(CloudSyncStatus.offline.id, equals('offline'));
      expect(CloudSyncStatus.offline.displayName, equals('Lưu cục bộ (Offline)'));

      expect(CloudSyncStatus.error.id, equals('error'));
      expect(CloudSyncStatus.error.displayName, equals('Lỗi đồng bộ'));
    });

    test('TC-SYNC-02: Kiểm tra hàm chuyển đổi CloudSyncStatusExtension.fromString', () {
      expect(CloudSyncStatusExtension.fromString('synced'), equals(CloudSyncStatus.synced));
      expect(CloudSyncStatusExtension.fromString('SYNCING'), equals(CloudSyncStatus.syncing));
      expect(CloudSyncStatusExtension.fromString('pending'), equals(CloudSyncStatus.pending));
      expect(CloudSyncStatusExtension.fromString('offline'), equals(CloudSyncStatus.offline));
      expect(CloudSyncStatusExtension.fromString('error'), equals(CloudSyncStatus.error));
      // Fallback khi dữ liệu không hợp lệ
      expect(CloudSyncStatusExtension.fromString('unknown'), equals(CloudSyncStatus.synced));
      expect(CloudSyncStatusExtension.fromString(null), equals(CloudSyncStatus.synced));
    });

    test('TC-SYNC-03: Kiểm tra tự động suy diễn cloudSyncStatus từ Document Model', () {
      // 1. Tài liệu có fileUrl trên đám mây -> Synced
      final cloudDoc = Document(
        id: 'doc-1',
        title: 'Slide KTPM Cloud',
        subjectId: 'sub-1',
        documentType: DocumentType.lecture,
        fileUrl: 'https://storage.googleapis.com/test.pdf',
      );
      expect(cloudDoc.cloudSyncStatus, equals(CloudSyncStatus.synced));

      // 2. Tài liệu chỉ có filePath cục bộ trên máy -> Pending
      final localDoc = Document(
        id: 'doc-2',
        title: 'Bai tap SQL',
        subjectId: 'sub-1',
        documentType: DocumentType.assignment,
        filePath: 'local/storage/sql.docx',
      );
      expect(localDoc.cloudSyncStatus, equals(CloudSyncStatus.pending));

      // 3. Tài liệu không có tệp đính kèm -> Offline
      final textDoc = Document(
        id: 'doc-3',
        title: 'Ghi chu buoi hoc',
        subjectId: 'sub-1',
        documentType: DocumentType.note,
      );
      expect(textDoc.cloudSyncStatus, equals(CloudSyncStatus.offline));

      // 4. Tài liệu được gán tường minh trạng thái
      final explicitDoc = cloudDoc.copyWith(cloudSyncStatus: CloudSyncStatus.error);
      expect(explicitDoc.cloudSyncStatus, equals(CloudSyncStatus.error));
    });
  });

  group('2. Kiểm thử Giao diện Widget Huy hiệu Cloud (CloudSyncBadge Widget)', () {
    testWidgets('TC-UI-01: CloudSyncBadge hiển thị đủ Icon và Text ở chế độ đầy đủ',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CloudSyncBadge(
              status: CloudSyncStatus.synced,
              compact: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
      expect(find.text('Cloud Sync'), findsOneWidget);
    });

    testWidgets('TC-UI-02: CloudSyncBadge thu gọn ở chế độ compact (chỉ hiển thị Icon)',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CloudSyncBadge(
              status: CloudSyncStatus.pending,
              compact: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
      expect(find.text('Chờ tải'), findsNothing);
    });
  });

  group('3. Kiểm thử Chỉ báo Ngoại tuyến (OfflineModeIndicator Widget)', () {
    testWidgets('TC-UI-03: OfflineModeIndicator hiển thị trạng thái Online đúng',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineModeIndicator(
              isOffline: false,
              pendingSyncCount: 0,
            ),
          ),
        ),
      );

      expect(find.text('Đám Mây Sẵn Sàng (Online)'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
    });

    testWidgets('TC-UI-04: OfflineModeIndicator hiển thị cảnh báo Ngoại tuyến và số lượng chờ tải',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineModeIndicator(
              isOffline: true,
              pendingSyncCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('Chế độ Ngoại Tuyến (Offline)'), findsOneWidget);
      expect(find.text('3 chờ tải'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('4. Kiểm thử Thanh Tiến Trình Tải Tệp (CloudTransferProgress Widget)', () {
    testWidgets('TC-UI-05: CloudTransferProgress hiển thị đúng phần trăm, tốc độ và nút tương tác',
        (tester) async {
      bool pausePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CloudTransferProgress(
              type: TransferType.upload,
              fileName: 'BaoCao_KienTruc_DMS.pdf',
              totalBytes: 10 * 1024 * 1024, // 10 MB
              transferredBytes: 5 * 1024 * 1024, // 5 MB -> 50%
              status: TransferStatus.transferring,
              speedText: '3.5 MB/s',
              etaText: '~1s',
              onPause: () => pausePressed = true,
            ),
          ),
        ),
      );

      expect(find.text('BaoCao_KienTruc_DMS.pdf'), findsOneWidget);
      expect(find.textContaining('50%'), findsOneWidget);
      expect(find.textContaining('3.5 MB/s'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.pause_circle_outline_rounded));
      expect(pausePressed, isTrue);
    });

    testWidgets('TC-UI-06: CloudTransferProgress hiển thị trạng thái hoàn tất 100%',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CloudTransferProgress(
              type: TransferType.download,
              fileName: 'Lecture_Cloud.pdf',
              totalBytes: 2 * 1024 * 1024,
              transferredBytes: 2 * 1024 * 1024,
              status: TransferStatus.completed,
            ),
          ),
        ),
      );

      expect(find.text('Hoàn tất 100%'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });
  });
}
