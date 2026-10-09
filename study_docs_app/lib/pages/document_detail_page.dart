import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../functions.dart';
import '../struct/document_enums.dart';
import '../struct/document_model.dart';
import '../struct/document_state_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'add_edit_document_page.dart';

/// Màn hình Chi tiết Tài liệu học tập (Xem, Chuyển trạng thái, Sửa, Xóa)
class DocumentDetailPage extends StatelessWidget {
  final String documentId;

  const DocumentDetailPage({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentStateProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Document? doc;
    try {
      doc = provider.allDocuments.firstWhere((d) => d.id == documentId);
    } catch (_) {
      doc = null;
    }

    if (doc == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tài liệu')),
        body: const Center(child: Text('Tài liệu không tồn tại hoặc đã bị xóa.')),
      );
    }

    final document = doc;
    final subject = provider.getSubjectById(document.subjectId);
    final typeColor = document.documentType.color;
    final formatColor = document.fileFormat.color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Tài Liệu'),
        actions: [
          // Nút Favorite
          IconButton(
            icon: Icon(
              document.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: document.isFavorite ? Colors.amber : null,
              size: 26,
            ),
            tooltip: 'Yêu thích',
            onPressed: () {
              provider.toggleFavorite(document.id);
            },
          ),
          // Nút Sửa
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Chỉnh sửa tài liệu',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditDocumentPage(documentToEdit: document),
                ),
              );
            },
          ),
          // Nút Xóa
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: 'Xóa tài liệu',
            onPressed: () async {
              final confirm = await ConfirmDialog.show(
                context: context,
                title: 'Xóa tài liệu này?',
                message:
                    'Bạn có chắc chắn muốn xóa "${document.title}"? Dữ liệu sẽ được lưu vào delete_logs của hệ thống.',
              );

              if (confirm && context.mounted) {
                try {
                  await provider.deleteDocument(document.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã xóa tài liệu thành công!'),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Không thể xóa tài liệu: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Thẻ Header tổng quan
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: formatColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(document.fileFormat.icon, color: formatColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subject?.name ?? 'Chưa phân môn',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: subject?.color ?? theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mã môn: ${subject?.code ?? "N/A"} • ${subject?.semester ?? ""}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    document.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  if (document.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      document.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Chuyển đổi trạng thái học tập nhanh (Status Selector Bar)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trạng thái tiến độ học tập',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: DocumentStatus.values.map((st) {
                      final isSelected = document.status == st;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () {
                              provider.updateDocumentStatus(document.id, st);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? st.color.withValues(alpha: 0.18)
                                    : (isDark ? Colors.white10 : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? st.color : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    size: 16,
                                    color: isSelected ? st.color : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    st.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? st.color : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 3. Bảng thông số chi tiết (Metadata Table)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: document.documentType.icon,
                    iconColor: typeColor,
                    label: 'Phân loại tài liệu',
                    value: document.documentType.displayName,
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    icon: document.fileFormat.icon,
                    iconColor: formatColor,
                    label: 'Định dạng & Dung lượng',
                    value:
                        '${document.fileFormat.extensionName} (${AppFunctions.formatFileSize(document.fileSizeBytes)})',
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    icon: Icons.priority_high_rounded,
                    iconColor: document.priority.color,
                    label: 'Mức độ ưu tiên',
                    value: document.priority.displayName,
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    icon: Icons.alarm_rounded,
                    iconColor: document.dueDate != null ? Colors.orange : Colors.grey,
                    label: 'Hạn chót / Deadline',
                    value: document.dueDate != null
                        ? AppFunctions.formatDate(document.dueDate)
                        : 'Không có hạn',
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today_rounded,
                    iconColor: Colors.blueGrey,
                    label: 'Ngày tạo',
                    value: AppFunctions.formatDateTime(document.dateCreated),
                  ),
                  const Divider(height: 1),
                  _buildDetailRow(
                    context,
                    icon: Icons.update_rounded,
                    iconColor: Colors.blueGrey,
                    label: 'Lần sửa cuối',
                    value: AppFunctions.formatDateTime(document.dateModified),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. File Path / URL link
          if ((document.fileUrl != null && document.fileUrl!.isNotEmpty) ||
              (document.filePath != null && document.filePath!.isNotEmpty))
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tệp đính kèm & Liên kết',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (document.filePath != null && document.filePath!.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.folder_open_rounded),
                        title: Text(document.filePath!, style: const TextStyle(fontSize: 13)),
                        subtitle: const Text('Đường dẫn lưu trên thiết bị'),
                      ),
                    if (document.fileUrl != null && document.fileUrl!.isNotEmpty)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.open_in_browser_rounded, color: Colors.blue),
                        title: Text(
                          document.fileUrl!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        subtitle: const Text('Liên kết tham khảo trực tuyến'),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),

          // 5. Thẻ Tags
          if (document.tags.isNotEmpty)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thẻ phân loại (Tags)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: document.tags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
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

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
