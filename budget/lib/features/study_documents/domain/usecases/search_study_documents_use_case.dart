import '../entities/study_document.dart';
import '../repositories/study_document_repository.dart';

class SearchStudyDocumentsUseCase {
  final StudyDocumentRepository repository;

  const SearchStudyDocumentsUseCase(this.repository);

  List<StudyDocument> call(String query) {
    return repository.search(query);
  }
}
