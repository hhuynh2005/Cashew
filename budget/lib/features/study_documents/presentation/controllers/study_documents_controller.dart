import 'package:flutter/foundation.dart';

import '../../data/repositories/in_memory_study_document_repository.dart';
import '../../domain/entities/study_document.dart';
import '../../domain/repositories/study_document_repository.dart';
import '../../domain/usecases/add_study_document_use_case.dart';
import '../../domain/usecases/delete_study_document_use_case.dart';
import '../../domain/usecases/search_study_documents_use_case.dart';
import '../../domain/usecases/update_study_document_use_case.dart';

class StudyDocumentsController extends ChangeNotifier {
  final StudyDocumentRepository repository;
  late final AddStudyDocumentUseCase _addUseCase;
  late final UpdateStudyDocumentUseCase _updateUseCase;
  late final DeleteStudyDocumentUseCase _deleteUseCase;
  late final SearchStudyDocumentsUseCase _searchUseCase;

  String searchQuery = '';

  StudyDocumentsController({StudyDocumentRepository? repository})
      : repository = repository ?? InMemoryStudyDocumentRepository() {
    _addUseCase = AddStudyDocumentUseCase(this.repository);
    _updateUseCase = UpdateStudyDocumentUseCase(this.repository);
    _deleteUseCase = DeleteStudyDocumentUseCase(this.repository);
    _searchUseCase = SearchStudyDocumentsUseCase(this.repository);
  }

  List<StudyDocument> get documents => _searchUseCase(searchQuery);

  StudyDocument addDocument({
    required String title,
    required String category,
    required String summary,
    required String fileName,
    required String fileType,
    List<String> tags = const [],
  }) {
    final document = StudyDocument(
      id: '',
      title: title,
      category: category,
      summary: summary,
      fileName: fileName,
      fileType: fileType,
      updatedAt: DateTime.now(),
      tags: tags,
    );

    final savedDocument = _addUseCase(document);
    notifyListeners();
    return savedDocument;
  }

  void updateDocument(StudyDocument document) {
    _updateUseCase(document);
    notifyListeners();
  }

  void deleteDocument(String documentId) {
    _deleteUseCase(documentId);
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query;
    notifyListeners();
  }
}
