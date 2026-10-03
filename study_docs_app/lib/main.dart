import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'pages/home_dashboard_page.dart';
import 'struct/document_repository.dart';
import 'struct/document_state_provider.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Database singleton theo kiến trúc Cashew (Local-first)
  final appDb = AppDatabase.instance;
  try {
    await appDb.database;
  } catch (e) {
    debugPrint('Database initialization warning: $e');
  }

  // Khởi tạo Repository chứa logic nghiệp vụ
  final repository = DocumentRepository(db: appDb);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DocumentStateProvider(repository: repository),
        ),
      ],
      child: const StudyDocsCashewApp(),
    ),
  );
}

class StudyDocsCashewApp extends StatelessWidget {
  const StudyDocsCashewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Tài Liệu Học Tập (Cashew Architecture)',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeDashboardPage(),
    );
  }
}
