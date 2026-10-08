import 'package:flutter/material.dart';

import '../struct/document_enums.dart';

/// Huy hiệu hiển thị trạng thái đồng bộ đám mây (Cloud Sync Badge)
/// Phụ trách: NGUYỄN TRUNG KIÊN (MSV: 2251172394) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
/// Nhánh Git: kien-cloud-ui
class CloudSyncBadge extends StatelessWidget {
  final CloudSyncStatus status;
  final bool compact;
  final VoidCallback? onTap;

  const CloudSyncBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    final bgColor = status.backgroundColor;

    final badgeWidget = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: compact ? 13 : 15,
            color: color,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              status.shortLabel,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );

    return Tooltip(
      message: status.displayName,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: badgeWidget,
            )
          : badgeWidget,
    );
  }
}
