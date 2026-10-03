import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../struct/document_enums.dart';
import '../struct/document_state_provider.dart';

/// Thanh lọc cuộn ngang (Horizontal Filter Chips) theo phong cách Cashew
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentStateProvider>();

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Chip "Tất cả"
          FilterChip(
            label: const Text('Tất cả'),
            selected: provider.selectedType == null &&
                provider.selectedStatus == null &&
                !provider.showFavoritesOnly,
            onSelected: (_) {
              provider.clearFilters();
            },
            showCheckmark: false,
          ),
          const SizedBox(width: 8),

          // Chip "Yêu thích"
          FilterChip(
            avatar: Icon(
              provider.showFavoritesOnly ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 16,
              color: provider.showFavoritesOnly ? Colors.amber : null,
            ),
            label: const Text('Yêu thích'),
            selected: provider.showFavoritesOnly,
            onSelected: (_) {
              provider.toggleFavoritesOnly();
            },
            showCheckmark: false,
          ),
          const SizedBox(width: 8),

          // Chips theo Loại tài liệu (DocumentType)
          ...DocumentType.values.map((type) {
            final isSelected = provider.selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: Icon(type.icon, size: 16, color: isSelected ? Colors.white : type.color),
                label: Text(type.displayName),
                selected: isSelected,
                selectedColor: type.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  provider.setSelectedType(selected ? type : null);
                },
                showCheckmark: false,
              ),
            );
          }),

          // Chips theo Trạng thái học tập
          ...DocumentStatus.values.map((status) {
            final isSelected = provider.selectedStatus == status;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(status.displayName),
                selected: isSelected,
                selectedColor: status.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  provider.setSelectedStatus(selected ? status : null);
                },
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
