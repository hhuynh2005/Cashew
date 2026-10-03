import 'package:flutter/material.dart';

import '../../domain/entities/study_document.dart';
import '../controllers/study_documents_controller.dart';

class StudyDocumentsPage extends StatefulWidget {
  const StudyDocumentsPage({super.key});

  @override
  State<StudyDocumentsPage> createState() => _StudyDocumentsPageState();
}

class _StudyDocumentsPageState extends State<StudyDocumentsPage> {
  late final StudyDocumentsController _controller;

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _summaryController = TextEditingController();
  final _fileNameController = TextEditingController();
  final _fileTypeController = TextEditingController();
  final _tagsController = TextEditingController();
  final _searchController = TextEditingController();

  StudyDocument? _selectedDocument;

  @override
  void initState() {
    super.initState();
    _controller = StudyDocumentsController();
    _controller.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    setState(() {});
  }

  TextStyle get _fieldTextStyle => const TextStyle(
        color: Color(0xFF0F3D4B),
        fontWeight: FontWeight.w700,
        fontSize: 15,
      );

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: const Color(0xFF0F3D4B)) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: Color(0xFF104D63),
        fontWeight: FontWeight.w700,
        fontSize: 14,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF7096A7),
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: Color(0xFF0D7C8B),
        fontWeight: FontWeight.w800,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBFE9F2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFBFE9F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D7C8B), width: 1.6),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFEAF9FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF1AA7D8),
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F3D4B),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7C8B),
                  minimumSize: const Size(120, 42),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _titleController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    _fileNameController.dispose();
    _fileTypeController.dispose();
    _tagsController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _selectedDocument = null;
    _titleController.clear();
    _categoryController.clear();
    _summaryController.clear();
    _fileNameController.clear();
    _fileTypeController.clear();
    _tagsController.clear();
  }

  void _populateForm(StudyDocument document) {
    setState(() {
      _selectedDocument = document;
      _titleController.text = document.title;
      _categoryController.text = document.category;
      _summaryController.text = document.summary;
      _fileNameController.text = document.fileName;
      _fileTypeController.text = document.fileType;
      _tagsController.text = document.tags.join(', ');
    });
  }

  void _saveDocument() {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    final summary = _summaryController.text.trim();
    final fileName = _fileNameController.text.trim();
    final fileType = _fileTypeController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (title.isEmpty || category.isEmpty || summary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền tiêu đề, danh mục và mô tả.'),
          backgroundColor: Color(0xFFEA5B5B),
        ),
      );
      return;
    }

    if (_selectedDocument != null) {
      _controller.updateDocument(
        _selectedDocument!.copyWith(
          title: title,
          category: category,
          summary: summary,
          fileName: fileName.isEmpty ? _selectedDocument!.fileName : fileName,
          fileType: fileType.isEmpty ? _selectedDocument!.fileType : fileType,
          tags: tags,
        ),
      );
      _showSuccessSnackBar('Cập nhật tài liệu thành công');
    } else {
      _controller.addDocument(
        title: title,
        category: category,
        summary: summary,
        fileName: fileName.isEmpty ? 'untitled' : fileName,
        fileType: fileType.isEmpty ? 'PDF' : fileType,
        tags: tags,
      );
      _showSuccessSnackBar('Thêm tài liệu thành công');
    }

    _resetForm();
  }

  @override
  Widget build(BuildContext context) {
    final documents = _controller.documents;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F7FA8),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Quản lý học tập',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF9FF), Color(0xFFDDF2FA), Color(0xFFE8F8F5)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6EC2D9).withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDocument == null ? 'Thêm tài liệu mới' : 'Chỉnh sửa tài liệu',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF0F3D4B),
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _titleController,
                        style: _fieldTextStyle,
                        decoration: _buildInputDecoration('Tiêu đề tài liệu'),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _categoryController,
                        style: _fieldTextStyle,
                        decoration: _buildInputDecoration('Danh mục'),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _summaryController,
                        maxLines: 4,
                        style: _fieldTextStyle,
                        decoration: _buildInputDecoration('Mô tả / Nội dung tổng quát'),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fileNameController,
                              style: _fieldTextStyle,
                              decoration: _buildInputDecoration('Tên file'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _fileTypeController,
                              style: _fieldTextStyle,
                              decoration: _buildInputDecoration('Loại file'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _tagsController,
                        style: _fieldTextStyle,
                        decoration: _buildInputDecoration('Tags (phân tách bằng dấu phẩy)'),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saveDocument,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D7C8B),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.save_alt_rounded),
                            label: Text(
                              _selectedDocument == null ? 'Lưu tài liệu' : 'Cập nhật',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (_selectedDocument != null)
                            TextButton.icon(
                              onPressed: _resetForm,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF0E5E73),
                              ),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7EC6D8).withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tìm kiếm tài liệu',
                        style: TextStyle(
                          color: Color(0xFF0F3D4B),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        style: _fieldTextStyle,
                        decoration: _buildInputDecoration('Nhập từ khóa...', prefixIcon: Icons.search),
                        onChanged: (value) {
                          _controller.search(value);
                        },
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final document = documents[index];

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4FCFF),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFFCAF0F8)),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                title: Text(
                                  document.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F3D4B),
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      '${document.category} • ${document.fileType}',
                                      style: const TextStyle(
                                        color: Color(0xFF235E73),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      document.summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF2C5867),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: document.tags
                                          .map(
                                            (tag) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDBF7F0),
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                tag,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF0E5E73),
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => _populateForm(document),
                                      icon: const Icon(Icons.edit_outlined, color: Color(0xFF0E5E73)),
                                      tooltip: 'Chỉnh sửa',
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            title: const Text(
                                              'Xác nhận xóa',
                                              style: TextStyle(fontWeight: FontWeight.w800),
                                            ),
                                            content: Text(
                                              'Bạn có chắc muốn xóa tài liệu "${document.title}" không?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Hủy'),
                                              ),
                                              FilledButton(
                                                style: FilledButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Xóa'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (shouldDelete ?? false) {
                                          _controller.deleteDocument(document.id);
                                          if (_selectedDocument?.id == document.id) {
                                            _resetForm();
                                          }
                                          _showSuccessSnackBar('Xóa tài liệu thành công');
                                        }
                                      },
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                      tooltip: 'Xóa',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
