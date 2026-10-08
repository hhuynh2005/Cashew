import 'package:flutter_test/flutter_test.dart';
import 'package:study_docs_app/database/app_database.dart';
import 'package:study_docs_app/database/tables.dart';
import 'package:study_docs_app/struct/document_enums.dart';
import 'package:study_docs_app/struct/document_model.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = await AppDatabase.initInMemory();
  });

  group('Offline sync database merge', () {
    test(
      'remote tombstone removes the local row and is retained for propagation',
      () async {
        final document = Document(
          id: 'sync-delete-test',
          title: 'Offline delete test',
          subjectId: 'subj_cse441',
          documentType: DocumentType.note,
          dateModified: DateTime(2026, 10, 8),
        );
        await database.insertDocument(document);
        final deletionTime = DateTime(2026, 10, 9);

        await database.applySyncedDeleteLog({
          'id': 'remote-delete-test',
          'item_id': document.id,
          'table_name': AppTables.tableDocuments,
          'date_deleted': deletionTime.toIso8601String(),
        });

        expect(await database.getDocumentById(document.id), isNull);
        expect(
          (await database.getDeleteLogs()).any(
            (log) => log['id'] == 'remote-delete-test',
          ),
          isTrue,
        );
      },
    );

    test('stale tombstone does not remove a newer local edit', () async {
      final document = Document(
        id: 'sync-stale-delete-test',
        title: 'Newer local edit',
        subjectId: 'subj_cse441',
        documentType: DocumentType.note,
        dateModified: DateTime(2026, 10, 9),
      );
      await database.insertDocument(document);

      await database.applySyncedDeleteLog({
        'id': 'stale-delete-test',
        'item_id': document.id,
        'table_name': AppTables.tableDocuments,
        'date_deleted': DateTime(2026, 10, 8).toIso8601String(),
      });

      expect(
        (await database.getDocumentById(document.id))?.title,
        document.title,
      );
    });

    test('deleting a subject records tombstones for its documents', () async {
      await database.deleteSubject('subj_cse441');

      final logs = await database.getDeleteLogs();
      expect(
        logs.any(
          (log) =>
              log['table_name'] == AppTables.tableSubjects &&
              log['item_id'] == 'subj_cse441',
        ),
        isTrue,
      );
      expect(
        logs.any((log) => log['table_name'] == AppTables.tableDocuments),
        isTrue,
      );
    });
  });
}
