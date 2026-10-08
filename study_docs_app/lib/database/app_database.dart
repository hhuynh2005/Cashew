import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:uuid/uuid.dart';

import '../struct/document_enums.dart';
import '../struct/document_model.dart';
import '../struct/subject_model.dart';
import 'mock_data.dart';
import 'tables.dart';

/// Database Layer - Quản lý SQLite Database cục bộ theo đúng tiêu chuẩn kiến trúc Cashew
class AppDatabase {
  static const String _databaseName = 'study_documents.db';
  static const int _databaseVersion = 1;
  static const _uuid = Uuid();

  static AppDatabase? _instance;
  static Database? _database;
  Future<Database>? _databaseInitialization;

  // Cấu chế Fallback bộ nhớ nếu Web worker / WASM bị chặn bởi trình duyệt
  bool _useMemoryFallback = false;
  final List<Document> _fallbackDocuments = [];
  final List<Subject> _fallbackSubjects = [];
  final List<Map<String, dynamic>> _fallbackDeleteLogs = [];

  // StreamControllers mô phỏng cơ chế reactive stream watch() của Drift/Cashew
  final StreamController<List<Document>> _documentsStreamController =
      StreamController<List<Document>>.broadcast();
  final StreamController<List<Subject>> _subjectsStreamController =
      StreamController<List<Subject>>.broadcast();
  final StreamController<Map<String, int>> _statsStreamController =
      StreamController<Map<String, int>>.broadcast();

  // Constructor
  AppDatabase._internal();

