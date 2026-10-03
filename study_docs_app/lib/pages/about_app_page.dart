import 'package:flutter/material.dart';

/// Màn hình Thông tin Đồ án TH1 & Giải trình Kiến trúc Cashew
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo Cáo Kiến Trúc & Tác Giả'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner Đồ án TH1
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF004D40), const Color(0xFF00796B)]
                    : [const Color(0xFF00796B), const Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BÀI THỰC HÀNH TH1',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          Text(
                            'Quản Lý Tài Liệu Học Tập',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ứng dụng được thiết kế và triển khai tuân thủ nghiêm ngặt các nguyên lý của Kiến trúc Cashew: Local-First, Phân tách 4 lớp độc lập, Reactive Stream Watchers và DeleteLogs audit.',
                  style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Thông tin Sinh viên thực hiện
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Thông Tin Sinh Viên Thực Hiện',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Họ và tên:', 'Nguyễn Văn Huỳnh'),
                  _buildInfoRow('Mã sinh viên:', '2351170599'),
                  _buildInfoRow('Lớp:', '65KTPM - Khoa CNTT'),
                  _buildInfoRow('Trường:', 'Trường Đại học Thủy Lợi (TLU)'),
                  _buildInfoRow('Môn học:', 'Lập trình Thiết bị Di động (CSE441)'),
                  _buildInfoRow('Đề tài:', 'TH1: Quản lý tài liệu theo kiến trúc Cashew'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 5 Mục Checklist đã hoàn thiện
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist_rounded, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text(
                        'Tiến Độ Checklist 5 Mục TH1',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildChecklistItem(
                    '1. Phân tích yêu cầu & Thiết kế sơ đồ luồng dữ liệu (DFD, Sequence)',
                    true,
                  ),
                  _buildChecklistItem(
                    '2. Thiết lập cấu trúc thư mục & Phân lớp hệ thống theo chuẩn Cashew',
                    true,
                  ),
                  _buildChecklistItem(
                    '3. Triển khai chức năng cốt lõi: Thêm, Sửa, Xóa, Tìm kiếm tài liệu',
                    true,
                  ),
                  _buildChecklistItem(
                    '4. Kiểm thử tính đúng đắn phân tách logic giữa các lớp (100% Pass)',
                    true,
                  ),
                  _buildChecklistItem(
                    '5. Đóng gói mã nguồn & Viết báo cáo giải trình chi tiết',
                    true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Phân tích Kiến trúc 4 tầng Cashew
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.layers_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'Mô Hình Phân Lớp Kiến Trúc Cashew',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildLayerCard(
                    title: '1. Presentation Layer (Tầng hiển thị)',
                    folder: 'lib/pages/ & lib/widgets/',
                    desc:
                        'Chứa các màn hình hoàn chỉnh (Dashboard, List, Detail, Search, Form) và các widget tái sử dụng. Sử dụng Provider để rebuild giao diện khi State thay đổi.',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  _buildLayerCard(
                    title: '2. Domain / Business Logic Layer',
                    folder: 'lib/struct/',
                    desc:
                        'Chứa Entities (Document, Subject), Enums, DocumentRepository thực thi validation nghiệp vụ và State Provider quản lý bộ lọc.',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 8),
                  _buildLayerCard(
                    title: '3. Data Access Layer (Tầng truy cập CSDL)',
                    folder: 'lib/database/',
                    desc:
                        'SQLite AppDatabase singleton, câu lệnh DDL, CRUD, Reactive Stream Controllers (watchAllDocuments, watchStats) và bảng delete_logs để audit delta.',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                  _buildLayerCard(
                    title: '4. Persistence / Local Storage',
                    folder: 'SQLite study_documents.db',
                    desc:
                        'Cơ sở dữ liệu SQLite lưu trực tiếp trên thiết bị (documents, subjects, delete_logs, app_settings), hoạt động 100% offline-first.',
                    color: Colors.amber.shade800,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 18,
            color: isDone ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerCard({
    required String title,
    required String folder,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  folder,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 12, height: 1.3),
          ),
        ],
      ),
    );
  }
}
