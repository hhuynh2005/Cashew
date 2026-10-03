import '../entities/study_document.dart';
import '../repositories/study_document_repository.dart';

class UpdateStudyDocumentUseCase {
  final StudyDocumentRepository repository;

  const UpdateStudyDocumentUseCase(this.repository);

  StudyDocument call(StudyDocument document) {
    final currentDocument = repository.getById(document.id);
    if (currentDocument == null) {
      throw StateError('Study document not found: ${document.id}');
    }

    final normalizedDocument = document.copyWith(
      title: document.title.trim(),
      category: document.category.trim(),
      summary: document.summary.trim(),
      fileName: document.fileName.trim(),
      fileType: document.fileType.trim(),
      tags: document.tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      updatedAt: DateTime.now(),
    );

    repository.save(normalizedDocument);
    return normalizedDocument;
  }
}