  static AppDatabase get instance {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  Future<void> applySyncedDocument(Document document) async {
    final db = await database;
    if (db == null) {
      _fallbackDocuments.removeWhere((item) => item.id == document.id);
      _fallbackDocuments.add(document);
    } else {
      await db.insert(
        AppTables.tableDocuments,
        document.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await _notifyWatchers();
  }

  Future<void> applySyncedSubject(Subject subject) async {
    final db = await database;
    if (db == null) {
      _fallbackSubjects.removeWhere((item) => item.id == subject.id);
      _fallbackSubjects.add(subject);
    } else {
      await db.insert(
        AppTables.tableSubjects,
        subject.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await _notifyWatchers();
  }

  Future<void> applySyncedDeleteLog(Map<String, dynamic> log) async {
    final tableName = log['table_name'] as String?;
    final itemId = log['item_id'] as String?;
    final logId = log['id'] as String?;
    final deletedAt = log['date_deleted'] as String?;
    final tombstoneAt = DateTime.tryParse(deletedAt ?? '');
    if ((tableName != AppTables.tableDocuments &&
            tableName != AppTables.tableSubjects) ||
        itemId == null ||
        logId == null ||
        tombstoneAt == null) {
      throw const FormatException('Invalid synchronized delete log.');
    }

    final db = await database;
    if (db == null) {
      if (tableName == AppTables.tableDocuments) {
        _fallbackDocuments.removeWhere(
          (item) =>
              item.id == itemId && !item.dateModified.isAfter(tombstoneAt),
        );
      } else if (tableName == AppTables.tableSubjects) {
        final subjectDeleted = _fallbackSubjects.any(
          (item) =>
              item.id == itemId && !item.dateModified.isAfter(tombstoneAt),
        );
        if (subjectDeleted) {
          final childIds = _fallbackDocuments
              .where((item) => item.subjectId == itemId)
              .map((item) => item.id)
              .toList();
          for (final childId in childIds) {
            _fallbackDeleteLogs.add({
              'id': _uuid.v4(),
              'item_id': childId,
              'table_name': AppTables.tableDocuments,
              'date_deleted': tombstoneAt.toIso8601String(),
            });
          }
        }
        _fallbackDocuments.removeWhere(
          (item) =>
              item.subjectId == itemId &&
              !item.dateModified.isAfter(tombstoneAt),
        );
        _fallbackSubjects.removeWhere(
          (item) =>
              item.id == itemId && !item.dateModified.isAfter(tombstoneAt),
        );
      }
      if (!_fallbackDeleteLogs.any((item) => item['id'] == logId)) {
        _fallbackDeleteLogs.add(Map<String, dynamic>.from(log));
      }
    } else {
      await db.transaction((txn) async {
        final logs = await txn.query(
          AppTables.tableDeleteLogs,
          where: 'id = ?',
          whereArgs: [logId],
          limit: 1,
        );
        if (logs.isEmpty) {
          await txn.insert(AppTables.tableDeleteLogs, log);
        }

        if (tableName == AppTables.tableDocuments) {
          final existing = await txn.query(
            AppTables.tableDocuments,
            columns: ['date_modified'],
            where: 'id = ?',
            whereArgs: [itemId],
            limit: 1,
          );
          if (existing.isNotEmpty) {
            final modifiedAt = DateTime.tryParse(
              existing.first['date_modified'] as String? ?? '',
            );
            if (modifiedAt == null || !modifiedAt.isAfter(tombstoneAt)) {
              await txn.delete(
                AppTables.tableDocuments,
                where: 'id = ?',
                whereArgs: [itemId],
              );
            }
          }
        } else if (tableName == AppTables.tableSubjects) {
          final existing = await txn.query(
            AppTables.tableSubjects,
            columns: ['date_modified'],
            where: 'id = ?',
            whereArgs: [itemId],
            limit: 1,
          );
          if (existing.isNotEmpty) {
            final modifiedAt = DateTime.tryParse(
              existing.first['date_modified'] as String? ?? '',
            );
            if (modifiedAt == null || !modifiedAt.isAfter(tombstoneAt)) {
              final childDocs = await txn.query(
                AppTables.tableDocuments,
                columns: ['id'],
                where: 'subject_id = ?',
                whereArgs: [itemId],
              );
              for (final child in childDocs) {
                await txn.insert(AppTables.tableDeleteLogs, {
                  'id': _uuid.v4(),
                  'item_id': child['id'],
                  'table_name': AppTables.tableDocuments,
                  'date_deleted': deletedAt,
                });
              }
              await txn.delete(
                AppTables.tableDocuments,
                where: 'subject_id = ?',
                whereArgs: [itemId],
              );
              await txn.delete(
                AppTables.tableSubjects,
                where: 'id = ?',
                whereArgs: [itemId],
              );
            }
          }
        }
      });
    }
    await _notifyWatchers();
  }

  /// Cung cấp quyền truy cập Database, tự động khởi tạo nếu chưa có
  Future<Database?> get database async {
    if (_useMemoryFallback) return null;
    if (_database != null && _database!.isOpen) {
      return _database!;
    }
    final initialization = _databaseInitialization ??= _initDatabase();
    try {
      _database = await initialization;
      return _database!;
    } catch (e) {
      debugPrint(
        'Database init notice ($e). Kích hoạt chế độ In-Memory Fallback.',
      );
      _useMemoryFallback = true;
      if (_fallbackDocuments.isEmpty) {
        _fallbackDocuments.addAll(MockData.getInitialDocuments());
      }
      if (_fallbackSubjects.isEmpty) {
        _fallbackSubjects.addAll(MockData.initialSubjects);
      }
      return null;
    } finally {
      if (identical(_databaseInitialization, initialization)) {
        _databaseInitialization = null;
      }
    }
  }

  bool get isUsingMemoryFallback => _useMemoryFallback;

  /// Khởi tạo database với hỗ trợ đa nền tảng (Web, Mobile, Desktop, Test)
  Future<Database> _initDatabase({bool isMemory = false}) async {
    String dbPath;

    if (kIsWeb) {
      try {
        databaseFactory = databaseFactoryFfiWebNoWebWorker;
      } catch (e) {
        debugPrint('Web database factory warning: $e');
      }
      dbPath = isMemory ? inMemoryDatabasePath : _databaseName;
    } else if (isMemory) {
      dbPath = inMemoryDatabasePath;
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    } else {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
        final docDir = await getApplicationDocumentsDirectory();
        final dbFolder = Directory(p.join(docDir.path, 'StudyDocsCashew'));
        if (!await dbFolder.exists()) {
          await dbFolder.create(recursive: true);
        }
        dbPath = p.join(dbFolder.path, _databaseName);
      } else {
        final databasesPath = await getDatabasesPath();
        dbPath = p.join(databasesPath, _databaseName);
      }
    }

    try {
      return await openDatabase(
        dbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onOpen: (db) async {
          await _seedInitialDataIfNeeded(db);
        },
      );
    } catch (e) {
      debugPrint(
        'Mở DB tại $dbPath không thành công ($e), chuyển sang inMemoryDatabasePath',
      );
      _useMemoryFallback = true;
      return await openDatabase(
        inMemoryDatabasePath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onOpen: (db) async {
          await _seedInitialDataIfNeeded(db);
        },
      );
    }
  }

  /// Khởi tạo in-memory database phục vụ Unit Test / Integration Test
  static Future<AppDatabase> initInMemory() async {
    final appDb = AppDatabase._internal();
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _database = await openDatabase(
      inMemoryDatabasePath,
      version: _databaseVersion,
      onCreate: appDb._onCreate,
    );
    await appDb._seedInitialDataIfNeeded(_database!);
    _instance = appDb;
    return appDb;
  }

  /// Tạo các bảng và chỉ mục khi tạo database lần đầu
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    batch.execute(AppTables.createTableSubjects);
    batch.execute(AppTables.createTableDocuments);
    batch.execute(AppTables.createTableDeleteLogs);
    batch.execute(AppTables.createTableAppSettings);

    for (final indexSql in AppTables.createIndexes) {
      batch.execute(indexSql);
    }
    await batch.commit(noResult: true);
  }

  /// Nạp dữ liệu mẫu ban đầu nếu cơ sở dữ liệu còn trống
  Future<void> _seedInitialDataIfNeeded(Database db) async {
    final subjectsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${AppTables.tableSubjects}'),
    );

    if (subjectsCount == 0) {
      final batch = db.batch();

      // Nạp Môn học
      for (final subject in MockData.initialSubjects) {
        batch.insert(AppTables.tableSubjects, subject.toMap());
      }

      // Nạp Tài liệu học tập
      for (final doc in MockData.getInitialDocuments()) {
        batch.insert(AppTables.tableDocuments, doc.toMap());
      }

      // Cài đặt mặc định
      batch.insert(AppTables.tableAppSettings, {
        'key': 'theme_mode',
        'value': 'system',
        'date_modified': DateTime.now().toIso8601String(),
      });

      await batch.commit(noResult: true);
      _notifyWatchers();
    }
  }

  // ===========================================================================
  // REACTIVE WATCHERS (Đặc trưng của kiến trúc Cashew)
  // ===========================================================================

  /// Phát tín hiệu cho các Stream Subscribers khi có thay đổi dữ liệu
  Future<void> _notifyWatchers() async {
    try {
      final docs = await getAllDocuments();
      if (!_documentsStreamController.isClosed) {
        _documentsStreamController.add(docs);
      }

      final subjects = await getAllSubjects();
      if (!_subjectsStreamController.isClosed) {
        _subjectsStreamController.add(subjects);
      }

      final stats = await getDocumentStats();
      if (!_statsStreamController.isClosed) {
        _statsStreamController.add(stats);
      }
    } catch (e) {
      debugPrint('Error notifying watchers: $e');
    }
  }

  /// Theo dõi danh sách toàn bộ tài liệu theo thời gian thực (Reactive Stream)
  Stream<List<Document>> watchAllDocuments() {
    getAllDocuments()
        .then((docs) {
          if (!_documentsStreamController.isClosed) {
            _documentsStreamController.add(docs);
          }
        })
        .catchError((err) {
          debugPrint('watchAllDocuments catchError: $err');
          if (!_documentsStreamController.isClosed) {
            _documentsStreamController.add(
              _fallbackDocuments.isNotEmpty
                  ? _fallbackDocuments
                  : MockData.getInitialDocuments(),
            );
          }
        });
    return _documentsStreamController.stream;
  }

  /// Theo dõi danh sách môn học theo thời gian thực
  Stream<List<Subject>> watchSubjects() {
    getAllSubjects()
        .then((subjects) {
          if (!_subjectsStreamController.isClosed) {
            _subjectsStreamController.add(subjects);
          }
        })
        .catchError((err) {
          debugPrint('watchSubjects catchError: $err');
          if (!_subjectsStreamController.isClosed) {
            _subjectsStreamController.add(
              _fallbackSubjects.isNotEmpty
                  ? _fallbackSubjects
                  : MockData.initialSubjects,
            );
          }
        });
    return _subjectsStreamController.stream;
  }

  /// Theo dõi số liệu thống kê theo thời gian thực
  Stream<Map<String, int>> watchStats() {
    getDocumentStats()
        .then((stats) {
          if (!_statsStreamController.isClosed) {
            _statsStreamController.add(stats);
          }
        })
        .catchError((err) {
          debugPrint('watchStats catchError: $err');
        });
    return _statsStreamController.stream;
  }

  // ===========================================================================
  // TÀI LIỆU (DOCUMENTS) - THAO TÁC CƠ SỞ DỮ LIỆU
  // ===========================================================================

  /// Lấy toàn bộ danh sách tài liệu
  Future<List<Document>> getAllDocuments() async {
    try {
      final db = await database;
      if (db == null) {
        return List<Document>.from(_fallbackDocuments)
          ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
      }
      final List<Map<String, dynamic>> maps = await db.query(
        AppTables.tableDocuments,
        orderBy: 'date_created DESC',
      );
      return maps.map((map) => Document.fromMap(map)).toList();
    } catch (e) {
      debugPrint('getAllDocuments fallback notice: $e');
      return List<Document>.from(
        _fallbackDocuments.isNotEmpty
            ? _fallbackDocuments
            : MockData.getInitialDocuments(),
      );
    }
  }

  /// Lấy chi tiết một tài liệu theo ID
  Future<Document?> getDocumentById(String id) async {
    try {
      final db = await database;
      if (db == null) {
        try {
          return _fallbackDocuments.firstWhere((d) => d.id == id);
        } catch (_) {
          return null;
        }
      }
      final List<Map<String, dynamic>> maps = await db.query(
        AppTables.tableDocuments,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Document.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('getDocumentById fallback notice: $e');
      try {
        return _fallbackDocuments.firstWhere((d) => d.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Thêm mới một tài liệu
  Future<int> insertDocument(Document doc) async {
    try {
      final db = await database;
      if (db == null) {
        _fallbackDocuments.removeWhere((d) => d.id == doc.id);
        _fallbackDocuments.add(doc);
        await _notifyWatchers();
        return 1;
      }
      final result = await db.insert(
        AppTables.tableDocuments,
        doc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _notifyWatchers();
      return result;
    } catch (e) {
      debugPrint('insertDocument fallback notice: $e');
      _fallbackDocuments.removeWhere((d) => d.id == doc.id);
      _fallbackDocuments.add(doc);
      await _notifyWatchers();
      return 1;
    }
  }

  /// Cập nhật thông tin tài liệu
  Future<int> updateDocument(Document doc) async {
    final updatedDoc = doc.copyWith(dateModified: DateTime.now());
    try {
      final db = await database;
      if (db == null) {
        final idx = _fallbackDocuments.indexWhere((d) => d.id == doc.id);
        if (idx != -1) {
          _fallbackDocuments[idx] = updatedDoc;
        } else {
          _fallbackDocuments.add(updatedDoc);
        }
        await _notifyWatchers();
        return 1;
      }
      final result = await db.update(
        AppTables.tableDocuments,
        updatedDoc.toMap(),
        where: 'id = ?',
        whereArgs: [doc.id],
      );
      await _notifyWatchers();
      return result;
    } catch (e) {
      debugPrint('updateDocument fallback notice: $e');
      final idx = _fallbackDocuments.indexWhere((d) => d.id == doc.id);
      if (idx != -1) {
        _fallbackDocuments[idx] = updatedDoc;
      } else {
        _fallbackDocuments.add(updatedDoc);
      }
      await _notifyWatchers();
      return 1;
    }
  }

  /// Xóa tài liệu và ghi log vào delete_logs (đúng nguyên tắc Cashew)
  Future<int> deleteDocument(String id) async {
    try {
      final db = await database;
      if (db == null) {
        _fallbackDeleteLogs.add({
          'id': _uuid.v4(),
          'item_id': id,
          'table_name': AppTables.tableDocuments,
          'date_deleted': DateTime.now().toIso8601String(),
        });
        _fallbackDocuments.removeWhere((d) => d.id == id);
        await _notifyWatchers();
        return 1;
      }

      final result = await db.transaction((txn) async {
        await txn.insert(AppTables.tableDeleteLogs, {
          'id': _uuid.v4(),
          'item_id': id,
          'table_name': AppTables.tableDocuments,
          'date_deleted': DateTime.now().toIso8601String(),
        });

        return await txn.delete(
          AppTables.tableDocuments,
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      await _notifyWatchers();
      return result;
    } catch (e) {
      debugPrint('deleteDocument fallback notice: $e');
      _fallbackDeleteLogs.add({
        'id': _uuid.v4(),
        'item_id': id,
        'table_name': AppTables.tableDocuments,
        'date_deleted': DateTime.now().toIso8601String(),
      });
      _fallbackDocuments.removeWhere((d) => d.id == id);
      await _notifyWatchers();
      return 1;
    }
  }

  /// Bật/Tắt trạng thái yêu thích
  Future<bool> toggleFavorite(String id) async {
    final doc = await getDocumentById(id);
    if (doc == null) return false;
    final updated = doc.copyWith(isFavorite: !doc.isFavorite);
    await updateDocument(updated);
    return updated.isFavorite;
  }

  /// Cập nhật nhanh trạng thái học tập (new -> in_progress -> completed)
  Future<void> updateDocumentStatus(String id, DocumentStatus newStatus) async {
    final doc = await getDocumentById(id);
    if (doc == null) return;
    final updated = doc.copyWith(status: newStatus);
    await updateDocument(updated);
  }

  /// Tìm kiếm và lọc tài liệu theo nhiều tiêu chí
  Future<List<Document>> searchDocuments({
    String query = '',
    String? subjectId,
    DocumentType? type,
    DocumentStatus? status,
    bool? isFavorite,
    String sortBy = 'date_desc', // date_desc, date_asc, title_asc, due_date
  }) async {
    try {
      final db = await database;
      List<Document> list;

      if (db == null) {
        list = List<Document>.from(_fallbackDocuments);
        if (subjectId != null && subjectId.isNotEmpty) {
          list = list.where((d) => d.subjectId == subjectId).toList();
        }
        if (type != null) {
          list = list.where((d) => d.documentType == type).toList();
        }
        if (status != null) {
          list = list.where((d) => d.status == status).toList();
        }
        if (isFavorite != null && isFavorite) {
          list = list.where((d) => d.isFavorite).toList();
        }
      } else {
        final List<String> whereClauses = [];
        final List<dynamic> whereArgs = [];

        if (subjectId != null && subjectId.isNotEmpty) {
          whereClauses.add('subject_id = ?');
          whereArgs.add(subjectId);
        }

        if (type != null) {
          whereClauses.add('document_type = ?');
          whereArgs.add(type.id);
        }

        if (status != null) {
          whereClauses.add('status = ?');
          whereArgs.add(status.id);
        }

        if (isFavorite != null && isFavorite) {
          whereClauses.add('is_favorite = 1');
        }

        final String? where = whereClauses.isNotEmpty
            ? whereClauses.join(' AND ')
            : null;

        final List<Map<String, dynamic>> maps = await db.query(
          AppTables.tableDocuments,
          where: where,
          whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        );

        list = maps.map((m) => Document.fromMap(m)).toList();
      }

      // Sắp xếp
      switch (sortBy) {
        case 'date_asc':
          list.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
          break;
        case 'title_asc':
          list.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
          break;
        case 'due_date':
          list.sort((a, b) {
            if (a.dueDate == null && b.dueDate == null) return 0;
            if (a.dueDate == null) return 1;
            if (b.dueDate == null) return -1;
            return a.dueDate!.compareTo(b.dueDate!);
          });
          break;
        case 'date_desc':
        default:
          list.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
          break;
      }

      // Lọc theo từ khóa trong bộ nhớ để hỗ trợ bỏ dấu tiếng Việt
      if (query.trim().isNotEmpty) {
        final normalizedQuery = _normalizeText(query);
        list = list.where((doc) {
          final title = _normalizeText(doc.title);
          final desc = _normalizeText(doc.description);
          final tags = _normalizeText(doc.tags.join(' '));
          return title.contains(normalizedQuery) ||
              desc.contains(normalizedQuery) ||
              tags.contains(normalizedQuery);
        }).toList();
      }

      return list;
    } catch (e) {
      debugPrint('searchDocuments fallback notice: $e');
      return [];
    }
  }

  // ===========================================================================
  // MÔN HỌC (SUBJECTS) - THAO TÁC CƠ SỞ DỮ LIỆU
  // ===========================================================================

  /// Lấy toàn bộ danh sách môn học
  Future<List<Subject>> getAllSubjects() async {
    try {
      final db = await database;
      if (db == null) {
        return List<Subject>.from(_fallbackSubjects)
          ..sort((a, b) => a.name.compareTo(b.name));
      }
      final List<Map<String, dynamic>> maps = await db.query(
        AppTables.tableSubjects,
        orderBy: 'name ASC',
      );
      return maps.map((map) => Subject.fromMap(map)).toList();
    } catch (e) {
      debugPrint('getAllSubjects fallback notice: $e');
      return List<Subject>.from(
        _fallbackSubjects.isNotEmpty
            ? _fallbackSubjects
            : MockData.initialSubjects,
      );
    }
  }

  /// Lấy môn học theo ID
  Future<Subject?> getSubjectById(String id) async {
    try {
      final db = await database;
      if (db == null) {
        try {
          return _fallbackSubjects.firstWhere((s) => s.id == id);
        } catch (_) {
          return null;
        }
      }
      final List<Map<String, dynamic>> maps = await db.query(
        AppTables.tableSubjects,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return Subject.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('getSubjectById fallback notice: $e');
      try {
        return _fallbackSubjects.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
  }

  /// Thêm mới môn học
  Future<int> insertSubject(Subject subject) async {
    try {
      final db = await database;
      if (db == null) {
        _fallbackSubjects.removeWhere((s) => s.id == subject.id);
        _fallbackSubjects.add(subject);
        await _notifyWatchers();
        return 1;
      }
      final result = await db.insert(
        AppTables.tableSubjects,
        subject.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _notifyWatchers();
      return result;
    } catch (e) {
      debugPrint('insertSubject fallback notice: $e');
      _fallbackSubjects.removeWhere((s) => s.id == subject.id);
      _fallbackSubjects.add(subject);
      await _notifyWatchers();
      return 1;
    }
  }

  /// Cập nhật môn học
  Future<int> updateSubject(Subject subject) async {
    final updated = subject.copyWith(dateModified: DateTime.now());
    try {
      final db = await database;
      if (db == null) {
        final idx = _fallbackSubjects.indexWhere((s) => s.id == subject.id);
        if (idx != -1) {
          _fallbackSubjects[idx] = updated;
        } else {
          _fallbackSubjects.add(updated);
        }
        await _notifyWatchers();
        return 1;
      }
      final result = await db.update(
        AppTables.tableSubjects,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [subject.id],
      );
      await _notifyWatchers();
      return result;
    } catch (e) {
      debugPrint('updateSubject fallback notice: $e');
      final idx = _fallbackSubjects.indexWhere((s) => s.id == subject.id);
      if (idx != -1) {
        _fallbackSubjects[idx] = updated;
      } else {
        _fallbackSubjects.add(updated);
      }
      await _notifyWatchers();
      return 1;
    }
  }

  /// Xóa môn học và cascade xóa các tài liệu liên quan
  Future<int> deleteSubject(String id) async {
    try {
      final db = await database;
      if (db == null) {
        final deletedAt = DateTime.now().toIso8601String();
        final childIds = _fallbackDocuments
            .where((document) => document.subjectId == id)
            .map((document) => document.id)
            .toList();
        _fallbackDeleteLogs.add({
          'id': _uuid.v4(),
          'item_id': id,
          'table_name': AppTables.tableSubjects,
          'date_deleted': deletedAt,
        });
        for (final childId in childIds) {
          _fallbackDeleteLogs.add({
            'id': _uuid.v4(),
            'item_id': childId,
            'table_name': AppTables.tableDocuments,
            'date_deleted': deletedAt,
          });
        }
        _fallbackDocuments.removeWhere((d) => d.subjectId == id);
        _fallbackSubjects.removeWhere((s) => s.id == id);
        await _notifyWatchers();
        return 1;
      }
      final result = await db.transaction((txn) async {
        final childDocs = await txn.query(
          AppTables.tableDocuments,
          columns: ['id'],
          where: 'subject_id = ?',
          whereArgs: [id],
        );
        final deletedAt = DateTime.now().toIso8601String();
        await txn.insert(AppTables.tableDeleteLogs, {
          'id': _uuid.v4(),
          'item_id': id,
          'table_name': AppTables.tableSubjects,
          'date_deleted': deletedAt,
        });
        for (final child in childDocs) {
          await txn.insert(AppTables.tableDeleteLogs, {
            'id': _uuid.v4(),
            'item_id': child['id'],
            'table_name': AppTables.tableDocuments,
            'date_deleted': deletedAt,
          });
        }

        await txn.delete(
          AppTables.tableDocuments,
          where: 'subject_id = ?',
          whereArgs: [id],
        );

        return await txn.delete(
          AppTables.tableSubjects,
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      await _notifyWatchers();
      return result;
    } catch (e) {
      debugPrint('deleteSubject fallback notice: $e');
      _fallbackDeleteLogs.add({
        'id': _uuid.v4(),
        'item_id': id,
        'table_name': AppTables.tableSubjects,
        'date_deleted': DateTime.now().toIso8601String(),
      });
      _fallbackDocuments.removeWhere((d) => d.subjectId == id);
      _fallbackSubjects.removeWhere((s) => s.id == id);
      await _notifyWatchers();
      return 1;
    }
  }

  // ===========================================================================
  // THỐNG KÊ (ANALYTICS & STATS)
  // ===========================================================================

  /// Lấy tổng hợp số liệu thống kê tài liệu học tập
  Future<Map<String, int>> getDocumentStats() async {
    try {
      final db = await database;
      if (db == null) {
        return {
          'total_documents': _fallbackDocuments.length,
          'total_subjects': _fallbackSubjects.length,
          'lectures_count': _fallbackDocuments
              .where((d) => d.documentType == DocumentType.lecture)
              .length,
          'assignments_count': _fallbackDocuments
              .where((d) => d.documentType == DocumentType.assignment)
              .length,
          'completed_count': _fallbackDocuments
              .where((d) => d.status == DocumentStatus.completed)
              .length,
          'in_progress_count': _fallbackDocuments
              .where((d) => d.status == DocumentStatus.inProgress)
              .length,
          'favorites_count': _fallbackDocuments
              .where((d) => d.isFavorite)
              .length,
        };
      }

      final totalDocs =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${AppTables.tableDocuments}',
            ),
          ) ??
          0;

      final totalSubjects =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM ${AppTables.tableSubjects}',
            ),
          ) ??
          0;

      final lecturesCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM ${AppTables.tableDocuments} WHERE document_type = 'lecture'",
            ),
          ) ??
          0;

      final assignmentsCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM ${AppTables.tableDocuments} WHERE document_type = 'assignment'",
            ),
          ) ??
          0;

      final completedCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM ${AppTables.tableDocuments} WHERE status = 'completed'",
            ),
          ) ??
          0;

      final inProgressCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM ${AppTables.tableDocuments} WHERE status = 'in_progress'",
            ),
          ) ??
          0;

      final favoritesCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM ${AppTables.tableDocuments} WHERE is_favorite = 1",
            ),
          ) ??
          0;

      return {
        'total_documents': totalDocs,
        'total_subjects': totalSubjects,
        'lectures_count': lecturesCount,
        'assignments_count': assignmentsCount,
        'completed_count': completedCount,
        'in_progress_count': inProgressCount,
        'favorites_count': favoritesCount,
      };
    } catch (e) {
      debugPrint('getDocumentStats fallback notice: $e');
      return {
        'total_documents': _fallbackDocuments.length,
        'total_subjects': _fallbackSubjects.length,
        'lectures_count': _fallbackDocuments
            .where((d) => d.documentType == DocumentType.lecture)
            .length,
        'assignments_count': _fallbackDocuments
            .where((d) => d.documentType == DocumentType.assignment)
            .length,
        'completed_count': _fallbackDocuments
            .where((d) => d.status == DocumentStatus.completed)
            .length,
        'in_progress_count': _fallbackDocuments
            .where((d) => d.status == DocumentStatus.inProgress)
            .length,
        'favorites_count': _fallbackDocuments.where((d) => d.isFavorite).length,
      };
    }
  }

  /// Lấy danh sách lịch sử xóa từ delete_logs
  Future<List<Map<String, dynamic>>> getDeleteLogs() async {
    try {
      final db = await database;
      if (db == null) {
        return List<Map<String, dynamic>>.from(_fallbackDeleteLogs);
      }
      return await db.query(
        AppTables.tableDeleteLogs,
        orderBy: 'date_deleted DESC',
      );
    } catch (e) {
      debugPrint('getDeleteLogs fallback notice: $e');
      return List<Map<String, dynamic>>.from(_fallbackDeleteLogs);
    }
  }

  /// Xóa toàn bộ dữ liệu và nạp lại dữ liệu ban đầu (Reset Database)
  Future<void> resetToDefault() async {
    try {
      final db = await database;
      if (db == null) {
        _fallbackDocuments.clear();
        _fallbackDocuments.addAll(MockData.getInitialDocuments());
        _fallbackSubjects.clear();
        _fallbackSubjects.addAll(MockData.initialSubjects);
        _fallbackDeleteLogs.clear();
        await _notifyWatchers();
        return;
      }
      await db.delete(AppTables.tableDocuments);
      await db.delete(AppTables.tableSubjects);
      await db.delete(AppTables.tableDeleteLogs);
      await _seedInitialDataIfNeeded(db);
      await _notifyWatchers();
    } catch (e) {
      debugPrint('resetToDefault fallback notice: $e');
      _fallbackDocuments.clear();
      _fallbackDocuments.addAll(MockData.getInitialDocuments());
      _fallbackSubjects.clear();
      _fallbackSubjects.addAll(MockData.initialSubjects);
      _fallbackDeleteLogs.clear();
      await _notifyWatchers();
    }
  }

  /// Hàm chuẩn hóa chuỗi tiếng Việt tìm kiếm
  String _normalizeText(String str) {
    var result = str.toLowerCase();
    const vietnamese = [
      'aàảãáạăằẳẵắặâầẩẫấậ',
      'dđ',
      'eèẻẽéẹêềểễếệ',
      'iìỉĩíị',
      'oòỏõóọôồổỗốộơờởỡớợ',
      'uùủũúụưừửữứự',
      'yỳỷỹýỵ',
    ];
    const latin = ['a', 'd', 'e', 'i', 'o', 'u', 'y'];

    for (var i = 0; i < vietnamese.length; i++) {
      for (var char in vietnamese[i].split('')) {
        result = result.replaceAll(char, latin[i]);
      }
    }
    return result;
  }

  /// Giải phóng tài nguyên StreamControllers
  void dispose() {
    _documentsStreamController.close();
    _subjectsStreamController.close();
    _statsStreamController.close();
  }
}
