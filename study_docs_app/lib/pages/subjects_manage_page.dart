import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../struct/document_state_provider.dart';
import '../struct/subject_model.dart';
import '../widgets/confirm_dialog.dart';

/// Màn hình Quản lý Danh mục Môn học (Subjects Management)
class SubjectsManagePage extends StatelessWidget {
  const SubjectsManagePage({super.key});

  void _showAddEditSubjectDialog(BuildContext context, [Subject? subjectToEdit]) {
    final nameController = TextEditingController(text: subjectToEdit?.name ?? '');
    final codeController = TextEditingController(text: subjectToEdit?.code ?? '');
    final semesterController =
        TextEditingController(text: subjectToEdit?.semester ?? 'Học kỳ 1 - 2026');
    String selectedColor = subjectToEdit?.colorHex ?? '#00796B';
    String selectedIcon = subjectToEdit?.iconName ?? 'code';

    final colors = [
      '#00796B', // Emerald
      '#1976D2', // Blue
      '#E65100', // Deep Orange
      '#6A1B9A', // Purple
      '#2E7D32', // Green
      '#C2185B', // Pink
      '#0097A7', // Cyan
      '#5D4037', // Brown
    ];

    final iconsList = ['code', 'database', 'laptop', 'network', 'calculate', 'book'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                subjectToEdit == null ? 'Thêm Môn Học Mới' : 'Sửa Môn Học',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      decoration: const InputDecoration(
                        labelText: 'Mã môn học (VD: CSE441) *',
                        prefixIcon: Icon(Icons.pin_rounded),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên môn học *',
                        prefixIcon: Icon(Icons.school_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: semesterController,
                      decoration: const InputDecoration(
                        labelText: 'Học kỳ',
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chọn biểu tượng môn học:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: iconsList.map((ic) {
                        final isSel = selectedIcon == ic;
                        IconData iconData;
                        switch (ic) {
                          case 'code':
                            iconData = Icons.terminal_rounded;
                            break;
                          case 'database':
                            iconData = Icons.storage_rounded;
                            break;
                          case 'laptop':
                            iconData = Icons.laptop_chromebook_rounded;
                            break;
                          case 'network':
                            iconData = Icons.hub_rounded;
                            break;
                          case 'calculate':
                            iconData = Icons.calculate_rounded;
                            break;
                          case 'book':
                          default:
                            iconData = Icons.menu_book_rounded;
                            break;
                        }
                        return InkWell(
                          onTap: () => setStateDialog(() => selectedIcon = ic),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isSel ? Colors.teal.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? Colors.teal : Colors.grey.shade300,
                                width: isSel ? 2 : 1,
                              ),
                            ),
                            child: Icon(iconData, color: isSel ? Colors.teal : Colors.black54, size: 20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chọn màu sắc nhận diện:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colors.map((c) {
                        final colorVal = Color(int.parse('FF${c.replaceAll('#', '')}', radix: 16));
                        final isSel = selectedColor == c;
                        return InkWell(
                          onTap: () => setStateDialog(() => selectedColor = c),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorVal,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.black : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSel
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final code = codeController.text.trim();
                    if (name.isEmpty || code.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập đầy đủ mã và tên môn học.')),
                      );
                      return;
                    }

                    final provider = context.read<DocumentStateProvider>();
                    if (subjectToEdit == null) {
                      await provider.addSubject(
                        name: name,
                        code: code,
                        colorHex: selectedColor,
                        iconName: selectedIcon,
                        semester: semesterController.text.trim(),
                      );
                    } else {
                      final updated = subjectToEdit.copyWith(
                        name: name,
                        code: code,
                        colorHex: selectedColor,
                        iconName: selectedIcon,
                        semester: semesterController.text.trim(),
                      );
                      await provider.updateSubject(updated);
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentStateProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Môn Học'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Thêm môn học mới',
            onPressed: () => _showAddEditSubjectDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.subjects.length,
        itemBuilder: (ctx, index) {
          final subject = provider.subjects[index];
          final docCount = provider.getDocumentCountBySubject(subject.id);

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: subject.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(subject.iconData, color: subject.color, size: 24),
              ),
              title: Text(
                '${subject.code} - ${subject.name}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                '${subject.semester.isNotEmpty ? "${subject.semester} • " : ""}$docCount tài liệu',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    onPressed: () => _showAddEditSubjectDialog(context, subject),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                    onPressed: () async {
                      final confirm = await ConfirmDialog.show(
                        context: context,
                        title: 'Xóa môn học?',
                        message:
                            'Xóa môn "${subject.name}" sẽ đồng thời xóa toàn bộ $docCount tài liệu thuộc môn này. Bạn có chắc chắn không?',
                      );

                      if (confirm && context.mounted) {
                        await provider.deleteSubject(subject.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã xóa môn học ${subject.code}')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditSubjectDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm môn học'),
      ),
    );
  }
}
