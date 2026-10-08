import 'package:flutter/material.dart';

import '../theme.dart';

/// Chỉ báo trạng thái Cloud và Ngoại tuyến (Offline Mode Indicator)
/// Phụ trách: NGUYỄN TRUNG KIÊN (MSV: 2251172394) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
/// Nhánh Git: kien-cloud-ui
class OfflineModeIndicator extends StatefulWidget {
  final bool isOffline;
  final ValueChanged<bool>? onToggleOffline;
  final VoidCallback? onSyncNow;
  final int pendingSyncCount;

  const OfflineModeIndicator({
    super.key,
    this.isOffline = false,
    this.onToggleOffline,
    this.onSyncNow,
    this.pendingSyncCount = 0,
  });

  @override
  State<OfflineModeIndicator> createState() => _OfflineModeIndicatorState();
}

class _OfflineModeIndicatorState extends State<OfflineModeIndicator> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isOffline = widget.isOffline;
    final primaryAccent = isOffline ? const Color(0xFFEF6C00) : AppTheme.primaryColor;
    final bgLight = isOffline
        ? (isDark ? const Color(0xFF3E2723) : const Color(0xFFFFF3E0))
        : (isDark ? const Color(0xFF00332C) : const Color(0xFFE0F2F1));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primaryAccent.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: primaryAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
              color: primaryAccent,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      isOffline ? 'Chế độ Ngoại Tuyến (Offline)' : 'Đám Mây Sẵn Sàng (Online)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryAccent,
                      ),
                    ),
                    if (widget.pendingSyncCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.pendingSyncCount} chờ tải',
                          style: const TextStyle(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  isOffline
                      ? 'Dữ liệu lưu an toàn tại SQLite cục bộ. Tự động đồng bộ khi có mạng.'
                      : 'Firebase Cloud Storage asia-southeast1 • Đồng bộ hai chiều tức thì.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Toggle chuyển đổi để test hoặc nút Sync
          if (widget.onToggleOffline != null)
            Tooltip(
              message: isOffline ? 'Chuyển sang Online' : 'Chuyển sang Offline (Mô phỏng)',
              child: Switch.adaptive(
                value: !isOffline,
                activeTrackColor: AppTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  widget.onToggleOffline?.call(!val);
                },
              ),
            ),
          if (widget.onSyncNow != null && isOffline)
            TextButton(
              onPressed: widget.onSyncNow,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Đồng bộ', style: TextStyle(fontSize: 11)),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 14),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Đóng thông báo',
            onPressed: () {
              setState(() => _dismissed = true);
            },
          ),
        ],
      ),
    );
  }
}
