import 'package:flutter/material.dart';

/// Loại tài liệu học tập
enum DocumentType {
  lecture, // Bài giảng / Slide
  assignment, // Bài tập / Đồ án
  reference, // Tài liệu tham khảo / Sách
  exam, // Đề thi / Đề kiểm tra
  note, // Ghi chú học tập
}

extension DocumentTypeExtension on DocumentType {
  String get id {
    switch (this) {
      case DocumentType.lecture:
        return 'lecture';
      case DocumentType.assignment:
        return 'assignment';
      case DocumentType.reference:
        return 'reference';
      case DocumentType.exam:
        return 'exam';
      case DocumentType.note:
        return 'note';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.lecture:
        return 'Bài giảng';
      case DocumentType.assignment:
        return 'Bài tập';
      case DocumentType.reference:
        return 'Tham khảo';
      case DocumentType.exam:
        return 'Đề thi';
      case DocumentType.note:
        return 'Ghi chú';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentType.lecture:
        return Icons.menu_book_rounded;
      case DocumentType.assignment:
        return Icons.assignment_rounded;
      case DocumentType.reference:
        return Icons.auto_stories_rounded;
      case DocumentType.exam:
        return Icons.quiz_rounded;
      case DocumentType.note:
        return Icons.edit_note_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DocumentType.lecture:
        return const Color(0xFF1E88E5); // Blue
      case DocumentType.assignment:
        return const Color(0xFFFB8C00); // Orange
      case DocumentType.reference:
        return const Color(0xFF43A047); // Green
      case DocumentType.exam:
        return const Color(0xFFE53935); // Red
      case DocumentType.note:
        return const Color(0xFF8E24AA); // Purple
    }
  }

  static DocumentType fromString(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'lecture':
        return DocumentType.lecture;
      case 'assignment':
        return DocumentType.assignment;
      case 'reference':
        return DocumentType.reference;
      case 'exam':
        return DocumentType.exam;
      case 'note':
        return DocumentType.note;
      default:
        return DocumentType.lecture;
    }
  }
}

/// Định dạng tệp tin
enum DocumentFormat {
  pdf,
  docx,
  pptx,
  xlsx,
  zip,
  link,
  txt,
  image,
  other,
}

extension DocumentFormatExtension on DocumentFormat {
  String get id => name;

  String get extensionName {
    switch (this) {
      case DocumentFormat.pdf:
        return 'PDF';
      case DocumentFormat.docx:
        return 'DOCX';
      case DocumentFormat.pptx:
        return 'PPTX';
      case DocumentFormat.xlsx:
        return 'XLSX';
      case DocumentFormat.zip:
        return 'ZIP';
      case DocumentFormat.link:
        return 'LINK';
      case DocumentFormat.txt:
        return 'TXT';
      case DocumentFormat.image:
        return 'IMG';
      case DocumentFormat.other:
        return 'FILE';
    }
  }

  IconData get icon {
    switch (this) {
      case DocumentFormat.pdf:
        return Icons.picture_as_pdf_rounded;
      case DocumentFormat.docx:
        return Icons.description_rounded;
      case DocumentFormat.pptx:
        return Icons.slideshow_rounded;
      case DocumentFormat.xlsx:
        return Icons.table_chart_rounded;
      case DocumentFormat.zip:
        return Icons.folder_zip_rounded;
      case DocumentFormat.link:
        return Icons.link_rounded;
      case DocumentFormat.txt:
        return Icons.text_snippet_rounded;
      case DocumentFormat.image:
        return Icons.image_rounded;
      case DocumentFormat.other:
        return Icons.insert_drive_file_rounded;
    }
  }

  Color get color {
    switch (this) {
      case DocumentFormat.pdf:
        return const Color(0xFFD32F2F);
      case DocumentFormat.docx:
        return const Color(0xFF1976D2);
      case DocumentFormat.pptx:
        return const Color(0xFFE64A19);
      case DocumentFormat.xlsx:
        return const Color(0xFF2E7D32);
      case DocumentFormat.zip:
        return const Color(0xFFF57C00);
      case DocumentFormat.link:
        return const Color(0xFF0097A7);
      case DocumentFormat.txt:
        return const Color(0xFF616161);
      case DocumentFormat.image:
        return const Color(0xFF7B1FA2);
      case DocumentFormat.other:
        return const Color(0xFF455A64);
    }
  }

  static DocumentFormat fromString(String? formatStr) {
    switch (formatStr?.toLowerCase()) {
      case 'pdf':
        return DocumentFormat.pdf;
      case 'docx':
      case 'doc':
        return DocumentFormat.docx;
      case 'pptx':
      case 'ppt':
        return DocumentFormat.pptx;
      case 'xlsx':
      case 'xls':
        return DocumentFormat.xlsx;
      case 'zip':
      case 'rar':
      case '7z':
        return DocumentFormat.zip;
      case 'link':
      case 'url':
        return DocumentFormat.link;
      case 'txt':
        return DocumentFormat.txt;
      case 'image':
      case 'png':
      case 'jpg':
      case 'jpeg':
        return DocumentFormat.image;
      default:
        return DocumentFormat.other;
    }
  }
}

/// Trạng thái học tập của tài liệu
enum DocumentStatus {
  newDoc, // Mới / Chưa xem
  inProgress, // Đang học / Đang làm
  completed, // Đã hoàn thành
}

extension DocumentStatusExtension on DocumentStatus {
  String get id {
    switch (this) {
      case DocumentStatus.newDoc:
        return 'new';
      case DocumentStatus.inProgress:
        return 'in_progress';
      case DocumentStatus.completed:
        return 'completed';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentStatus.newDoc:
        return 'Chưa học';
      case DocumentStatus.inProgress:
        return 'Đang học';
      case DocumentStatus.completed:
        return 'Hoàn thành';
    }
  }

  Color get color {
    switch (this) {
      case DocumentStatus.newDoc:
        return const Color(0xFF757575);
      case DocumentStatus.inProgress:
        return const Color(0xFF0288D1);
      case DocumentStatus.completed:
        return const Color(0xFF388E3C);
    }
  }

  static DocumentStatus fromString(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'in_progress':
        return DocumentStatus.inProgress;
      case 'completed':
        return DocumentStatus.completed;
      case 'new':
      default:
        return DocumentStatus.newDoc;
    }
  }
}

/// Mức độ ưu tiên
enum DocumentPriority {
  low,
  medium,
  high,
}

extension DocumentPriorityExtension on DocumentPriority {
  String get id => name;

  String get displayName {
    switch (this) {
      case DocumentPriority.low:
        return 'Thấp';
      case DocumentPriority.medium:
        return 'Vừa';
      case DocumentPriority.high:
        return 'Cao';
    }
  }

  Color get color {
    switch (this) {
      case DocumentPriority.low:
        return const Color(0xFF81C784);
      case DocumentPriority.medium:
        return const Color(0xFFFFB74D);
      case DocumentPriority.high:
        return const Color(0xFFE57373);
    }
  }

  static DocumentPriority fromString(String? pStr) {
    switch (pStr?.toLowerCase()) {
      case 'high':
        return DocumentPriority.high;
      case 'medium':
        return DocumentPriority.medium;
      case 'low':
      default:
        return DocumentPriority.low;
    }
  }
}
