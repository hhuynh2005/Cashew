import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../pages/login_page.dart';
import '../struct/google_auth_service.dart';
import '../theme.dart';

/// Thẻ thông tin người dùng & Quản lý phiên Cloud (User Profile Header)
/// Phụ trách: NGUYỄN TRUNG KIÊN (MSV: 2251172394) - Nhóm 16 (65KTPM - ĐH Thủy Lợi)
/// Nhánh Git: kien-cloud-ui
class UserProfileHeader extends StatelessWidget {
  final VoidCallback? onOpenAuthPage;
  final double usedStorageGb;
  final double totalStorageGb;

  const UserProfileHeader({
    super.key,
    this.onOpenAuthPage,
    this.usedStorageGb = 1.25,
    this.totalStorageGb = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return _buildSignedInHeader(context, user, isDark);
        } else {
          return _buildSignedOutBanner(context, isDark);
        }
      },
    );
  }

  /// Giao diện khi NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP GOOGLE CLOUD
  Widget _buildSignedInHeader(BuildContext context, User user, bool isDark) {
    final email = user.email ?? '';
    final displayName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : 'Sinh viên Thủy Lợi';
    final photoUrl = user.photoURL;
    final isStudent = GoogleAuthService.isStudentEmail(email);
    final badge = GoogleAuthService.getAccountBadge(email);

    final double quotaPercent = (usedStorageGb / totalStorageGb).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF003830),
                    const Color(0xFF00241F),
                  ]
                : [
                    const Color(0xFFF2FAF8),
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar người dùng với chỉ báo Online
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                      backgroundImage:
                          photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            )
                          : null,
                    ),
                    Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF00241F) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Họ tên, Email và Huy hiệu sinh viên
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isStudent ? Colors.blue : Colors.green)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isStudent ? Colors.blue : Colors.green,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isStudent ? Icons.school_rounded : Icons.verified_user_rounded,
                                  size: 11,
                                  color: isStudent ? Colors.blue : Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isStudent ? 'TLU' : 'Google',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isStudent ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email.isNotEmpty ? email : 'Đã kết nối Firebase DMS',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nút cài đặt / chi tiết tài khoản
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  color: AppTheme.primaryColor,
                  tooltip: 'Xem thông tin tài khoản Cloud',
                  onPressed: () {
                    if (onOpenAuthPage != null) {
                      onOpenAuthPage!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Thanh dung lượng Cloud Storage Quota
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.cloud_queue_rounded,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Dung lượng Cloud DMS (S3 / Firebase):',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${usedStorageGb.toStringAsFixed(2)} / ${totalStorageGb.toStringAsFixed(1)} GB (${(quotaPercent * 100).toInt()}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: quotaPercent,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Giao diện khi CHƯA ĐĂNG NHẬP
  Widget _buildSignedOutBanner(BuildContext context, bool isDark) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF003830),
                    const Color(0xFF00241F),
                  ]
                : [
                    const Color(0xFFE8F5E9),
                    Colors.white,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_upload_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đăng nhập Google Cloud',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đồng bộ tài liệu học tập lên Firebase Storage & truy cập mọi lúc.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () {
                if (onOpenAuthPage != null) {
                  onOpenAuthPage!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                }
              },
              style: FilledButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Đăng nhập', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
