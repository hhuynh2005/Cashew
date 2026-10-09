import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../struct/document_state_provider.dart';

class CloudSyncPanel extends StatelessWidget {
  const CloudSyncPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentStateProvider>();
    final theme = Theme.of(context);
    final user = provider.currentUser;
    final status = !provider.cloudSyncAvailable
        ? 'Firebase chưa sẵn sàng'
        : user == null
            ? provider.isOnline
                ? 'Chưa đăng nhập đồng bộ'
                : 'Offline • dữ liệu lưu cục bộ'
            : provider.isSyncing
                ? 'Đang đồng bộ hai chiều...'
                : !provider.isOnline
                    ? 'Offline • thay đổi lưu cục bộ'
                    : provider.syncError != null
                        ? 'Đồng bộ cần kiểm tra'
                        : provider.lastSyncedAt == null
                            ? 'Đã đăng nhập • chờ đồng bộ'
                            : 'Đã đồng bộ gần nhất lúc '
                                '${TimeOfDay.fromDateTime(provider.lastSyncedAt!).format(context)}';
    final icon = provider.isSyncing
        ? Icons.sync_rounded
        : user == null
            ? Icons.cloud_off_rounded
            : provider.syncError != null
                ? Icons.cloud_sync_rounded
                : Icons.cloud_done_rounded;
    final color = provider.syncError != null
        ? theme.colorScheme.error
        : provider.isOnline
            ? theme.colorScheme.primary
            : theme.colorScheme.tertiary;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        user?.email ??
                            (provider.localDatabaseIsPersistent
                                ? 'SQLite trên thiết bị • Firebase: cashew-study-docs-d5b15'
                                : 'Cảnh báo: SQLite chưa mở được, dữ liệu hiện chỉ ở bộ nhớ'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (provider.isSyncing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (user == null)
                  TextButton(
                    onPressed: provider.cloudSyncAvailable
                        ? () => _showAccountDialog(context)
                        : null,
                    child: const Text('Đăng nhập'),
                  )
                else ...[
                  IconButton(
                    tooltip: 'Đồng bộ ngay',
                    onPressed: provider.isOnline
                        ? () => _runSync(context, provider)
                        : null,
                    icon: const Icon(Icons.sync_rounded),
                  ),
                  IconButton(
                    tooltip: 'Đăng xuất tài khoản đồng bộ',
                    onPressed: () => provider.signOutCloudAccount(),
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ],
            ),
            if (provider.syncError case final error?)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 34),
                child: Text(
                  error,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
                ),
              ),
            if (provider.lastSyncResult case final result?)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 34),
                child: Text(
                  'Lên cloud: ${result.uploaded} • Tải về: ${result.downloaded} • '
                  'Xóa/hợp nhất: ${result.deleted}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _runSync(
    BuildContext context,
    DocumentStateProvider provider,
  ) async {
    try {
      await provider.syncNow();
    } catch (_) {
      // The provider exposes the failure in the sync status panel.
    }
  }

  Future<void> _showAccountDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _CloudAccountDialog(),
    );
  }
}

class _CloudAccountDialog extends StatefulWidget {
  const _CloudAccountDialog();

  @override
  State<_CloudAccountDialog> createState() => _CloudAccountDialogState();
}

class _CloudAccountDialogState extends State<_CloudAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _createAccount = false;
  bool _working = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<DocumentStateProvider>();
    return AlertDialog(
      title: Text(_createAccount ? 'Tạo tài khoản đồng bộ' : 'Đăng nhập Firebase'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || !value.contains('@') ? 'Nhập email hợp lệ' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu (ít nhất 6 ký tự)'),
                validator: (value) =>
                    value == null || value.length < 6 ? 'Mật khẩu quá ngắn' : null,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _working
              ? null
              : () => setState(() {
                    _createAccount = !_createAccount;
                    _error = null;
                  }),
          child: Text(_createAccount ? 'Đã có tài khoản? Đăng nhập' : 'Tạo tài khoản mới'),
        ),
        FilledButton(
          onPressed: _working ? null : () => _submit(provider),
          child: _working
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_createAccount ? 'Tạo tài khoản' : 'Đăng nhập'),
        ),
      ],
    );
  }

  Future<void> _submit(DocumentStateProvider provider) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      if (_createAccount) {
        await provider.createCloudAccount(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await provider.signIn(
          _emailController.text,
          _passwordController.text,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      setState(() => _error = _authErrorMessage(error));
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _authErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Email này đã có tài khoản. Hãy đăng nhập.';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không đúng.';
      case 'weak-password':
        return 'Mật khẩu cần mạnh hơn (tối thiểu 6 ký tự).';
      case 'operation-not-allowed':
        return 'Hãy bật Email/Password trong Firebase Authentication.';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Dữ liệu local vẫn được giữ.';
      default:
        return error.message ?? 'Không thể xác thực với Firebase (${error.code}).';
    }
  }
}
