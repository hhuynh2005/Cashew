import 'package:flutter/material.dart';

/// Thực thể Môn học (Subject / Course)
class Subject {
  final String id;
  final String name;
  final String code;
  final String colorHex;
  final String iconName;
  final String semester;
  final DateTime dateCreated;
  final DateTime dateModified;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.colorHex = '#00796B',
    this.iconName = 'book',
    this.semester = 'HK1 - 2026',
    DateTime? dateCreated,
    DateTime? dateModified,
  })  : dateCreated = dateCreated ?? DateTime.now(),
        dateModified = dateModified ?? DateTime.now();

  /// Chuyển colorHex sang Color trong Flutter
  Color get color {
    try {
      final hexCode = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (_) {
      return const Color(0xFF00796B);
    }
  }

  /// Chuyển iconName sang IconData phù hợp
  IconData get iconData {
    switch (iconName.toLowerCase()) {
      case 'code':
      case 'laptop':
        return Icons.terminal_rounded;
      case 'database':
      case 'storage':
        return Icons.storage_rounded;
      case 'network':
      case 'wifi':
        return Icons.hub_rounded;
      case 'calculate':
      case 'math':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'book':
      default:
        return Icons.menu_book_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'color_hex': colorHex,
      'icon_name': iconName,
      'semester': semester,
      'date_created': dateCreated.toIso8601String(),
      'date_modified': dateModified.toIso8601String(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      colorHex: (map['color_hex'] as String?) ?? '#00796B',
      iconName: (map['icon_name'] as String?) ?? 'book',
      semester: (map['semester'] as String?) ?? '',
      dateCreated: map['date_created'] != null
          ? DateTime.tryParse(map['date_created'] as String) ?? DateTime.now()
          : DateTime.now(),
      dateModified: map['date_modified'] != null
          ? DateTime.tryParse(map['date_modified'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? colorHex,
    String? iconName,
    String? semester,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      semester: semester ?? this.semester,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subject && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
