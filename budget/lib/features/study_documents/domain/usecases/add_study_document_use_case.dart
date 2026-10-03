import '../entities/study_document.dart';
import '../repositories/study_document_repository.dart';

class AddStudyDocumentUseCase {
  final StudyDocumentRepository repository;

  const AddStudyDocumentUseCase(this.repository);

  StudyDocument call(StudyDocument document) {
    final normalizedDocument = document.copyWith(
      id: document.id.trim().isEmpty ? DateTime.now().microsecondsSinceEpoch.toString() : document.id,
      title: document.title.trim(),
      category: document.category.trim(),
      summary: document.summary.trim(),
      fileName: document.fileName.trim(),
      fileType: document.fileType.trim(),
      tags: document.tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
    );

    repository.save(normalizedDocument);
    return normalizedDocument;
  }
}
