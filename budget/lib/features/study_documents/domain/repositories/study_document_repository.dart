import '../entities/study_document.dart';

abstract class StudyDocumentRepository {
  List<StudyDocument> getAll();

  StudyDocument? getById(String id);

  void save(StudyDocument document);

  void delete(String id);

  List<StudyDocument> search(String query);
}
