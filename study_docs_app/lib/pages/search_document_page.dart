import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../struct/document_enums.dart';
import '../struct/document_state_provider.dart';
import '../widgets/document_card.dart';
import '../widgets/empty_state_view.dart';
import 'document_detail_page.dart';

/// Màn hình Tìm kiếm Toàn diện (Live Search & Multi-criteria Filter)
class SearchDocumentPage extends StatefulWidget {
  const SearchDocumentPage({super.key});

  @override
  State<SearchDocumentPage> createState() => _SearchDocumentPageState();
}

class _SearchDocumentPageState extends State<SearchDocumentPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<DocumentStateProvider>();
    _searchController.text = provider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentStateProvider>();
    final theme = Theme.of(context);

    final results = provider.filteredDocuments;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tìm bài giảng, bài tập, đề thi...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            provider.setSearchQuery(val);
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Chips trên thanh tìm kiếm
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Lọc theo Môn
                DropdownButton<String?>(
                  value: provider.selectedSubjectId,
                  hint: const Text('Tất cả môn'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả môn')),
                    ...provider.subjects.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.code)),
                    ),
                  ],
                  onChanged: (val) => provider.setSelectedSubject(val),
                ),
                const SizedBox(width: 8),

                // Lọc theo Loại
                DropdownButton<DocumentType?>(
                  value: provider.selectedType,
                  hint: const Text('Loại tài liệu'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả loại')),
                    ...DocumentType.values.map(
                      (t) => DropdownMenuItem(value: t, child: Text(t.displayName)),
                    ),
                  ],
                  onChanged: (val) => provider.setSelectedType(val),
                ),
                const SizedBox(width: 8),

                // Lọc theo Trạng thái
                DropdownButton<DocumentStatus?>(
                  value: provider.selectedStatus,
                  hint: const Text('Trạng thái'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
                    ...DocumentStatus.values.map(
                      (st) => DropdownMenuItem(value: st, child: Text(st.displayName)),
                    ),
                  ],
                  onChanged: (val) => provider.setSelectedStatus(val),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Số lượng kết quả
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tìm thấy ${results.length} tài liệu',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (provider.searchQuery.isNotEmpty ||
                    provider.selectedSubjectId != null ||
                    provider.selectedType != null ||
                    provider.selectedStatus != null)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    child: Text(
                      'Xóa tất cả bộ lọc',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Danh sách kết quả
          Expanded(
            child: results.isEmpty
                ? const EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'Không tìm thấy tài liệu phù hợp',
                    message:
                        'Vui lòng kiểm tra lại từ khóa hoặc xóa bớt tiêu chí lọc để mở rộng phạm vi tìm kiếm.',
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (ctx, idx) {
                      final doc = results[idx];
                      return DocumentCard(
                        document: doc,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DocumentDetailPage(documentId: doc.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
