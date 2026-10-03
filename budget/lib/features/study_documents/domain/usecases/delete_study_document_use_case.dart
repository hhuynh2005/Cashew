import '../repositories/study_document_repository.dart';

class DeleteStudyDocumentUseCase {
  final StudyDocumentRepository repository;

  const DeleteStudyDocumentUseCase(this.repository);

  void call(String documentId) {
    repository.delete(documentId);
  }
}
